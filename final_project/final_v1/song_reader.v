
`define WAIT1 3'b000
`define READ 3'b001
`define WAIT2 3'b010
`define SEND 3'b011
`define WAIT3 3'b100

module song_reader(  	input clk,
			input reset,
			input play,
			input wire [1:0] song, 
			input note_done,
			output song_done,
			output wire [5:0] note,
			output [5:0] duration,
			output new_note);
wire [2:0] next;
reg [2:0] next1;
wire [2:0] state;
wire [6:0] address;
reg [4:0] next_add;
wire [11:0] rom_out;
wire [4:0] addr;
reg ready;
reg done;

assign address = {song, addr};

//Whether the player is on or off
//dffr is_on ( .clk(clk), .r(reset), .d(play), .q(on));

//The address at which the song reader is reading
dffr #(3'd5) address_value ( .clk(clk), .r(reset), .d(next_add), .q(addr));

//The state of the song reader
dffr #(2'b11) reader_state( .clk(clk), .r(reset), .d(next), .q(state));

//All the song options
song_rom songs( .clk(clk), .addr(address), .dout(rom_out));

always @(*) begin

//if(play)
	case(state)
		`WAIT1: begin
				next1 = `SEND;
				next_add = addr;
				ready = 0;//1;
				done = 0;
			end

		`READ: begin    //If the last address of the song has been read
				next_add = addr + 5'b1;
				if(addr == 5'b11111) 
				//if(next_add == 5'b11111) 
					done = 1;
				else
					done = 0;

				
				next1 = `WAIT2;
				//ready = 1;
				ready = 0;
			end

		`WAIT2: begin
				next1 = play ? `SEND : `WAIT2;
				next_add = addr;
				ready = 0;
				done = 0;
			end

		`SEND:  begin	
				done = 0;
				next1 = `WAIT3;
				next_add = addr;
				/*if(addr == 5'b00000)
					ready = 0;
				else*/
					ready = 1;
			end

		`WAIT3: begin
				if(note_done) next1 = `READ;
				else next1 = `WAIT3;

				next_add = addr;
				ready = 0;
				done = 0;
			end

		default: begin
				next1 = state;
				next_add = addr;
				ready = 0;
				done = 0;
			end
	endcase

/*else begin
	next1 = state;
	next_add1 = address;
	ready = 0;
	done = 0;
end*/

end

assign {note, duration} = rom_out;

assign next = reset ? `WAIT1 : next1;
//assign next_add = reset ? 5'b0 : next_add1;

//Debug
//assign next_add = reset ? 5'b11101 : next_add1;

assign new_note = /*reset ? 1'b0 :*/ ready;
assign song_done = /*reset ? 1'b0 :*/ done;

endmodule
