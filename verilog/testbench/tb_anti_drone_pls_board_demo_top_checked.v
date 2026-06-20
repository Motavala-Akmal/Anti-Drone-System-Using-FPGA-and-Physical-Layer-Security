`timescale 1ns / 1ps

// ============================================================
// TESTBENCH FOR ANTI-DRONE PLS SECURITY CONTROLLER
//
// DUT:
//   anti_drone_pls_board_demo_top
//
// Test sequence:
//   mode_select = 00 -> Normal / Verified Bob
//   mode_select = 01 -> Weak secrecy / Secure monitoring
//   mode_select = 10 -> Attack / Alarm
//   mode_select = 11 -> Severe attack / Isolation
// ============================================================

module tb_anti_drone_pls_board_demo_top_checked;

    // --------------------------------------------------------
    // Inputs to DUT
    // --------------------------------------------------------
    reg clk;
    reg rst;
    reg [1:0] mode_select;

    // --------------------------------------------------------
    // Outputs from DUT
    // --------------------------------------------------------
    wire normal_led;
    wire secure_led;
    wire alarm_led;
    wire isolate_led;

    wire relay_trip;
    wire charging_enable;

    wire [7:0] risk_score;
    wire [2:0] decision_code;
    wire [1:0] pls_mode;

    integer error_count;

    // --------------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------------
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

    // --------------------------------------------------------
    // Clock Generation
    // 10 ns clock period = 100 MHz
    // --------------------------------------------------------
    always #5 clk = ~clk;

    // --------------------------------------------------------
    // Test Task
    // --------------------------------------------------------
    task run_test_case;
        input [1:0] test_mode;
        input [255:0] test_name;

        input expected_normal;
        input expected_secure;
        input expected_alarm;
        input expected_isolate;

        input expected_relay;
        input expected_charging;

        input [7:0] expected_risk_score;
        input [2:0] expected_decision_code;
        input [1:0] expected_pls_mode;

        begin
            @(negedge clk);
            mode_select = test_mode;

            @(posedge clk);
            #2;

            $display("--------------------------------------------------");
            $display("TEST CASE: %s", test_name);
            $display("mode_select     = %b", mode_select);
            $display("risk_score      = %d", risk_score);
            $display("decision_code   = %d", decision_code);
            $display("pls_mode        = %b", pls_mode);
            $display("normal_led      = %b", normal_led);
            $display("secure_led      = %b", secure_led);
            $display("alarm_led       = %b", alarm_led);
            $display("isolate_led     = %b", isolate_led);
            $display("relay_trip      = %b", relay_trip);
            $display("charging_enable = %b", charging_enable);

            if (
                normal_led      !== expected_normal        ||
                secure_led      !== expected_secure        ||
                alarm_led       !== expected_alarm         ||
                isolate_led     !== expected_isolate       ||
                relay_trip      !== expected_relay         ||
                charging_enable !== expected_charging      ||
                risk_score      !== expected_risk_score    ||
                decision_code   !== expected_decision_code ||
                pls_mode        !== expected_pls_mode
            ) begin
                $display("RESULT: FAILED");
                error_count = error_count + 1;
            end
            else begin
                $display("RESULT: PASSED");
            end

            #80;
        end
    endtask

    // --------------------------------------------------------
    // Main Test Sequence
    // --------------------------------------------------------
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        mode_select = 2'b00;
        error_count = 0;

        $display("==================================================");
        $display("ANTI-DRONE PLS SECURITY CONTROLLER TESTBENCH");
        $display("==================================================");

        // Apply reset
        #20;
        rst = 1'b0;

        // ----------------------------------------------------
        // Mode 00: Normal / Verified Bob
        // Expected:
        // normal_led = 1
        // charging_enable = 1
        // risk_score = 10
        // pls_mode = 00
        // ----------------------------------------------------
        run_test_case(
            2'b00,
            "MODE 00: NORMAL / VERIFIED BOB",
            1'b1,   // normal_led
            1'b0,   // secure_led
            1'b0,   // alarm_led
            1'b0,   // isolate_led
            1'b0,   // relay_trip
            1'b1,   // charging_enable
            8'd10,  // risk_score
            3'd0,   // decision_code
            2'b00   // pls_mode
        );

        // ----------------------------------------------------
        // Mode 01: Weak Secrecy / Secure Monitoring
        // Expected:
        // secure_led = 1
        // charging_enable = 1
        // risk_score = 45
        // pls_mode = 01
        // ----------------------------------------------------
        run_test_case(
            2'b01,
            "MODE 01: WEAK SECRECY / SECURE MONITORING",
            1'b0,   // normal_led
            1'b1,   // secure_led
            1'b0,   // alarm_led
            1'b0,   // isolate_led
            1'b0,   // relay_trip
            1'b1,   // charging_enable
            8'd45,  // risk_score
            3'd2,   // decision_code
            2'b01   // pls_mode
        );

        // ----------------------------------------------------
        // Mode 10: Attack / Alarm
        // Expected:
        // alarm_led = 1
        // relay_trip = 1
        // charging_enable = 0
        // risk_score = 65
        // pls_mode = 10
        // ----------------------------------------------------
        run_test_case(
            2'b10,
            "MODE 10: ATTACK / ALARM",
            1'b0,   // normal_led
            1'b0,   // secure_led
            1'b1,   // alarm_led
            1'b0,   // isolate_led
            1'b1,   // relay_trip
            1'b0,   // charging_enable
            8'd65,  // risk_score
            3'd3,   // decision_code
            2'b10   // pls_mode
        );

        // ----------------------------------------------------
        // Mode 11: Severe Attack / Isolation
        // Expected:
        // isolate_led = 1
        // relay_trip = 1
        // charging_enable = 0
        // risk_score = 100
        // pls_mode = 11
        // ----------------------------------------------------
        run_test_case(
            2'b11,
            "MODE 11: SEVERE ATTACK / ISOLATION",
            1'b0,    // normal_led
            1'b0,    // secure_led
            1'b0,    // alarm_led
            1'b1,    // isolate_led
            1'b1,    // relay_trip
            1'b0,    // charging_enable
            8'd100,  // risk_score
            3'd4,    // decision_code
            2'b11    // pls_mode
        );

        // ----------------------------------------------------
        // Final Result
        // ----------------------------------------------------
        $display("==================================================");

        if (error_count == 0) begin
            $display("ALL TEST CASES PASSED SUCCESSFULLY.");
        end
        else begin
            $display("TESTBENCH COMPLETED WITH %0d ERROR(S).", error_count);
        end

        $display("==================================================");

        #20;
        $stop;
    end

endmodule
