`timescale 1ns / 1ps

module pls_security_controller(
    input wire clk,
    input wire rst,

    input wire [7:0] gamma_D,
    input wire [7:0] gamma_E,
    input wire [7:0] leakage_index,
    input wire [7:0] outage_value,

    input wire [15:0] P_req,
    input wire [15:0] P_auth,

    input wire can_abnormal,
    input wire repeated_violation,

    output reg [1:0] security_state,

    output reg normal_led,
    output reg secure_led,
    output reg alarm_led,
    output reg isolate_led,

    output reg relay_trip,
    output reg charging_enable,

    output reg [10:0] can_command_id
);

// ======================================================
// Parameter Definitions
// ======================================================

parameter [1:0] STATE_NORMAL  = 2'b00;
parameter [1:0] STATE_SECURE  = 2'b01;
parameter [1:0] STATE_ALARM   = 2'b10;
parameter [1:0] STATE_ISOLATE = 2'b11;

parameter [7:0]  SECRECY_MARGIN    = 8'd5;
parameter [7:0]  LEAKAGE_THRESHOLD = 8'd80;
parameter [7:0]  OUTAGE_THRESHOLD  = 8'd100;
parameter [15:0] POWER_DIFF_LIMIT  = 16'd500;

// CAN command identifiers
parameter [10:0] CAN_NORMAL_CMD  = 11'h100;
parameter [10:0] CAN_SECURE_CMD  = 11'h101;
parameter [10:0] CAN_ALARM_CMD   = 11'h102;
parameter [10:0] CAN_ISOLATE_CMD = 11'h103;

// ======================================================
// Internal Wires and Registers
// ======================================================

reg secrecy_safe;
reg leakage_attack;
reg outage_attack;
reg false_power_demand;
reg attack_detected;

reg [15:0] power_difference;

// To avoid overflow in gamma_E + SECRECY_MARGIN
wire [8:0] gamma_D_ext;
wire [8:0] gamma_E_margin;

assign gamma_D_ext    = {1'b0, gamma_D};
assign gamma_E_margin = {1'b0, gamma_E} + {1'b0, SECRECY_MARGIN};

// ======================================================
// Power Difference Calculation
// ======================================================

always @(*) begin
    if (P_req >= P_auth)
        power_difference = P_req - P_auth;
    else
        power_difference = P_auth - P_req;
end

// ======================================================
// Security Condition Calculation
// ======================================================

always @(*) begin
    if (gamma_D_ext > gamma_E_margin)
        secrecy_safe = 1'b1;
    else
        secrecy_safe = 1'b0;

    if (leakage_index > LEAKAGE_THRESHOLD)
        leakage_attack = 1'b1;
    else
        leakage_attack = 1'b0;

    if (outage_value > OUTAGE_THRESHOLD)
        outage_attack = 1'b1;
    else
        outage_attack = 1'b0;

    if (power_difference > POWER_DIFF_LIMIT)
        false_power_demand = 1'b1;
    else
        false_power_demand = 1'b0;

    attack_detected = leakage_attack |
                      outage_attack |
                      false_power_demand |
                      can_abnormal;
end

// ======================================================
// Main FSM Logic
// ======================================================

always @(posedge clk or posedge rst) begin
    if (rst) begin
        security_state <= STATE_NORMAL;
    end
    else begin
        case (security_state)

            STATE_NORMAL: begin
                if (repeated_violation)
                    security_state <= STATE_ISOLATE;
                else if (attack_detected)
                    security_state <= STATE_ALARM;
                else if (!secrecy_safe)
                    security_state <= STATE_SECURE;
                else
                    security_state <= STATE_NORMAL;
            end

            STATE_SECURE: begin
                if (repeated_violation)
                    security_state <= STATE_ISOLATE;
                else if (attack_detected)
                    security_state <= STATE_ALARM;
                else if (secrecy_safe)
                    security_state <= STATE_NORMAL;
                else
                    security_state <= STATE_SECURE;
            end

            STATE_ALARM: begin
                if (repeated_violation)
                    security_state <= STATE_ISOLATE;
                else if (!attack_detected && secrecy_safe)
                    security_state <= STATE_NORMAL;
                else
                    security_state <= STATE_ALARM;
            end

            STATE_ISOLATE: begin
                security_state <= STATE_ISOLATE;
            end

            default: begin
                security_state <= STATE_NORMAL;
            end

        endcase
    end
end

// ======================================================
// Output Logic
// ======================================================

always @(*) begin
    normal_led       = 1'b0;
    secure_led       = 1'b0;
    alarm_led        = 1'b0;
    isolate_led      = 1'b0;
    relay_trip       = 1'b0;
    charging_enable  = 1'b1;
    can_command_id   = CAN_NORMAL_CMD;

    case (security_state)

        STATE_NORMAL: begin
            normal_led       = 1'b1;
            charging_enable  = 1'b1;
            relay_trip       = 1'b0;
            can_command_id   = CAN_NORMAL_CMD;
        end

        STATE_SECURE: begin
            secure_led       = 1'b1;
            charging_enable  = 1'b1;
            relay_trip       = 1'b0;
            can_command_id   = CAN_SECURE_CMD;
        end

        STATE_ALARM: begin
            alarm_led        = 1'b1;
            charging_enable  = 1'b1;
            relay_trip       = 1'b0;
            can_command_id   = CAN_ALARM_CMD;
        end

        STATE_ISOLATE: begin
            isolate_led      = 1'b1;
            charging_enable  = 1'b0;
            relay_trip       = 1'b1;
            can_command_id   = CAN_ISOLATE_CMD;
        end

        default: begin
            normal_led       = 1'b1;
            charging_enable  = 1'b1;
            relay_trip       = 1'b0;
            can_command_id   = CAN_NORMAL_CMD;
        end

    endcase
end

endmodule
