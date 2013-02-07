module midi_dynamics_tb();

    reg clk, reset, update, update_all, generate_next;
    reg [13:0] controller_values, note_values;
    wire signed [15:0] sample_in, sample_out;
    wire samples_in_ready, samples_out_ready, voice_on;
    wire [5:0] note;
    wire [19:0] step_size;

    midi_dynamics dynamics (
        .clk(clk),
        .reset(reset),
        .update_voice(update),
        .update_all_voices(update_all),
        .generate_next(generate_next),
        .controller_values(controller_values),
        .note_values(note_values),
        .samples_in_ready(samples_in_ready),
        .sample_in1(sample_in),
        .sample_in2(),
        .sample_in3(),
        .sample_in4(),
        .sample_in5(),
        .sample_in6(),
        .sample_in7(),
        .sample_in8(),
        .voice_on(voice_on),
        .note(note),
        .samples_out_ready(samples_out_ready),
        .sample_out1(sample_out),
        .sample_out2(),
        .sample_out3(),
        .sample_out4(),
        .sample_out5(),
        .sample_out6(),
        .sample_out7(),
        .sample_out8()
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
        .sample_ready(samples_in_ready),
        .sample(sample_in)
    );

    // clocking and resets
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat(10) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // generate next
    initial begin
        generate_next = 1'b0;
        @(negedge reset);
        @(negedge clk);
        forever begin
            #3000;
            generate_next = 1'b1;
            #8;
            generate_next = 1'b0;
            #2;
        end
    end

    // tests
    integer delay;
    initial begin
        delay = 20000000;
        controller_values = {7'd0,7'h40};
        note_values = {7'd127,7'd60};
        update = 1'b0;
        update_all = 1'b0;
        @(negedge reset);
        @(negedge clk);
        $monitor("update %b, update_all %b, note_val %h, control_val %h, on %b, note %d",
            update, update_all, note_values, controller_values, voice_on, note);

        update = 1'b1;
        @(negedge clk);
        update = 1'b0;
        repeat(delay) begin
            @(negedge clk);
        end
        note_values[13:7] = 7'd0;
        @(negedge clk);
        update = 1'b1;
        @(negedge clk);
        update = 1'b0;
        repeat(10) begin
            @(negedge clk);
        end

        $finish;
    end

    // output a .snd file of the output
    integer file, samplecount;
    initial begin
        // Open the output file. GENERATES_SND (a player is auto-launched)
        file = $fopen("midi_dynamics_tb_audio.snd", "wb");
        $display("Audio out: sound file midi_dynamics_tb_audio.snd opened for output.");
        // Write the SND header. It consists of 6 32-bit, big-endian words, and
        // is followed by four 8-bit zero bytes to signify no annotations.
        // 0: Magic number: ASCII ".snd"
        // 1: Offset of the audio data in bytes: 28
        // 2: Data size: unknown -> all F's
        // 3: Encoding format: 3 = 16-bit linear PCM 
        // 4: Sample rate: 48KHz = 0xBB80
        // 5: Number of channels: 2
        // (6): No annotations: 0
        $fwrite(file, ".snd%u%u%u%u%u%u",
            32'h1C_00_00_00, 32'hFF_FF_FF_FF, 32'h03_00_00_00,
            32'h80_BB_00_00, 32'h02_00_00_00, 32'h00_00_00_00);
        // After this is all the PCM data, stored in big-endian format.
        samplecount = 0;
        forever begin
            // Wait for a new sample
            @(posedge samples_out_ready);
            // Output the sample data (16-bit big-endian, left then right)
            $fwrite(file, "%u",
                {sample_out[7:0], sample_out[15:8],
                  sample_out[7:0],  sample_out[15:8]});
            samplecount = samplecount + 1;
            if (samplecount && samplecount % 48000 == 0)
                $display("[%0t] Audio out: generated %0d seconds.",
                    $time, samplecount/48000);
        end
    end

endmodule
