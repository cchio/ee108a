module beat32_tb();
reg clk;
reg reset;
wire hbeat;
reg [15:0] curTime;

beat32 bt(.clk(clk), .reset(reset), .count_en(hbeat));

initial begin

$monitor("time %d, reset %b, beat %b", curTime, reset, hbeat);


reset = 1'b1;
#10;
reset = 1'b0;
#10;

#110;
reset = 1'b1;
#30;
$finish;
end

initial begin
clk = 1'b0;
curTime = 16'b0;

forever begin
#1 clk = ~clk;
curTime = curTime + 16'd1;
end
end

endmodule
