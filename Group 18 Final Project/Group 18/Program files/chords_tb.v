`timescale 1ns/1ps

module chords_tb();

reg clk_sim; 
reg reset_sim;
reg play_sim;
reg [5:0] note_sim; 
reg [5:0] duration_sim;
reg new_note_sim;
reg beat_sim;
reg gen_next_sim;
wire [15:0] sample_out_sim;
wire samp_rdy_sim;

chords c(	.clk(clk_sim), 
	.reset(reset_sim),
	.play(play_sim),
	.note(note_sim), 
	.duration(duration_sim),
	.new_note(new_note_sim),
	.beat(beat_sim),
	.generate_next_sample(gen_next_sim),
	.sample_out(sample_out_sim),
	.new_sample_ready(samp_rdy_sim));

//Initialize clock				
initial begin
	clk_sim = 1'b0;
	forever #2 clk_sim = ~clk_sim;
end

//Initialize beat
initial begin
	beat_sim = 1'b0;
	forever begin
		#96 beat_sim = 1'b1;
		#4 beat_sim = 1'b0;
	end
end

initial begin
	gen_next_sim = 1'b0;
	#6
	forever begin
		#28 gen_next_sim = 1'b1;
		#4 gen_next_sim = 1'b0;
	end
		
end

initial begin
	#2
	//Initialize values
	play_sim = 1'b1;
	note_sim = 6'b0;
	duration_sim = 6'b0;
	new_note_sim = 1'b0;
	//gen_next_sim = 1'b0;
	
	//Reset the system
	reset_sim = 1'b1;
	#4
	reset_sim = 1'b0;
	
	//Input a note and let it finish
		note_sim = 6'd37;
		duration_sim = 6'd4;
		new_note_sim = 1'b1;
		#4
		new_note_sim = 1'b0;
		
		#500
	
	//Input two notes and let them finish
		note_sim = 6'd37; //A4
		duration_sim = 6'd4;
		new_note_sim = 1'b1;
		#4
		new_note_sim = 1'b0;
		#4
		
		note_sim = 6'd41; //C#4
		duration_sim = 6'd4;
		new_note_sim = 1'b1;
		#4
		new_note_sim = 1'b0;
		
		#500
	
	//Input three notes and let them finish
	
		note_sim = 6'd37; //A4
		duration_sim = 6'd4;
		new_note_sim = 1'b1;
		#4
		new_note_sim = 1'b0;
		#4
		note_sim = 6'd41; //C#4
		duration_sim = 6'd4;
		new_note_sim = 1'b1;
		#4
		new_note_sim = 1'b0;
		#4
		note_sim = 6'd44; //E4
		duration_sim = 6'd4;
		new_note_sim = 1'b1;
		#4
		new_note_sim = 1'b0;
		
		#470
	
	//Input three notes in sequence (instead of at the same time)
	
		note_sim = 6'd37; //A4
		duration_sim = 6'd4;
		new_note_sim = 1'b1;
		#4
		new_note_sim = 1'b0;
		
		#100
		
		note_sim = 6'd41; //C#4
		duration_sim = 6'd4;
		new_note_sim = 1'b1;
		#4
		new_note_sim = 1'b0;
		
		#100
		
		note_sim = 6'd44; //E4
		duration_sim = 6'd4;
		new_note_sim = 1'b1;
		#4
		new_note_sim = 1'b0;
		
		#500
	
	$finish;
end
endmodule
