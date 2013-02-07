
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
			input beat, //BEAT!
			output song_done, //goes to mcu
			output wire [5:0] note, //note pushed out to chords.v
			output [5:0] duration,
			output new_note);

wire on;

wire [2:0] next;
reg [2:0] next_reg;
wire [2:0] state;
wire [8:0] address;
wire [6:0] next_add;
reg [6:0] next_add_reg;
wire [12:0] rom_out;
wire [6:0] addr;
reg ready;
reg done;

wire advance;

wire [5:0] timer_duration;
wire timer_done;
reg load_new_duration;

assign address = {song, addr};

//Whether the player is on or off
dffr is_on ( .clk(clk), .r(reset), .d(play), .q(on));

//The address at which the song reader is reading
dffr #(3'd7) address_value ( .clk(clk), .r(reset), .d(next_add), .q(addr));

//The state of the song reader
dffr #(2'b11) reader_state( .clk(clk), .r(reset), .d(next), .q(state));

//Timer for advance times
duration_timer2 timer(.clk(clk), .reset(reset), .beat(beat), .pause(~play), 
		.load_new_duration(load_new_duration), 
		.duration(timer_duration), .done(timer_done));

//All the song options
song_rom songs( .clk(clk), .addr(address), .dout(rom_out));

always @(*) begin

if(on)
	case(state)
		`WAIT1: begin
				next_reg = `READ;
				next_add_reg = addr;
				ready = 0;
				done = 1;
				load_new_duration = 0;
			end

		`READ: begin   
				if(next_add_reg == 7'b1111111)  //If the last address of the song has been read
					done = 1;
				else
					done = 0;

				next_add_reg = addr + 7'b1;
				next_reg = `WAIT2;
				ready = 0;
				load_new_duration = 0;
				
			end

		`WAIT2: begin
				next_reg = `SEND;
				next_add_reg = addr;
				ready = 1;
				done = 0;
				load_new_duration = 0;
			end

		`SEND:  begin	//If the song had fewer than 32 notes and ended
				if(rom_out == 13'b0) 
					done = 1;
				else 
					done = 0;
					
				if(advance == 1'b1)
					load_new_duration = 1;
			 	else
					load_new_duration = 0;
				
				next_reg = `WAIT3;
				next_add_reg = addr;
				ready = 0;
				
			end

		`WAIT3: begin
				if(timer_done) 
					next_reg = `READ;
				else 
					next_reg = `WAIT3;
				
				load_new_duration = 0;
				
				next_add_reg = addr;
				ready = 0;
				done = 0;
			end

		default: begin
				load_new_duration = 0;
				next_reg = next;
				next_add_reg = addr;
				ready = 0;
				done = 0;
			end
	endcase

else begin
	next_reg = next;
	next_add_reg = address;
	ready = 0;
	done = 0;
	load_new_duration = 0;
end

end



assign {advance, note, duration} = rom_out;

assign next = reset ? `WAIT1 : next_reg;
assign next_add = reset ? 5'b0 : next_add_reg;
assign new_note = reset ? 1'b0 : ready;
assign song_done = reset ? 1'b0 : done;
assign timer_duration = reset ? 6'b0 : duration;

endmodule
