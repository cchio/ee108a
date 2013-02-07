module mcu(
    input clk,
    input reset,
    input play_button,
    input next_button,
    output play,
    output reset_player,
    output [1:0] song,
    input song_done
);
	
	reg [1:0] next_song;
	reg not_play;
	reg reset_player_reg;
	
	assign reset_player = reset_player_reg;
	
	dffr #(.WIDTH(2)) songFlipFlop(.clk(clk), .r(reset), .d(next_song), .q(song));
	dffr playFlipFlop(.clk(clk), .r(reset), .d(not_play), .q(play));

	always @ (*) begin
	
		if(reset) begin
			not_play = 1'b0;
			next_song = 2'b00;
			reset_player_reg = 1'b1;
		end

		else if(play_button) begin 
			not_play = ~play;
			reset_player_reg = 1'b0;
			next_song = song;
		end
		
		else if(next_button) begin
			not_play = 1'b0;
			reset_player_reg = 1'b1;
			next_song = (song == 2'b11) ? 2'b00 : (song + 1);
		end
		
		else if(song_done) begin
			not_play = 1'b0;
			reset_player_reg = 1'b1;
			next_song = (song == 2'b11) ? 2'b00 : (song + 1);
		end
		
		else begin
			not_play = play;
			reset_player_reg = 1'b0;
			next_song = song;
		end

	end //always @ (*)

endmodule
