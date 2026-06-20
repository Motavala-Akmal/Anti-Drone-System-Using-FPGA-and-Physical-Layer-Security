`timescale 1ns / 1ps
// ============================================================
// Anti-Drone PLS Security Controller
// MATLAB-to-Vivado mapped Verilog version
//
// This file contains:
//   1. anti_drone_pls_core
//      - Synthesizable risk-score and decision logic
//   2. anti_drone_pls_board_demo_top
//      - Board-level wrapper using 2-bit mode_select
//   3. tb_anti_drone_pls_board_demo_top
//      - Simulation testbench
//
// Scaling used for fixed-point inputs:
//   CSI mismatch              : value x 1000
//   RF fingerprint distance   : value x 1000
//   Secrecy capacity          : value x 1000
//   Activity duty cycle       : value x 1000
//   BER                       : value x 1,000,000
//
// Example:
//   CSI = 0.5744  -> csi_mismatch_x1000 = 574
//   BER = 0.0045  -> mean_bob_ber_x1e6  = 4500
// ============================================================


// ============================================================
// MODULE 1: CORE ANTI-DRONE PLS DECISION LOGIC
// ============================================================
module anti_drone_pls_core
#(
    parameter signed [7:0] EXPECTED_BOB_RSSI_DBM = -8'sd55,

    parameter [7:0]  RSSI_MISMATCH_TH_DB         = 8'd8,
    parameter [15:0] CSI_MISMATCH_TH_X1000       = 16'd350,
    parameter [7:0]  LOCATION_ERROR_TH_M         = 8'd10,
    parameter [15:0] RF_FINGERPRINT_TH_X1000     = 16'd300,

    parameter [15:0] SECRECY_REQ_X1000           = 16'd1000,

    parameter signed [7:0] INTERFERENCE_HIGH_TH_DBM = -8'sd75,
    parameter [7:0]  BOB_SNR_LOW_TH_DB           = 8'd10,
    parameter [31:0] BER_HIGH_TH_X1E6            = 32'd10000,

    parameter [7:0]  LATENCY_RELAY_TH_MS         = 8'd25,

    parameter [15:0] INTERMITTENT_DUTY_MIN_X1000 = 16'd100,
    parameter [15:0] INTERMITTENT_DUTY_MAX_X1000 = 16'd700,

    parameter [7:0]  NEEDS_VERIFICATION_TH       = 8'd20,
    parameter [7:0]  SUSPICIOUS_TH               = 8'd40,
    parameter [7:0]  LIKELY_EVE_TH               = 8'd65,
    parameter [7:0]  HIGH_RISK_EVE_TH            = 8'd80
)
(
    // --------------------------------------------------------
    // Status / identity inputs
    // --------------------------------------------------------
    input  wire        inside_boundary,
    input  wire        claimed_bob,
    input  wire        registered,
    input  wire        auth_passed,
    input  wire        mobility_static,

    // --------------------------------------------------------
    // Activity and evidence inputs
    // --------------------------------------------------------
    input  wire        tx_detected,
    input  wire        rx_detected,
    input  wire        pilot_mismatch,
    input  wire        relay_evidence,
    input  wire        collusion_detected,

    // --------------------------------------------------------
    // Valid flags for physical-layer measurements
    // --------------------------------------------------------
    input  wire        rssi_valid,
    input  wire        csi_valid,

    // --------------------------------------------------------
    // Physical-layer / security measurements
    // --------------------------------------------------------
    input  wire signed [7:0]  mean_rssi_dbm,
    input  wire        [15:0] csi_mismatch_x1000,
    input  wire        [7:0]  location_error_m,
    input  wire        [15:0] rf_fingerprint_x1000,

    input  wire        [7:0]  mean_bob_snr_db,
    input  wire        [31:0] mean_bob_ber_x1e6,
    input  wire signed [7:0]  interference_dbm,

    input  wire        [15:0] mean_secrecy_capacity_x1000,
    input  wire        [7:0]  latency_ms,
    input  wire        [15:0] activity_duty_x1000,

    // --------------------------------------------------------
    // Score outputs
    // --------------------------------------------------------
    output reg         jamming_condition,

    output reg  [7:0]  identity_score,
    output reg  [7:0]  authentication_score,
    output reg  [7:0]  rssi_score,
    output reg  [7:0]  csi_score,
    output reg  [7:0]  location_score,
    output reg  [7:0]  rf_fingerprint_score,
    output reg  [7:0]  secrecy_score,
    output reg  [7:0]  activity_score,
    output reg  [7:0]  jamming_score,
    output reg  [7:0]  relay_score,
    output reg  [7:0]  collusion_score,

    output reg  [7:0]  total_risk_score,

    // --------------------------------------------------------
    // Final decision outputs
    //
    // decision_code:
    //   0 = Normal / Low risk / Verified Bob
    //   1 = Needs verification
    //   2 = Suspicious / Secure monitoring
    //   3 = Likely Eve / Alarm
    //   4 = High-risk Eve / Isolation
    //
    // pls_mode:
    //   00 = Normal
    //   01 = Secure monitoring / Weak secrecy
    //   10 = Alarm
    //   11 = Isolation
    // --------------------------------------------------------
    output reg  [2:0]  decision_code,
    output reg  [1:0]  pls_mode,

    output reg         normal_led,
    output reg         secure_led,
    output reg         alarm_led,
    output reg         isolate_led,

    output reg         relay_trip,
    output reg         charging_enable
);

    reg signed [8:0] rssi_delta;
    reg        [8:0] rssi_abs;
    reg        [15:0] score_sum;
    reg               verified_bob_condition;

    always @(*) begin
        // ----------------------------------------------------
        // Default values
        // ----------------------------------------------------
        identity_score        = 8'd0;
        authentication_score  = 8'd0;
        rssi_score            = 8'd0;
        csi_score             = 8'd0;
        location_score        = 8'd0;
        rf_fingerprint_score  = 8'd0;
        secrecy_score         = 8'd0;
        activity_score        = 8'd0;
        jamming_score         = 8'd0;
        relay_score           = 8'd0;
        collusion_score       = 8'd0;

        total_risk_score      = 8'd0;
        score_sum             = 16'd0;

        decision_code         = 3'd0;
        pls_mode              = 2'b00;

        normal_led            = 1'b0;
        secure_led            = 1'b0;
        alarm_led             = 1'b0;
        isolate_led           = 1'b0;

        relay_trip            = 1'b0;
        charging_enable       = 1'b1;

        rssi_delta            = 9'sd0;
        rssi_abs              = 9'd0;

        verified_bob_condition = 1'b0;

        // ----------------------------------------------------
        // Jamming / link degradation condition
        // MATLAB equivalent:
        //   interference > -75 OR Bob SNR < 10 OR BER > 1e-2
        // ----------------------------------------------------
        if (($signed(interference_dbm) > $signed(INTERFERENCE_HIGH_TH_DBM)) ||
            (mean_bob_snr_db < BOB_SNR_LOW_TH_DB) ||
            (mean_bob_ber_x1e6 > BER_HIGH_TH_X1E6)) begin
            jamming_condition = 1'b1;
        end
        else begin
            jamming_condition = 1'b0;
        end

        // ----------------------------------------------------
        // If drone is outside the protected boundary,
        // keep system in normal monitoring state.
        // ----------------------------------------------------
        if (inside_boundary == 1'b0) begin
            total_risk_score = 8'd0;
            decision_code    = 3'd0;
            pls_mode         = 2'b00;

            normal_led       = 1'b1;
            secure_led       = 1'b0;
            alarm_led        = 1'b0;
            isolate_led      = 1'b0;

            relay_trip       = 1'b0;
            charging_enable  = 1'b1;
        end

        else begin
            // ------------------------------------------------
            // Identity score
            // ------------------------------------------------
            if (claimed_bob && registered && auth_passed) begin
                identity_score = 8'd0;
            end
            else if (claimed_bob && !registered) begin
                identity_score = 8'd25;
            end
            else if (registered && !auth_passed) begin
                identity_score = 8'd20;
            end
            else if (relay_evidence || (latency_ms > LATENCY_RELAY_TH_MS)) begin
                identity_score = 8'd20;
            end
            else if (!registered) begin
                identity_score = 8'd20;
            end
            else begin
                identity_score = 8'd10;
            end

            // Mobility mismatch:
            // Bob is expected to be static in this project.
            if (claimed_bob && !mobility_static) begin
                identity_score = identity_score + 8'd10;
            end

            // ------------------------------------------------
            // Authentication and pilot verification score
            // ------------------------------------------------
            if (!auth_passed) begin
                authentication_score = authentication_score + 8'd20;
            end

            if (pilot_mismatch) begin
                authentication_score = authentication_score + 8'd10;
            end

            // ------------------------------------------------
            // RSSI mismatch score
            // RSSI mismatch = abs(observed RSSI - expected Bob RSSI)
            // ------------------------------------------------
            rssi_delta = $signed(mean_rssi_dbm) - $signed(EXPECTED_BOB_RSSI_DBM);

            if (rssi_delta < 0) begin
                rssi_abs = -rssi_delta;
            end
            else begin
                rssi_abs = rssi_delta;
            end

            if (rssi_valid && (rssi_abs > RSSI_MISMATCH_TH_DB)) begin
                rssi_score = 8'd10;
            end

            // ------------------------------------------------
            // CSI mismatch score
            // ------------------------------------------------
            if (csi_valid && (csi_mismatch_x1000 > CSI_MISMATCH_TH_X1000)) begin
                csi_score = 8'd15;
            end

            // ------------------------------------------------
            // Location error score
            // ------------------------------------------------
            if (location_error_m > LOCATION_ERROR_TH_M) begin
                location_score = 8'd15;
            end

            // ------------------------------------------------
            // RF fingerprint score
            // ------------------------------------------------
            if (rf_fingerprint_x1000 > RF_FINGERPRINT_TH_X1000) begin
                rf_fingerprint_score = 8'd15;
            end

            // ------------------------------------------------
            // Secrecy capacity score
            // Here, the FPGA receives already-computed/estimated
            // secrecy capacity scaled by 1000.
            // ------------------------------------------------
            if (mean_secrecy_capacity_x1000 < SECRECY_REQ_X1000) begin
                secrecy_score = 8'd20;
            end

            // ------------------------------------------------
            // Activity score
            // ------------------------------------------------
            if ((!tx_detected) && rx_detected) begin
                activity_score = activity_score + 8'd10;   // passive/listening
            end

            if (tx_detected) begin
                activity_score = activity_score + 8'd10;   // transmitting
            end

            if (jamming_condition) begin
                activity_score = activity_score + 8'd15;   // jamming-related activity
            end

            if ((activity_duty_x1000 > INTERMITTENT_DUTY_MIN_X1000) &&
                (activity_duty_x1000 < INTERMITTENT_DUTY_MAX_X1000)) begin
                activity_score = activity_score + 8'd10;   // intermittent Eve behavior
            end

            // ------------------------------------------------
            // Jamming score
            // ------------------------------------------------
            if (jamming_condition) begin
                jamming_score = 8'd20;
            end

            // ------------------------------------------------
            // Relay score
            // ------------------------------------------------
            if (relay_evidence || (latency_ms > LATENCY_RELAY_TH_MS)) begin
                relay_score = 8'd15;
            end

            // ------------------------------------------------
            // Collusion score
            // ------------------------------------------------
            if (collusion_detected) begin
                collusion_score = 8'd15;
            end

            // ------------------------------------------------
            // Total risk score = sum of all evidence scores
            // capped at 100.
            // ------------------------------------------------
            score_sum =
                identity_score +
                authentication_score +
                rssi_score +
                csi_score +
                location_score +
                rf_fingerprint_score +
                secrecy_score +
                activity_score +
                jamming_score +
                relay_score +
                collusion_score;

            if (score_sum > 16'd100) begin
                total_risk_score = 8'd100;
            end
            else begin
                total_risk_score = score_sum[7:0];
            end

            // ------------------------------------------------
            // Verified Bob condition
            // Bob is accepted only if identity and physical-layer
            // evidence are both clean.
            // ------------------------------------------------
            if (claimed_bob &&
                registered &&
                auth_passed &&
                (rssi_score == 8'd0) &&
                (csi_score == 8'd0) &&
                (location_score == 8'd0) &&
                (rf_fingerprint_score == 8'd0) &&
                (secrecy_score == 8'd0) &&
                (jamming_score == 8'd0)) begin
                verified_bob_condition = 1'b1;
            end
            else begin
                verified_bob_condition = 1'b0;
            end

            // ------------------------------------------------
            // Final decision and PLS mode mapping
            // ------------------------------------------------
            if (verified_bob_condition) begin
                decision_code = 3'd0;
                pls_mode      = 2'b00;      // Normal
            end
            else if (total_risk_score >= HIGH_RISK_EVE_TH) begin
                decision_code = 3'd4;
                pls_mode      = 2'b11;      // Isolation
            end
            else if (total_risk_score >= LIKELY_EVE_TH) begin
                decision_code = 3'd3;
                pls_mode      = 2'b10;      // Alarm
            end
            else if (total_risk_score >= SUSPICIOUS_TH) begin
                decision_code = 3'd2;
                pls_mode      = 2'b01;      // Secure monitoring
            end
            else if (total_risk_score >= NEEDS_VERIFICATION_TH) begin
                decision_code = 3'd1;
                pls_mode      = 2'b01;      // Secure monitoring
            end
            else begin
                decision_code = 3'd0;
                pls_mode      = 2'b00;      // Normal / Low risk
            end

            // ------------------------------------------------
            // PLS hardware outputs
            // Isolation has the highest priority.
            // ------------------------------------------------
            case (pls_mode)
                2'b00: begin
                    normal_led      = 1'b1;
                    secure_led      = 1'b0;
                    alarm_led       = 1'b0;
                    isolate_led     = 1'b0;
                    relay_trip      = 1'b0;
                    charging_enable = 1'b1;
                end

                2'b01: begin
                    normal_led      = 1'b0;
                    secure_led      = 1'b1;
                    alarm_led       = 1'b0;
                    isolate_led     = 1'b0;
                    relay_trip      = 1'b0;
                    charging_enable = 1'b1;
                end

                2'b10: begin
                    normal_led      = 1'b0;
                    secure_led      = 1'b0;
                    alarm_led       = 1'b1;
                    isolate_led     = 1'b0;
                    relay_trip      = 1'b1;
                    charging_enable = 1'b0;
                end

                2'b11: begin
                    normal_led      = 1'b0;
                    secure_led      = 1'b0;
                    alarm_led       = 1'b0;  // isolation priority
                    isolate_led     = 1'b1;
                    relay_trip      = 1'b1;
                    charging_enable = 1'b0;
                end

                default: begin
                    normal_led      = 1'b1;
                    secure_led      = 1'b0;
                    alarm_led       = 1'b0;
                    isolate_led     = 1'b0;
                    relay_trip      = 1'b0;
                    charging_enable = 1'b1;
                end
            endcase
        end
    end

endmodule



// ============================================================
// MODULE 2: BOARD-LEVEL WRAPPER FOR VIVADO / BASYS-STYLE DEMO
//
// mode_select:
//   00 = Verified Bob / Normal
//   01 = Weak secrecy / Secure monitoring
//   10 = Attack / Alarm
//   11 = Severe attack / Isolation
// ============================================================
module anti_drone_pls_board_demo_top
(
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  mode_select,

    output wire        normal_led,
    output wire        secure_led,
    output wire        alarm_led,
    output wire        isolate_led,

    output wire        relay_trip,
    output wire        charging_enable,

    output wire [7:0]  risk_score,
    output wire [2:0]  decision_code,
    output wire [1:0]  pls_mode
);

    // --------------------------------------------------------
    // Internal feature registers generated by wrapper
    // --------------------------------------------------------
    reg        inside_boundary;
    reg        claimed_bob;
    reg        registered;
    reg        auth_passed;
    reg        mobility_static;

    reg        tx_detected;
    reg        rx_detected;
    reg        pilot_mismatch;
    reg        relay_evidence;
    reg        collusion_detected;

    reg        rssi_valid;
    reg        csi_valid;

    reg signed [7:0]  mean_rssi_dbm;
    reg        [15:0] csi_mismatch_x1000;
    reg        [7:0]  location_error_m;
    reg        [15:0] rf_fingerprint_x1000;

    reg        [7:0]  mean_bob_snr_db;
    reg        [31:0] mean_bob_ber_x1e6;
    reg signed [7:0]  interference_dbm;

    reg        [15:0] mean_secrecy_capacity_x1000;
    reg        [7:0]  latency_ms;
    reg        [15:0] activity_duty_x1000;

    // Optional score wires for waveform observation
    wire        jamming_condition;

    wire [7:0] identity_score;
    wire [7:0] authentication_score;
    wire [7:0] rssi_score;
    wire [7:0] csi_score;
    wire [7:0] location_score;
    wire [7:0] rf_fingerprint_score;
    wire [7:0] secrecy_score;
    wire [7:0] activity_score;
    wire [7:0] jamming_score;
    wire [7:0] relay_score;
    wire [7:0] collusion_score;

    // --------------------------------------------------------
    // Scenario generation
    // These values are fixed-point hardware equivalents of the
    // MATLAB feature outputs.
    // --------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset to safe normal condition
            inside_boundary              <= 1'b1;
            claimed_bob                  <= 1'b1;
            registered                   <= 1'b1;
            auth_passed                  <= 1'b1;
            mobility_static              <= 1'b1;

            tx_detected                  <= 1'b1;
            rx_detected                  <= 1'b1;
            pilot_mismatch               <= 1'b0;
            relay_evidence               <= 1'b0;
            collusion_detected           <= 1'b0;

            rssi_valid                   <= 1'b1;
            csi_valid                    <= 1'b1;

            mean_rssi_dbm                <= -8'sd55;
            csi_mismatch_x1000           <= 16'd120;
            location_error_m             <= 8'd1;
            rf_fingerprint_x1000         <= 16'd100;

            mean_bob_snr_db              <= 8'd18;
            mean_bob_ber_x1e6            <= 32'd100;
            interference_dbm             <= -8'sd92;

            mean_secrecy_capacity_x1000  <= 16'd2000;
            latency_ms                   <= 8'd7;
            activity_duty_x1000          <= 16'd1000;
        end
        else begin
            case (mode_select)

                // ------------------------------------------------
                // 00: Normal / Verified Authorized Bob
                // Expected: normal_led = 1, charging_enable = 1
                // ------------------------------------------------
                2'b00: begin
                    inside_boundary              <= 1'b1;
                    claimed_bob                  <= 1'b1;
                    registered                   <= 1'b1;
                    auth_passed                  <= 1'b1;
                    mobility_static              <= 1'b1;

                    tx_detected                  <= 1'b1;
                    rx_detected                  <= 1'b1;
                    pilot_mismatch               <= 1'b0;
                    relay_evidence               <= 1'b0;
                    collusion_detected           <= 1'b0;

                    rssi_valid                   <= 1'b1;
                    csi_valid                    <= 1'b1;

                    mean_rssi_dbm                <= -8'sd55;
                    csi_mismatch_x1000           <= 16'd120;
                    location_error_m             <= 8'd1;
                    rf_fingerprint_x1000         <= 16'd100;

                    mean_bob_snr_db              <= 8'd18;
                    mean_bob_ber_x1e6            <= 32'd100;
                    interference_dbm             <= -8'sd92;

                    mean_secrecy_capacity_x1000  <= 16'd2000;
                    latency_ms                   <= 8'd7;
                    activity_duty_x1000          <= 16'd1000;
                end

                // ------------------------------------------------
                // 01: Weak secrecy / Secure monitoring
                // CSI mismatch and secrecy capacity are weak.
                // Expected: secure_led = 1
                // ------------------------------------------------
                2'b01: begin
                    inside_boundary              <= 1'b1;
                    claimed_bob                  <= 1'b1;
                    registered                   <= 1'b1;
                    auth_passed                  <= 1'b1;
                    mobility_static              <= 1'b1;

                    tx_detected                  <= 1'b1;
                    rx_detected                  <= 1'b1;
                    pilot_mismatch               <= 1'b0;
                    relay_evidence               <= 1'b0;
                    collusion_detected           <= 1'b0;

                    rssi_valid                   <= 1'b1;
                    csi_valid                    <= 1'b1;

                    mean_rssi_dbm                <= -8'sd54;
                    csi_mismatch_x1000           <= 16'd400;   // above 0.35
                    location_error_m             <= 8'd2;
                    rf_fingerprint_x1000         <= 16'd120;

                    mean_bob_snr_db              <= 8'd14;
                    mean_bob_ber_x1e6            <= 32'd2000;
                    interference_dbm             <= -8'sd85;

                    mean_secrecy_capacity_x1000  <= 16'd900;   // below 1.0
                    latency_ms                   <= 8'd9;
                    activity_duty_x1000          <= 16'd1000;
                end

                // ------------------------------------------------
                // 10: Attack / Alarm
                // Authentication failure and channel mismatch.
                // Expected: alarm_led = 1, relay_trip = 1
                // ------------------------------------------------
                2'b10: begin
                    inside_boundary              <= 1'b1;
                    claimed_bob                  <= 1'b0;
                    registered                   <= 1'b1;
                    auth_passed                  <= 1'b0;
                    mobility_static              <= 1'b1;

                    tx_detected                  <= 1'b1;
                    rx_detected                  <= 1'b1;
                    pilot_mismatch               <= 1'b0;
                    relay_evidence               <= 1'b0;
                    collusion_detected           <= 1'b0;

                    rssi_valid                   <= 1'b1;
                    csi_valid                    <= 1'b1;

                    mean_rssi_dbm                <= -8'sd55;
                    csi_mismatch_x1000           <= 16'd400;
                    location_error_m             <= 8'd3;
                    rf_fingerprint_x1000         <= 16'd100;

                    mean_bob_snr_db              <= 8'd16;
                    mean_bob_ber_x1e6            <= 32'd2000;
                    interference_dbm             <= -8'sd90;

                    mean_secrecy_capacity_x1000  <= 16'd1100;
                    latency_ms                   <= 8'd10;
                    activity_duty_x1000          <= 16'd1000;
                end

                // ------------------------------------------------
                // 11: Severe repeated attack / Isolation
                // Multiple severe indicators are active.
                // Expected: isolate_led = 1, relay_trip = 1
                // ------------------------------------------------
                2'b11: begin
                    inside_boundary              <= 1'b1;
                    claimed_bob                  <= 1'b1;
                    registered                   <= 1'b0;
                    auth_passed                  <= 1'b0;
                    mobility_static              <= 1'b0;

                    tx_detected                  <= 1'b1;
                    rx_detected                  <= 1'b1;
                    pilot_mismatch               <= 1'b1;
                    relay_evidence               <= 1'b1;
                    collusion_detected           <= 1'b1;

                    rssi_valid                   <= 1'b1;
                    csi_valid                    <= 1'b1;

                    mean_rssi_dbm                <= -8'sd38;
                    csi_mismatch_x1000           <= 16'd720;
                    location_error_m             <= 8'd35;
                    rf_fingerprint_x1000         <= 16'd850;

                    mean_bob_snr_db              <= 8'd7;
                    mean_bob_ber_x1e6            <= 32'd20000;
                    interference_dbm             <= -8'sd62;

                    mean_secrecy_capacity_x1000  <= 16'd500;
                    latency_ms                   <= 8'd35;
                    activity_duty_x1000          <= 16'd500;
                end

                default: begin
                    inside_boundary              <= 1'b1;
                    claimed_bob                  <= 1'b1;
                    registered                   <= 1'b1;
                    auth_passed                  <= 1'b1;
                    mobility_static              <= 1'b1;

                    tx_detected                  <= 1'b1;
                    rx_detected                  <= 1'b1;
                    pilot_mismatch               <= 1'b0;
                    relay_evidence               <= 1'b0;
                    collusion_detected           <= 1'b0;

                    rssi_valid                   <= 1'b1;
                    csi_valid                    <= 1'b1;

                    mean_rssi_dbm                <= -8'sd55;
                    csi_mismatch_x1000           <= 16'd120;
                    location_error_m             <= 8'd1;
                    rf_fingerprint_x1000         <= 16'd100;

                    mean_bob_snr_db              <= 8'd18;
                    mean_bob_ber_x1e6            <= 32'd100;
                    interference_dbm             <= -8'sd92;

                    mean_secrecy_capacity_x1000  <= 16'd2000;
                    latency_ms                   <= 8'd7;
                    activity_duty_x1000          <= 16'd1000;
                end
            endcase
        end
    end

    // --------------------------------------------------------
    // Core controller instance
    // --------------------------------------------------------
    anti_drone_pls_core CORE (
        .inside_boundary(inside_boundary),
        .claimed_bob(claimed_bob),
        .registered(registered),
        .auth_passed(auth_passed),
        .mobility_static(mobility_static),

        .tx_detected(tx_detected),
        .rx_detected(rx_detected),
        .pilot_mismatch(pilot_mismatch),
        .relay_evidence(relay_evidence),
        .collusion_detected(collusion_detected),

        .rssi_valid(rssi_valid),
        .csi_valid(csi_valid),

        .mean_rssi_dbm(mean_rssi_dbm),
        .csi_mismatch_x1000(csi_mismatch_x1000),
        .location_error_m(location_error_m),
        .rf_fingerprint_x1000(rf_fingerprint_x1000),

        .mean_bob_snr_db(mean_bob_snr_db),
        .mean_bob_ber_x1e6(mean_bob_ber_x1e6),
        .interference_dbm(interference_dbm),

        .mean_secrecy_capacity_x1000(mean_secrecy_capacity_x1000),
        .latency_ms(latency_ms),
        .activity_duty_x1000(activity_duty_x1000),

        .jamming_condition(jamming_condition),

        .identity_score(identity_score),
        .authentication_score(authentication_score),
        .rssi_score(rssi_score),
        .csi_score(csi_score),
        .location_score(location_score),
        .rf_fingerprint_score(rf_fingerprint_score),
        .secrecy_score(secrecy_score),
        .activity_score(activity_score),
        .jamming_score(jamming_score),
        .relay_score(relay_score),
        .collusion_score(collusion_score),

        .total_risk_score(risk_score),

        .decision_code(decision_code),
        .pls_mode(pls_mode),

        .normal_led(normal_led),
        .secure_led(secure_led),
        .alarm_led(alarm_led),
        .isolate_led(isolate_led),

        .relay_trip(relay_trip),
        .charging_enable(charging_enable)
    );

endmodule



// ============================================================
// MODULE 3: TESTBENCH
// Use this only for simulation.
// For synthesis/implementation, set anti_drone_pls_board_demo_top
// as the top module.
// ============================================================
module tb_anti_drone_pls_board_demo_top;

    reg clk;
    reg rst;
    reg [1:0] mode_select;

    wire normal_led;
    wire secure_led;
    wire alarm_led;
    wire isolate_led;
    wire relay_trip;
    wire charging_enable;
    wire [7:0] risk_score;
    wire [2:0] decision_code;
    wire [1:0] pls_mode;

    anti_drone_pls_board_demo_top DUT (
        .clk(clk),
        .rst(rst),
        .mode_select(mode_select),

        .normal_led(normal_led),
        .secure_led(secure_led),
        .alarm_led(alarm_led),
        .isolate_led(isolate_led),

        .relay_trip(relay_trip),
        .charging_enable(charging_enable),

        .risk_score(risk_score),
        .decision_code(decision_code),
        .pls_mode(pls_mode)
    );

    // 10 ns clock period = 100 MHz
    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        mode_select = 2'b00;

        #20;
        rst = 1'b0;

        // Normal / Verified Bob
        mode_select = 2'b00;
        #100;

        // Weak secrecy / Secure monitoring
        mode_select = 2'b01;
        #100;

        // Attack / Alarm
        mode_select = 2'b10;
        #100;

        // Severe attack / Isolation
        mode_select = 2'b11;
        #100;

        $stop;
    end

endmodule
