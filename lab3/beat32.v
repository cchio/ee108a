`timescale 1ns / 1ps

//`define HIGH  22'd3125000
// debugging value for HIGH
`define HIGH 22'd10
`define STARTOVER 22'd0

module beat32(  input clk,
		input reset,
		output wire count_en);
wire [21:0] counter;
reg count_en1;
reg [21:0] next1;

dffr #(.WIDTH(22)) flip(.clk(clk), .r(reset), .d(next1), .q(counter));

always @(*) begin
if (reset) begin
count_en1 = 1'b0;
next1 = `STARTOVER;
end

else if (counter == `HIGH) begin
count_en1 = 1'b1;
next1 = `STARTOVER;
end

else begin
count_en1 = 1'b0;
next1 = next1 + 1;
end
end

// Handle resets
assign count_en = reset ? 1'b0 : count_en1;

endmodule
