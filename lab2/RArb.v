/* Module: RArb
 * ------------------
 * Function: Returns a
 * one hot signal(g) with 
 * the most significant 1 
 * of r.

module RArb(r, g);

parameter n = 5;
input [n-1:0] r;
output [n-1:0] g;

wire [n-1:0] c = {1'b1, (~r[n-1:1] & c[n-1:1])};
assign g = r & c;

endmodule