
`define WAIT1 3'b000
`define READ 3'b001
`define WAIT2 3'b010
`define SEND 3'b011
`define WAIT3 3'b100

module song_reader(  	
			input clk,
			input reset,
			input play,
			input wire [1:0] song, 
			input note_done,
			output song_done,
			output wire [5:0] note,
			output [5:0] duration,
			output new_note);

wire on;

wire [2:0] next;
reg [2:0] next1;
wire [2:0] state;
wire [6:0] address;
wire [4:0] next_add;
reg [4:0] next_add1;
wire [11:0] rom_out;
wire [4:0] addr;
reg ready;
reg done;

assign address = {song, addr};

//Whether the player is on or off
dffr is_on ( .clk(clk), .r(reset), .d(play), .q(on));

//The address at which the song reader is reading
dffr #(3'd5) address_value ( .clk(clk), .r(reset), .d(next_add), .q(addr));

//The state of the song reader
dffr #(2'b11) reader_state( .clk(clk), .r(reset), .d(next), .q(state));

//All the song options
song_rom songs( .clk(clk), .addr(address), .dout(rom_out));

always @(*) begin

if(on)
	case(state)
		`WAIT1: begin
				next1 = `READ;
				next_add1 = addr;
				ready = 0;
				done = 0;
			end

		`READ: begin    //If the last address of the song has been read
				if(next_add1 == 5'b11111) 
					done = 1;
				else
					done = 0;

				next_add1 = addr + 5'b1;
				next1 = `WAIT2;
				ready = 0;
			end

		`WAIT2: begin
				next1 = `SEND;
				next_add1 = addr;
				ready = 1;
				done = 0;
			end

		`SEND:  begin	//If the song had fewer than 32 notes and ended
				if(rom_out == 12'b0) 
					done = 1;
				else 
					done = 0;

				next1 = `WAIT3;
				next_add1 = addr;
				ready = 0;
				
			end

		`WAIT3: begin
				if(note_done) next1 = `READ;
				else next1 = `WAIT3;

				next_add1 = addr;
				ready = 0;
				done = 0;
			end

		default: begin
				next1 = next;
				next_add1 = addr;
				ready = 0;
				done = 0;
			end
	endcase

else begin
	next1 = next;
	next_add1 = address;
	ready = 0;
	done = 0;
end

end

assign {note, duration} = rom_out;

assign next = reset ? `WAIT1 : next1;
assign next_add = reset ? 5'b0 : next_add1;
assign new_note = reset ? 1'b0 : ready;
assign song_done = reset ? 1'b0 : done;

endmodule
