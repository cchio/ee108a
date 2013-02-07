module note_player_tb();

    reg clk, reset, play_enable, generate_next_sample;
    reg [5:0] note_to_load;
    wire [5:0] duration_to_load;
    wire done_with_note, beat, new_sample_ready;
    wire [15:0] sample_out;
    reg load_new_note;

    assign duration_to_load = 6'b11;

    note_player np(
        .clk(clk),
        .reset(reset),

        .play_enable(play_enable),
        .note_to_load(note_to_load),
        .duration_to_load(duration_to_load),
        .load_new_note(load_new_note),
        .done_with_note(done_with_note),
        .beat(beat),
        .generate_next_sample(generate_next_sample),
        .sample_out(sample_out),
        .new_sample_ready(new_sample_ready)
    );

    beat_generator #(.WIDTH(17), .STOP(1500)) beat_generator(
        .clk(clk),
        .reset(reset),
        .en(1'b1),
        .beat(beat)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // generate_next_sample timing
    initial begin
        generate_next_sample = 1'b0;
        @(negedge reset);

        forever begin
            #50; 
            @(negedge clk);
            generate_next_sample = 1'b1;
            @(negedge clk);
            generate_next_sample = 1'b0;
        end
    end

    // Tests
    initial begin
        note_to_load = 6'd1;
        @(negedge reset);
        #15;
        @(negedge clk);
        load_new_note = 1'b1;
        @(negedge clk);
        load_new_note = 1'b0;
        play_enable = 1'b1;
        $monitor("beat %b, done %b, note %d, sample %d, ready %b, enable %b", beat, done_with_note, np.note_to_load,
          sample_out, new_sample_ready, play_enable);
        while (~done_with_note) begin
            @(negedge clk);
        end
        note_to_load = 6'd10;
        @(negedge clk);
        load_new_note = 1'b1;
        @(negedge clk);
        load_new_note = 1'b0;
        #32000;
        @(negedge clk);
        play_enable = 1'b0;
        #16000;
        @(negedge clk);
        play_enable = 1'b1;
        #30000;

        $finish;
    end

endmodule