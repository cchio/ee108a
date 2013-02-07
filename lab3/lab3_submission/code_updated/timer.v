// Lab 3: Bicycle Light
//
// This is the timer module.
//
// Stores a counter value loaded in from the load_value input and decreases it by 1
// every time the count_en input (fed in from beat32) goes high. When the counter reaches
// 0, pulse the output for a cycle and reloads the counter from load_value.
//
// load_value needs to be 9 bit to store counts of up to 256, since the max number of 
// count decrements we are making is for 8 seconds, with one decrement every 1/32nd of
// a second. 8 * 32 = 256

`define COUNTER_WIDTH 9

module timer (
    input [8:0] load_value,
    input count_en,
    input clk,
    input reset,
    output reg timer_out
);  
	
	reg [8:0] counter_in;
	wire [8:0] counter_out;
	
	dffr #(`COUNTER_WIDTH) timer_ff(.clk(clk), .r(reset), .d(counter_in), .q(counter_out));
	
	always @ (*) begin
		//if(reset) begin
		//counter_in = `ONE;
		//end

		if(counter_out > 0) begin
			timer_out = 1'b0;
			counter_in = count_en ? counter_out - 1'b1 : counter_out;
		end

		else begin
			timer_out = 1'b1;
			counter_in = load_value; //loading the next load_value
		end

	end // always @ (*)
	
endmodule
