
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
wire [3:0] next, state;
reg [3:0] next1;
wire shiftedState, shiftedIn;
reg shiftedIn1;

//Instantiate flipflops
dffr #(`BWIDTH) flipflop (.clk(clk), .r(reset), .d(next), .q(state));
dffr shifted(.clk(clk), .r(reset), .d(shiftedIn), .q(shiftedState));

always @(*) begin
	if (shift_left & ~shiftedState) begin//shift_left & ~shifted) begin
		next1 = (state != `ONE) ? (state << 1) : `ONE;
		shiftedIn1 = 1;
	end

	else if (shift_right & ~shiftedState) begin// & ~shifted) begin
		next1 = (state != `FOUR)  ? (state >> 1) : `FOUR;
		shiftedIn1 = 1;
	end

	else begin 
		next1 = next;
		shiftedIn1 = 0;	
	end
end

// Handle reset
assign next = reset ? `ONE : next1;

assign shiftedIn = reset ? 0 : shiftedIn1;

//Distinguish between fast and slow (flip if slow)
assign out = fast ? {3'b000, state} : {state[0], state[1], state[2], state[3], 3'b000};

endmodule
