module wave_capture_tb();

    reg clk, rst, displ_idle, next;
    wire [19:0] step = {10'd50,10'd0};
    wire new_sample_ready;
    wire [15:0] sample;
    wire wr_en, index;
    wire [8:0] wr_addr;
    wire [7:0] wr_sample;

    sine_reader sn (
        .clk(clk),
        .reset(rst),
        .step_size(step),
        .generate_next(next),
        .sample_ready(new_sample_ready),
        .sample(sample)
    );

    wave_capture wave (
        .clk(clk),
        .reset(rst),
        .new_sample_ready(new_sample_ready),
        .new_sample_in(sample),
        .wave_display_idle(displ_idle),
        .write_address(wr_addr),
        .write_sample(wr_sample),
        .write_enable(wr_en),
        .read_index(index)
    );

    // clock and reset
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        repeat(4) #5 clk = ~clk;
        rst = 1'b0;

        forever #5 clk = ~clk;
    end

    // generate_next pulses
    initial begin
        next = 1'b0;
        @(negedge rst);
        @(negedge clk);

        forever begin
            #100;
            @(negedge clk);
            next = 1'b1;
            @(negedge clk);
            next = 1'b0;
            #100;
        end
    end

    // tests
    initial begin
        displ_idle = 1'b1;
        @(negedge rst);
        @(negedge clk);
        $monitor("ready %b, sample %d, state %b, idle %b, addr %d, en %b, wr_sample %d, index %b",
          new_sample_ready, sample, wave.curr_state_out, displ_idle, wr_addr, wr_en,
          wr_sample, index);

        #500000;

        $finish;
    end

endmodule
