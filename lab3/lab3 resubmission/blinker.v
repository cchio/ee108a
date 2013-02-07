// Lab 3: Bicycle Light
//
// This is the blinker module.
//
// Output inverts whenever its input goes high.

module blinker (
    	input blinker_switch,
	input clk,
	input reset,
    	output blinker_out
);  
	dffre blinker_ff(clk, reset, blinker_switch, ~blinker_out, blinker_out);

endmodule
