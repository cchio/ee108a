`timescale 1ns / 1ps

module piano_voice_tb ();

reg clk_sim;
reg rst_sim;
reg gen_sim;
reg [19:0] freq_sim;
wire rdy_sim;
wire [15:0] samp_sim;

piano_voice pv (.clk(clk_sim), .reset(rst_sim), .generate_next(gen_sim), .freq(freq_sim), .sample_ready(rdy_sim), .sample(samp_sim));
		 
initial begin
	clk_sim = 1'b0;
	forever begin 
		#2 clk_sim = ~clk_sim;
	end
end 

initial begin	
	gen_sim = 0;
	freq_sim = 20'b0;

	//Reset
	rst_sim = 1'b1;
	#4
	rst_sim = 1'b0;
	#4

	//Test 0 input case
	gen_sim = 1;
	#4
	gen_sim = 0;
	
	#8	
	
	//Test input with all harmonics within bounds
	#4 freq_sim = {10'd018, 10'd791};
	#4
	
	gen_sim = 1;
	#4
	gen_sim = 0;
	
	#8
	
	//Test input with some harmonics out of bounds
	#4 freq_sim = {10'd178, 10'd879};
	#4
	
	gen_sim = 1;
	#4
	gen_sim = 0;
	
	#8
	
	//Test input with highest-frequency note
	#4 freq_sim = {10'd337, 10'd942};
	#4
	
	gen_sim = 1;
	#4
	gen_sim = 0;
	
	#8
	
	$finish;
	
end

endmodule
