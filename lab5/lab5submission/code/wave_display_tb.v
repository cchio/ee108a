//`timescale 1ns / 1ps

module wave_display_tb();
reg clk_sim;
reg rst_sim, valid_sim, read_index_sim;
wire [10:0] x_sim;
wire [9:0] y_sim;
wire [7:0] read_value_sim;
wire [8:0] read_address_sim;
wire valid_pixel_sim;
wire [7:0] r_sim;
wire [7:0] g_sim;
wire [7:0] b_sim;
wire chip_vsync;

wave_display display(   .clk(clk_sim), .reset(rst_sim), .x(x_sim), .y(y_sim), .valid(valid_sim), .read_index(read_index_sim), .read_value(read_value_sim), .read_address(read_address_sim), .valid_pixel(valid_pixel_sim), .r(r_sim), .g(g_sim), .b(b_sim));

dvi_controller_top dvi(.clk(clk_sim), .enable(1'b1), .reset(rst_sim), .r(r_sim), .g(g_sim), .b(b_sim), .x(x_sim), .y(y_sim), .chip_vsync(chip_vsync));

fake_sample_ram RAM(.clk(clk_sim), .addr(read_address_sim), .dout(read_value_sim));

//Clock simulator
initial begin
	clk_sim = 1'b0;
	forever #2 clk_sim = ~clk_sim;

	
end

initial begin

	//Reset
	rst_sim = 1'b1;
	#4;
	rst_sim = 1'b0;
	#4;

	//Assume valid VGA
	valid_sim = 1'b1;
	//Read from the top
	read_index_sim = 1'b0;

	#36
	
	@(negedge chip_vsync)
	#100

	$finish;
end





/*initial @(negedge chip_vsync) begin

//Initialize variables
valid_sim = 1'b1;
//read_value_sim = 8'b0;

//Draw a straight, horizontal line
//read_value_sim = 8'd100;
//read_value_sim = 8'b11111111;

#12
/*
for(y = 10'b0; y <= 10'd1023; y = y + 10'b1) begin
	for(x = 11'b0; y <= 11'd1023; y = y + 11'b1) begin
		x_sim = x;
		y_sim = y;
		#4
	end
end


$finish;
end*/

endmodule
