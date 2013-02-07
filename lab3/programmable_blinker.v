// Lab 3: Bicycle Light
//
// This is the programmable_blinker intermediate module.
//

module programmable_blinker (
    input shift_left, shift_right,
    input count_en, fast,
    input clk, reset,
    output programmable_blinker_out
);  
	wire [6:0] shifter_out;
	wire [8:0] load_value;
	wire timer_out;

	shifter shifter_instance(.shift_left(shift_left), .shift_right(shift_right), .fast(fast), .clk(clk), .reset(reset), .out(shifter_out));

	assign load_value = {shifter_out, 2'b00};
	
	timer timer_instance(.load_value(load_value), .count_en(count_en), .clk(clk), .reset(reset), .timer_out(timer_out));

	blinker blinker_instance(.blinker_switch(timer_out/*switch*/), .clk(clk), .reset(reset), .blinker_out(programmable_blinker_out)); 

	
endmodule
