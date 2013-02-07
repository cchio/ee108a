module midi_note_tb();

    reg clk, reset, update, update_all, generate_next;
    reg [15:0] controller_values, note_values;
    wire [15:0] sample;
    wire sample_ready, note_on;

    midi_note note (
        .clk(clk),
        .reset(reset),
        .update_note(update),
        .update_all_notes(update_all),
        .generate_next(generate_next),
        .controller_values(controller_values),
        .note_values(note_values),
        .sample_out_ready(sample_ready),
        .sample_out(sample),
        .note_playing(note_on)
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
            #3200;
            generate_next = 1'b1;
            #8;
            generate_next = 1'b0;
            #2;
        end
    end

    // tests
    integer delay;
    initial begin
        delay = 155000000;
        controller_values = 16'h0040;
        note_values = {8'd127,8'd50};
        update = 1'b0;
        update_all = 1'b0;
        @(negedge reset);
        @(negedge clk);

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

        $finish;
    end

    // output a .snd file of the output
    integer file, samplecount;
    initial begin
        // Open the output file. GENERATES_SND (a player is auto-launched)
        file = $fopen("midi_note_tb_audio.snd", "wb");
        $display("Audio out: sound file midi_note_tb_audio.snd opened for output.");
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
            @(posedge sample_ready);
            // Output the sample data (16-bit big-endian, left then right)
            $fwrite(file, "%u",
                {sample[7:0], sample[15:8],
                  sample[7:0],  sample[15:8]});
            samplecount = samplecount + 1;
            if (samplecount && samplecount % 48000 == 0)
                $display("[%0t] Audio out: generated %0d seconds.",
                    $time, samplecount/48000);
        end
    end

endmodule
