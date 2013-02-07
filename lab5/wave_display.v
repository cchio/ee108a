module wave_display(
    	input clk,
  	input reset,
	input [10:0] x,
	input [9:0] y,
	input valid,
	input read_index,
	input [7:0] read_value,
	output [8:0] read_address,
	output valid_pixel,
	output [7:0] r,
	output [7:0] g,
	output [7:0] b
);

reg area_is_valid;
wire [7:0] short_y;
assign short_y = y[8:1];

//RAM Flipflop
wire [7:0] ram_prev;
dffr #(4'd8) ram_value_ff(.clk(clk), .r(reset), .d(read_value), .q(ram_prev));

//Y flipflop
wire [7:0] y_curr;
dffr #(4'd8) y_ff(.clk(clk), .r(reset), .d(short_y), .q(y_curr));

//Check to make sure the area is valid
always @ (*) begin
	
	if ((x[10:8] == 3'b000) || (x[10:8] >= 3'b011) ||
	    ~valid || y[9]) 
		area_is_valid = 1'b0;

	else
		area_is_valid = 1'b1;

end //always @ (*)

//Set address
wire right_side;
assign right_side = (x[10:8] == 3'b010);
assign read_address = {read_index, right_side, x[7:1]};

//Comparison logic

reg point_is_valid;

always @(*) begin

	if(x <= 11'b00100000001)
		point_is_valid = 0; //Check this with the TAs

	else begin
		if(ram_prev > read_value) begin //going up
			//if( (ram_prev >= y_curr) && (read_value <= y_curr) )
			if( (ram_prev > y_curr) && (read_value <= y_curr) )
				point_is_valid = 1'b1;
			else
				point_is_valid = 1'b0;
		end

		else if (( ram_prev == y_curr) && (read_value == y_curr) )
			point_is_valid = 1'b1;

		else begin //going down
			//if( (ram_prev < y_curr) && (read_value > y_curr) )
			if( (ram_prev < y_curr) && (read_value >= y_curr) )
				point_is_valid = 1'b1;
			else
				point_is_valid = 1'b0;
		end
	end
end

//Assign outputs
assign valid_pixel = point_is_valid && area_is_valid;
assign r = valid_pixel ? 8'hFF : 8'h0;
assign g = valid_pixel ? 8'hFF : 8'h0;
assign b = valid_pixel ? 8'hFF : 8'h0;

endmodule
