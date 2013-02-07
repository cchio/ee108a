`timescale 1ns / 1ps

`define ONE = 4'b1000;
`define TWO = 4'b0100;
`define THREE = 4'b0010;
`define FOUR = 4'b0001;
`define BWIDTH = 3'b100;

module shifter_test( input wire shift_left,
		input wire shift_right,
		input fast,
		input clk,
		input reset,
		output wire [6:0] out);

//Current and next state
wire [3:0] state, result;
reg [3:0] next;

//Instantiate flipflop
dffr #(`BWIDTH) flipflop (.clk(clk), .r(reset), .d(result), .q(state));

endmodule
