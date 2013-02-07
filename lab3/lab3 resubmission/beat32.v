`timescale 1ns / 1ps

`define HIGH  22'd3124999
`define STARTOVER 22'd0

module beat32(  input clk,
		input reset,
		output reg count_en);
wire [21:0] counter;
reg [21:0] next;

dffr #(.WIDTH(22)) flip(.clk(clk), .r(reset), .d(next), .q(counter));

always @(*) begin
if (reset) begin
count_en = 1'b0;
next = `STARTOVER;
end

else if ((counter == `HIGH) & ~reset) begin
count_en = 1'b1;
next = `STARTOVER;
end

else if (~reset) begin
count_en = 1'b0;
next = next + 22'd1;
end

else begin
count_en = 1'b0;
next = `STARTOVER;
end
end

endmodule
