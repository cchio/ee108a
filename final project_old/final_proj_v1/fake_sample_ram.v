/*
 * A simple fake RAM that you can use to aid in debugging your wave display.
 */
module fake_sample_ram (
    input clk,
    input [8:0] addr,
    output reg [7:0] dout
);

    always @(posedge clk) begin
	if(addr < 9'd32)
	        dout = addr[7:0];
	else if(addr < 9'd64)
		dout = 8'd32;
	else if(addr < 9'd96)
		dout = 8'd96 - addr[7:0];
	else if(addr < 9'd32 + 9'd96)
	        dout = addr[7:0] - 9'd96;
	else if(addr < 9'd64 + 9'd96)
		dout = 8'd32;
	else if(addr < 9'd96 + 9'd96)
		dout = 8'd96 + 9'd96 - addr[7:0];
	else 
		dout = 8'd0;
    end

endmodule
