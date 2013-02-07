module chords(	input clk,
		input reset,
		input play,
		input [2:0] sw, // Our input from the DIP switches
		input [5:0] note,
		input [5:0] duration,
		input new_note,
		input beat,
		input generate_next_sample,
		output player_available,
		output reg [15:0] sample_out,
		output new_sample_ready
			//Output for compatibility with old song reader
			//	output done_with_note
);

wire player1_done;
wire player2_done;
wire player3_done;
reg [2:0] load1;
wire [2:0] load;
wire [15:0] sample1;
wire [15:0] sample2;
wire [15:0] sample3;
wire [5:0] note_to_load;
wire [5:0] duration_to_load;
wire signed [17:0] sum;

//Output for compatibility with old song reader
//assign done_with_note = player1_done;

dffr #(3) player_select(.clk(clk), .r(reset), .d(load1), .q(load));
//dffr #(6) notes(.clk(clk), .r(reset), .d(note), .q(note_to_load));
//dffr #(6) durations(.clk(clk), .r(reset), .d(duration), .q(duration_to_load));

//Debug
assign note_to_load = note;
assign duration_to_load = duration;

always @(*) begin
	if(player1_done) begin
		load1 = {new_note, 1'b0, 1'b0};
	end

	else if(player2_done) begin
		load1 = {1'b0, new_note, 1'b0};
	end

	else if(player3_done) begin
		load1 = {1'b0, 1'b0, new_note};
	end

	else begin
		//load1 = load;
		load1 = 3'b0;
	end

end

//Weighting
//This is just an average, but to make computation more quick and simple, we divide by four
//instead of three
wire signed [17:0] s1_ext;
wire signed [17:0] s2_ext;
wire signed [17:0] s3_ext;

assign s1_ext = {sample1, 2'b0};
assign s2_ext = {sample2, 2'b0};
assign s3_ext = {sample3, 2'b0};

assign sum = (s1_ext >>> 2) + (s2_ext >>> 2) + (s3_ext >>> 2);

always @(*) begin
	//All three playing: divide by 4
	if( ~(player1_done & player2_done & player3_done) )
		sample_out = sum[17:2];

	//Two playing: divide by two
	else if( ~((player1_done & player2_done) | (player1_done & player3_done) | (player3_done & player2_done)) )
		sample_out = sum[16:1];

	//One or 0 playing: no need to divide
	else
		sample_out = sum[15:0];
end

//Note player instantiations
ROM_note_player_ext player1(
        .clk(clk),
        .reset(reset),
        .play_enable(play),
	.voice(sw[0]),
        .note_to_load(note_to_load),
        .duration_to_load(duration_to_load),
        .load_new_note(load[2]),
        .done_with_note(player1_done),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(sample1),
        .new_sample_ready()
    );

ROM_note_player_ext player2(
        .clk(clk),
        .reset(reset),
        .play_enable(play),
	.voice(sw[1]),
        .note_to_load(note_to_load),
        .duration_to_load(duration_to_load),
        .load_new_note(load[1]),
        .done_with_note(player2_done),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(sample2),
        .new_sample_ready()
    );

ROM_note_player_ext player3(
        .clk(clk),
        .reset(reset),
        .play_enable(play),
	.voice(sw[2]),
        .note_to_load(note_to_load),
        .duration_to_load(duration_to_load),
        .load_new_note(load[0]),
        .done_with_note(player3_done),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(sample3),
        .new_sample_ready(new_sample_ready)
    );

//When a player is available
assign player_available = player1_done | player2_done | player3_done;

endmodule
