module midi_wave_reader_tb();

    reg clk, reset, generate_next, zero;
    wire [19:0] step;
    wire samples_ready;
    wire signed [15:0] samp1, samp2, samp3, samp4, samp5, samp6, samp7,
      samp8;



    frequency_rom freq (
        .clk(clk),
        .addr(6'd1),
        .dout(step)
    );

    midi_wave_reader reader (
        .clk(clk),
        .reset(reset),
        .zero(zero),
        .generate_next(generate_next),
        .step1(step),
        .step2(),
        .step3(),
        .step4(),
        .step5(),
        .step6(),
        .step7(),
        .step8(8*step),
        .samples_ready(samples_ready),
        .sample1(samp1),
        .sample2(),
        .sample3(),
        .sample4(),
        .sample5(),
        .sample6(),
        .sample7(),
        .sample8(samp8)
    );


    // clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat(4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end


    // tests
    initial begin
        generate_next = 1'b0;
        @(negedge reset);
        @(negedge clk);
        forever begin
            #400;
            generate_next = 1'b1;
            #8;
            generate_next = 1'b0;
            #2;
        end
    end


    // tests
    integer delay;
    initial begin
        delay = 1000000;
        zero = 1'b0;
        @(negedge reset);
        @(negedge clk);

        repeat(delay-246) begin
            @(negedge clk);
        end
        zero = 1'b1;
        repeat(246) begin
            @(negedge clk);
        end

        $finish;
    end


    // output files
    // integer file1, file2, samplecount;
    // initial begin
    //     // Open the output files. GENERATES_SND (a player is auto-launched)
    //     file1 = $fopen("midi_wave_audio1.snd", "wb");
    //     file2 = $fopen("midi_wave_audio2.snd", "wb");
    //     $display("Audio out: sound files opened for output.");
    //     // Write the SND header. It consists of 6 32-bit, big-endian words, and
    //     // is followed by four 8-bit zero bytes to signify no annotations.
    //     // 0: Magic number: ASCII ".snd"
    //     // 1: Offset of the audio data in bytes: 28
    //     // 2: Data size: unknown -> all F's
    //     // 3: Encoding format: 3 = 16-bit linear PCM
    //     // 4: Sample rate: 48KHz = 0xBB80
    //     // 5: Number of channels: 2
    //     // (6): No annotations: 0
    //     $fwrite(file1, ".snd%u%u%u%u%u%u",
    //         32'h1C_00_00_00, 32'hFF_FF_FF_FF, 32'h03_00_00_00,
    //         32'h80_BB_00_00, 32'h02_00_00_00, 32'h00_00_00_00);
    //     $fwrite(file2, ".snd%u%u%u%u%u%u",
    //         32'h1C_00_00_00, 32'hFF_FF_FF_FF, 32'h03_00_00_00,
    //         32'h80_BB_00_00, 32'h02_00_00_00, 32'h00_00_00_00);
    //     // After this is all the PCM data, stored in big-endian format.
    //     samplecount = 0;
    //     forever begin
    //         // Wait for a new sample
    //         @(posedge samples_ready);
    //         // Output the sample data (16-bit big-endian, left then right)
    //         $fwrite(file1, "%u",
    //             {samp1[7:0], samp1[15:8],
    //               samp1[7:0],  samp1[15:8]});
    //         $fwrite(file2, "%u",
    //             {samp8[7:0], samp8[15:8],
    //               samp8[7:0],  samp8[15:8]});
    //         samplecount = samplecount + 1;
    //         if (samplecount && samplecount % 48000 == 0)
    //             $display("[%0t] Audio out: generated %0d seconds.",
    //                 $time, samplecount/48000);
    //     end
    // end

endmodule
