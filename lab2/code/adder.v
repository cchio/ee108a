/* Module: adder
 * ----------------------
 * Adds two 5-bit numbers, 
 * a and b, and outputs the
 * sum, amount of shifting
 * required to move the sum
 * in such a way that the MS
 * 1 is in the MSB, and the
 * direction of that shift. */

module adder(input wire [4:0] a, b,
	     //output reg [2:0] shift,
	     output wire dir,
	     output reg [4:0] sum);

wire [5:0] a_ext, b_ext, full_sum;
//wire [2:0] shifted;

//Account for the possibility of overflow during addition
assign a_ext = {1'b0, a};
assign b_ext = {1'b0, b};

assign full_sum = a_ext + b_ext;

assign dir = full_sum[5];
//RevPriEnc53 rev(sum, shifted);

always @(*)
begin
	//If there was overflow
	if(dir) begin
		//shift = 3'b001;
		sum = full_sum[5:1];
	end

	else begin
		//Find the most significant 1 and the distance   <----Disregard this comment
		//required to shift it to be the MSB of the sum
		
		sum = full_sum[4:0];
		//shift = shifted;
		
	end

end

endmodule
