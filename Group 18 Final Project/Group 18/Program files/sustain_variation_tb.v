module sustain_variation_tb();

    reg clk, reset;
    reg [5:0] note;
    wire [15:0] out;

    sustain_variation var (
        .clk(clk),
        .reset(reset),
        .note(note),
        .count(out)
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
        note = 6'b1;
        @(negedge reset);
        @(negedge clk);
        $monitor("clk %b, note %d, count %d", clk, note, out);

        #40;
        note = 6'd2;
        #40;
        note = 6'd3;
        #40;
        note = 6'd63;
        #40;

        $finish;
    end

endmodule
