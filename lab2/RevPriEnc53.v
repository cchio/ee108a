/* Module: RevPriEnc53
 *----------------------
 * Reverse Priority Encoder;
 * Finds the MS 1 of a and 
 * encodes it into binary,
 * starting from the left
 * (i.e. 10000 -> 000)*/

module RevPriEnc53(a,b);

input wire [4:0] a;
wire [4:0] one_hot;
output reg [2:0] b;

RArb arb(.r(a), .g(one_hot));

always @(*) begin

case(one-hot)
	5'b10000: b = 3'b000;
	5'b01000: b = 3'b001;
	5'b00100: b = 3'b010;
	5'b00010: b = 3'b011;
	5'b00001: b = 3'b100;
	5'b00000: b = 3'b000;
	default: b = 3'b111;
endcase
end
endmodule