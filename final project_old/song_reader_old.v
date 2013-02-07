
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
			input note1_done,
			input note2_done,
			input note3_done,
			output song_done,
			output wire [5:0] note1,
			output wire [5:0] note2,
			output wire [5:0] note3,
			output [5:0] duration1,
			output [5:0] duration2,
			output [5:0] duration3,
			output new_note1
			output new_note2
			output new_note3);

wire on;


wire [2:0] next1;
reg [2:0] next1_reg;
wire [6:0] address1;
wire [4:0] next1_add;
reg [4:0] next1_add_reg;
wire [11:0] rom1_out;
wire [4:0] addr1;

wire [2:0] next2;
reg [2:0] next2_reg;
wire [6:0] address2;
wire [4:0] next2_add;
reg [4:0] next2_add_reg;
wire [11:0] rom2_out;
wire [4:0] addr2;

wire [2:0] next3;
reg [2:0] next3_reg;
wire [6:0] address3;
wire [4:0] next3_add;
reg [4:0] next3_add_reg;
wire [11:0] rom3_out;
wire [4:0] addr3;

wire [2:0] state;

reg ready;
reg done;

assign address1 = {song, addr1};
assign address2 = {song, addr2};
assign address3 = {song, addr3};

//Whether the player is on or off
dffr is_on ( .clk(clk), .r(reset), .d(play), .q(on));

//The address (note1) at which the song reader is reading
dffr #(3'd5) address1_value ( .clk(clk), .r(reset), .d(next1_add), .q(addr1));

//The address (note2) at which the song reader is reading
dffr #(3'd5) address2_value ( .clk(clk), .r(reset), .d(next2_add), .q(addr2));

//The address (note3) at which the song reader is reading
dffr #(3'd5) address3_value ( .clk(clk), .r(reset), .d(next3_add), .q(addr3));

//The state of the song reader
dffr #(2'b11) reader_state( .clk(clk), .r(reset), .d(next), .q(state));

//All the song options (note1)
song_rom songs( .clk(clk), .addr(address1), .dout(rom1_out));

//All the song options (note2)
song_rom songs( .clk(clk), .addr(address2), .dout(rom2_out));

//All the song options (note3)
song_rom songs( .clk(clk), .addr(address3), .dout(rom3_out));

always @(*) begin

if(on)
	case(state)
		`WAIT1: begin
				next1_reg = `READ;
				next1_add_reg = addr1;
				next2_reg = `READ;
				next2_add_reg = addr2;
				next3_reg = `READ;
				next3_add_reg = addr3;
				ready = 0;
				done = 0;
			end

		`READ: begin    //If the last address of the song has been read (should only need this for one of the notes, 
						//since we should standardize that all notes for a song should be same length)
				if(next1_add_reg == 5'b11111) 
					done = 1;
				else
					done = 0;

				next1_add_reg = addr1 + 5'b1;
				next1_reg = `WAIT2;
				next2_add_reg = addr2 + 5'b1;
				next2_reg = `WAIT2;
				next3_add_reg = addr3 + 5'b1;
				next3_reg = `WAIT2;
				ready = 0;
			end

		`WAIT2: begin
				next1_reg = `SEND;
				next1_add_reg = addr1;
				next2_reg = `SEND;
				next2_add_reg = addr2;
				next3_reg = `SEND;
				next3_add_reg = addr3;
				ready = 1;
				done = 0;
			end

		`SEND:  begin	//If the song had fewer than 32 notes and ended (should only need this for one of the notes, 
						//since we should standardize that all notes for a song should be same length)
				if(rom1_out == 12'b0) 
					done = 1;
				else 
					done = 0;

				next1_reg = `WAIT3;
				next1_add_reg = addr1;
				next2_reg = `WAIT3;
				next2_add_reg = addr2;
				next3_reg = `WAIT3;
				next3_add_reg = addr3;
				ready = 0;
				
			end

		`WAIT3: begin
				if(note1_done) next1_reg = `READ;
				else next1_reg = `WAIT3;
				next1_add_reg = addr1;
				
				if(note2_done) next2_reg = `READ;
				else next2_reg = `WAIT3;
				next2_add_reg = addr2;
				
				if(note3_done) next3_reg = `READ;
				else next3_reg = `WAIT3;
				next3_add_reg = addr3;
				
				ready = 0;
				done = 0;
			end

		default: begin
				next1_reg = next1;
				next1_add_reg = addr1;
				next2_reg = next2;
				next2_add_reg = addr2;
				next3_reg = next3;
				next3_add_reg = addr3;
				ready = 0;
				done = 0;
			end
	endcase

else begin
	next1_reg = next1;
	next1_add_reg = address1;
	next2_reg = next2;
	next2_add_reg = address2;
	next3_reg = next3;
	next3_add_reg = address3;
	
	ready = 0;
	done = 0;
end

end

assign {note1, duration1} = rom1_out;
end

assign {note2, duration2} = rom2_out;
end

assign {note3, duration3} = rom3_out;

assign next1 = reset ? `WAIT1 : next1_reg;
assign next1_add = reset ? 5'b0 : next1_add_reg;
assign new_note1 = reset ? 1'b0 : ready;

assign next2 = reset ? `WAIT1 : next2_reg;
assign next2_add = reset ? 5'b0 : next2_add_reg;
assign new_note2 = reset ? 1'b0 : ready;

assign next3 = reset ? `WAIT1 : next3_reg;
assign next3_add = reset ? 5'b0 : next3_add_reg;
assign new_note3 = reset ? 1'b0 : ready;

assign song_done = reset ? 1'b0 : done;

endmodule
