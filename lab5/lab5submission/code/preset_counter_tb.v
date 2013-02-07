module preset_counter_tb();

    reg enable, reset, clk, beat;
    wire [7:0] count;

    preset_counter #(.WIDTH(6),.MAX(31)) cnt(
        .clk(clk),
        .reset(reset),
        .beat(beat),
        .enable(enable),
        .count(count)
    );

    // clocking
    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // slow beat
    initial begin
        beat = 1'b0;
        #5;

        forever #10 beat = ~beat;
    end

    // tests
    initial begin
        reset = 1'b1;
        #10;
        reset = 1'b0;
        enable = 1'b1;
        $monitor("rst %b, beat %b, count %d, enable %b", reset, beat, count, enable);

        // run the timer and then cycle the enable input
        #700;
        enable = 1'b0;
        #55;
        enable = 1'b1;
        #100;

        $finish;
    end

endmodule
