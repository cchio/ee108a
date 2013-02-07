module midi_harmonic_dynamics_tb();

    reg clk, reset, update, update_all, generate_next;
    reg [15:0] controller_values, note_values;
    wire signed [15:0] sample_in;
    wire [15:0] sustain_inc;
    wire sample_ready, voice_on, decay;
    wire [5:0] note;
    wire [7:0] gain, velocity;
    wire [19:0] step_size;

    midi_harmonic_dynamics dynamics (
        .clk(clk),
        .reset(reset),
        .update_voice(update),
        .update_all_voices(update_all),
        .generate_next(generate_next),
        .controller_values(controller_values),
        .note_values(note_values),
        .sustain_inc(sustain_inc),
        .sample_ready(sample_ready),
        .sample_in(sample_in),
        .voice_on(voice_on),
        .note(note),
        .velocity(velocity),
        .gain(gain),
        .decay_type(decay)
    );

    frequency_rom freq_rom (
        .clk(clk),
        .addr(note),
        .dout(step_size)
    );

    sine_reader sine (
        .clk(clk),
        .reset(reset),
        .step_size(step_size),
        .zero(~voice_on),
        .generate_next(generate_next),
        .sample_ready(sample_ready),
        .sample(sample_in)
    );

    sustain_variation var (
        .clk(clk),
        .reset(reset),
        .note(note),
        .count(sustain_inc)
    );


    // clocking and resets
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat(4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // generate next
    initial begin
        generate_next = 1'b0;
        @(negedge reset);
        @(negedge clk);
        forever begin
            #100;
            generate_next = 1'b1;
            #8;
            generate_next = 1'b0;
            #2;
        end
    end

    // tests
    integer delay;
    initial begin
        delay = 7000000;
        controller_values = 16'h0040;
        note_values = {8'd127, 8'd29};
        update = 1'b0;
        update_all = 1'b0;
        @(negedge reset);
        @(negedge clk);
        $monitor("update %b, update_all %b, note_val %h, control_val %h, on %b, gain %d, note %d, vel %h, decay_type %b",
        update, update_all, note_values, controller_values, voice_on, gain, note,
        velocity, decay);

        update = 1'b1;
        @(negedge clk);
        update = 1'b0;
        repeat(delay) begin
            @(negedge clk);
        end
        note_values[15:8] = 8'd0;
        @(negedge clk);
        update = 1'b1;
        @(negedge clk);
        update = 1'b0;
        repeat(10) begin
            @(negedge clk);
        end
        note_values = {8'd64,8'd91};
        update = 1'b1;
        @(negedge clk);
        update = 1'b0;
        repeat(delay/9) begin
            @(negedge clk);
        end
        controller_values = 16'h7F40;
        note_values[15:8] = 8'b0;
        @(negedge clk);
        update = 1'b1;
        update_all = 1'b1;
        @(negedge clk);
        update = 1'b0;
        update_all = 1'b0;
        repeat(delay/3) begin
            @(negedge clk);
        end
        controller_values = 16'h0040;
        note_values[15:8] = 8'd127;
        @(negedge clk);
        update = 1'b1;
        update_all = 1'b1;
        @(negedge clk);
        update = 1'b0;
        update_all = 1'b0;
        repeat(delay/9) begin
            @(negedge clk);
        end
        note_values[15:8] = 8'b0;
        update = 1'b1;
        @(negedge clk);
        update = 1'b0;
        repeat(delay/9) begin
            @(negedge clk);
        end

        $finish;
    end

endmodule
