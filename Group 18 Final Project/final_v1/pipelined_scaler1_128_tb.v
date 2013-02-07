module pipelined_scaler1_128_tb();

    reg clk, reset;
    reg signed [15:0] in;
    wire signed [15:0] out;
    reg [7:0] mult;

    pipelined_scaler1_128 scaler (
        .clk(clk),
        .reset(reset),
        .in(in),
        .multiplier(mult),
        .out(out)
    );


    // reset and clocking
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat(4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // tests
    initial begin
        mult = 8'd0;
        in = 16'd0;
        @(negedge reset);
        @(negedge clk);
        $monitor("clk %b, in %d, mult %d, out %d", clk, in, mult, out);

        @(negedge clk);
        mult = 8'd128;
        in = 16'd1200;
        repeat(10) begin
            @(negedge clk);
        end
        mult = 8'd64;
        in = 16'd45000;
        repeat(10) begin
            @(negedge clk);
        end

        $finish;
    end

endmodule
