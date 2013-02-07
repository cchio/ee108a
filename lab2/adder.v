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
	     output reg [2:0] shift,
	     output wire dir
	     output reg [4:0] sum);

wire [5:0] a_ext, b_ext, full_sum;

//Account for the possibility of overflow during addition
assign a_ext = {1'b0, a};
assign b_ext = {1'b0, b};

assign full_sum = a_ext + b_ext;

assign dir = full_sum[5];

always @(*)
begin
	//If there was overflow
	if(dir) begin
		assign shift = 3'b001;
		assign sum = full_sum[5:1];
	end

	else
		//Find the most significant 1 and the distance
		//required to shift it to be the MSB of the sum
		
		assign sum = full_sum[4:0];
		RevPriEnc53 rev(sum, shift);
	end

end

endmodule