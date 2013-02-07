module polyphony32_mixer_tb();

    reg clk, rst, ready_in;
    reg [7:0] mult;
    reg [`NUM_NOTES*16-1:0] samples;
    wire ready_out;
    wire [15:0] out;

    polyphony_mixer mix (
        .clk(clk),
        .reset(rst),
        .multiplier(mult),
        .samples_ready(ready_in),
        .samples(samples),
        .sample_ready(ready_out),
        .sample(out)
    );

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        repeat(4) #5 clk = ~clk;
        rst = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        samples = 47'b0;
        mult = 8'd0;
        samples[15:0] = 16'd12000;
        ready_in = 1'b0;
        @(negedge rst);
        @(negedge clk);
        $monitor("clk %b, sample1 %d, sample2 %d, sample3 %d, mult %d, ready_in %b, out %d, ready_out %b",
          clk, samples[15:0], samples[31:16], samples[47:32], mult, ready_in, out, ready_out);

        #40;
        $display("out should equal 12000");
        @(negedge clk);
        ready_in = 1'b1;
        @(negedge clk);
        ready_in = 1'b0;
        @(negedge ready_out);
        @(negedge clk);
        mult = 8'd128;
        samples[31:16] = 16'd25000;
        $display("out should equal 18568");
        @(negedge clk);
        ready_in = 1'b1;
        @(negedge clk);
        ready_in = 1'b0;
        @(negedge ready_out);
        @(negedge clk);
        mult = 8'd171;
        samples[47:32] = 16'sd45000;
        $display("out should equal 5520");
        @(negedge clk);
        ready_in = 1'b1;
        @(negedge clk);
        ready_in = 1'b0;
        @(negedge ready_out);
        @(negedge clk);
        mult = 8'd128;
        samples[15:0] = 16'sd45000;
        samples[31:16] = 16'sd40000;
        samples[47:32] = 16'sd0;
        $display("out should equal 42504");
        @(negedge clk);
        ready_in = 1'b1;
        @(negedge clk);
        ready_in = 1'b0;
        @(negedge ready_out);
        @(negedge clk);

        $finish;
    end

endmodule
