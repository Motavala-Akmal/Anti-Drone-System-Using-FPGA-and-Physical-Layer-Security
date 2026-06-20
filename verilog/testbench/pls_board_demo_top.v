`timescale 1ns / 1ps

module tb_pls_board_demo_top;

reg clk;
reg rst;
reg [1:0] mode_select;

wire normal_led;
wire secure_led;
wire alarm_led;
wire isolate_led;
wire relay_trip;
wire charging_enable;

// ======================================================
// Instantiate Board-Level Top Module
// ======================================================

pls_board_demo_top DUT (
    .clk(clk),
    .rst(rst),
    .mode_select(mode_select),
    .normal_led(normal_led),
    .secure_led(secure_led),
    .alarm_led(alarm_led),
    .isolate_led(isolate_led),
    .relay_trip(relay_trip),
    .charging_enable(charging_enable)
);

// ======================================================
// Clock Generation: 100 MHz
// ======================================================

always #5 clk = ~clk;

// ======================================================
// Test Stimulus
// ======================================================

initial begin

    clk = 0;
    rst = 1;
    mode_select = 2'b00;

    #20;
    rst = 0;

    // Mode 00: Normal condition
    mode_select = 2'b00;
    #100;

    // Mode 01: Weak secrecy condition
    mode_select = 2'b01;
    #100;

    // Mode 10: Attack condition
    mode_select = 2'b10;
    #100;

    // Mode 11: Repeated severe attack condition
    mode_select = 2'b11;
    #100;

    // Reset check
    rst = 1;
    #20;
    rst = 0;

    mode_select = 2'b00;
    #100;

    $stop;

end

endmodule
