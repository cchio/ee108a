
`define ONE 4'b1000
`define TWO 4'b0100
`define THREE 4'b0010
`define FOUR 4'b0001
`define BWIDTH 3'b100

module shifter( input wire shift_left,
		input wire shift_right,
		input fast,
		input clk,
		input reset,
		output wire [6:0] out);

//Current and next state
wire [3:0] state;
reg [3:0] next;
reg shifted;

//Instantiate flipflop
dffr #(`BWIDTH) flipflop (.clk(clk), .r(reset), .d(next), .q(state));

always @(*) begin
	if(reset) begin
		next = `ONE;
		shifted = 0;
	end

	else if(shift_left & ~shifted) begin
		next = (state != `ONE) ? (state << 1) : `ONE;
		shifted = 1;
	end

	else if(shift_right & ~shifted) begin
		next = (state != `FOUR)  ? (state >> 1) : `FOUR;
		shifted = 1;
	end

	else begin 
		next = next;	
		shifted = 0;	
	end	
end

//Distinguish between fast and slow (flip if slow)
assign out = fast ? {3'b000, state} : {state[0], state[1], state[2], state[3], 3'b000};

endmodule
