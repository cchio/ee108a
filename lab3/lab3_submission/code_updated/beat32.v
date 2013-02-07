`timescale 1ns / 1ps

`define HI  22'd3124999
// debugging value for HIGH
//`define HI 22'd2
`define STARTOVER 22'd0

module beat32(  input clk,
		input reset,
		output wire count_en);
wire [21:0] counter;
reg count_en1;
reg [21:0] next;

dffr #(.WIDTH(22)) flip(.clk(clk), .r(reset), .d(next), .q(counter));

always @(*) begin
if (reset) begin
count_en1 = 1'b0;
next = `STARTOVER;
end

else if ((counter == `HI) & ~reset) begin
count_en1 = 1'b1;
next = `STARTOVER;
end

else begin
count_en1 = 1'b0;
next = counter + 22'd1;
end

/*else begin
count_en = 1'b0;
next = `STARTOVER;
end*/
end

//Handle resets
assign count_en = reset ? 1'b0 : count_en1;

endmodule
