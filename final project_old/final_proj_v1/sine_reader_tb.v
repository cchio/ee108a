module sine_reader_tb();

    reg clk, reset, generate_next, zero;
    reg [19:0] step_size;
    wire sample_ready;
    wire [15:0] sample;
    sine_reader reader(
        .clk(clk),
        .reset(reset),
        .zero(zero),
        .step_size(step_size),
        .generate_next(generate_next),
        .sample_ready(sample_ready),
        .sample(sample)
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // generate_next pulse
    initial begin
        generate_next = 1'b0;
        #20;

        forever begin
            #200; generate_next = 1'b1;
            #8; generate_next = 1'b0;
            #2;
        end
    end

    // Tests
    initial begin
        zero = 1'b0;
        step_size = {10'd128, 10'd0};
        #20;
        $monitor("generate_next %b, zero %b, step %b, ready %b, sample %d, addr %d",
          generate_next, zero, step_size, sample_ready, sample, reader.curAddr[19:10]);
        #7000;
        step_size[19:10] = 10'd512;
        #3500;
        zero = 1'b1;
        #1000;

        $finish;
    end

endmodule
