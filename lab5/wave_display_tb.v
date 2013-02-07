`timescale 1ns / 1ps

module wave_display_tb();
reg clk_sim;
reg rst_sim, valid_sim, read_index_sim;
reg [10:0] x_sim;
reg [9:0] y_sim;
reg [7:0] read_value_sim;
wire [8:0] read_address_sim;
wire valid_pixel_sim;
wire [7:0] r_sim;
wire [7:0] g_sim;
wire [7:0] b_sim;

wave_display display(   .clk(clk_sim), .reset(rst_sim), .x(x_sim), .y(y_sim), 
		.valid(valid_sim), .read_index(read_index_sim), 
		.read_value(read_value_sim), .read_address(read_address_sim), 
		.valid_pixel(valid_pixel_sim), .r(r_sim), .b(b_sim), .g(g_sim));

dvi_controller_top dvi(.clk(clk), .enable(1'b1), .reset(rst_sim), .r(r_sim), .g(g_sim), .b(b_sim), .x(x_sim), .y(y_sim));

fake_sample_ram(.clk(clk), .addr(read_address_sim), .dout(read_value_sim));

//Clock simulator
initial begin
	clk_sim = 1'b0;
	forever #2 clk_sim = ~clk_sim;

	//Reset
	rst_sim = 1'b1;
	#4;
	rst_sim = 1'b0;
	#4;
end

initial begin

//Initialize variables
valid_sim = 1'b1;
x_sim = 11'b00100000000;
y_sim = 11'b0;
read_value_sim = 8'b0;

//Draw a straight, horizontal line
//read_value = 8'd100;

read_value = 8'b11111111;

#12
/*
for(y = 10'b0; y <= 10'd1023; y = y + 10'b1) begin
	for(x = 11'b0; y <= 11'd1023; y = y + 11'b1) begin
		x_sim = x;
		y_sim = y;
		#4
	end
end
*/

$finish;
end

endmodule
