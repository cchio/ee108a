module dynamics_calc_tb();

    reg clk, reset, samples_ready;
    reg [15:0] cycles;
    wire samples_out_ready;
    wire signed [15:0] out1, out2, out3, out4, out5, out6, out7, out8;

    dynamics_calc calc (
        .clk(clk),
        .reset(reset),
        .samples_in_ready(samples_ready),
        .velocity(8'd127),
        .sample_in1(16'b0),
        .gain1(8'b0),
        .decay_type1(1'b0),
        .sample_in2(16'd1200),
        .gain2(8'd64),
        .decay_type2(1'b0),
        .sample_in3(16'd1200),
        .gain3(8'd127),
        .decay_type3(1'b1),
        .sample_in4(16'd1200),
        .gain4(8'd127),
        .decay_type4(1'b0),
        .sample_in5(16'd50000),
        .gain5(8'd64),
        .decay_type5(1'b0),
        .sample_in6(16'd50000),
        .gain6(8'd127),
        .decay_type6(1'b1),
        .sample_in7(16'd1200),
        .gain7(8'd127),
        .decay_type7(1'b1),
        .sample_in8(16'd1200),
        .gain8(8'd127),
        .decay_type8(1'b1),

        .samples_out_ready(samples_out_ready),
        .sample_out1(out1),
        .sample_out2(out2),
        .sample_out3(out3),
        .sample_out4(out4),
        .sample_out5(out5),
        .sample_out6(out6),
        .sample_out7(out7),
        .sample_out8(out8)
    );


    // clocking and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat(10) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // tests
    initial begin
        $display("out: 0, 600, 1170, 1190, -7768, -15173, 1170, 1170");
        @(negedge reset);
        @(negedge clk);
        $monitor("time %d, ready %b, out1 %d, out2 %d, out3 %d, out4 %d, out5 %d, out6 %d, out7 %d, out8 %d",
          cycles, samples_ready, out1, out2, out3, out4, out5, out6, out7,
          out8);

        samples_ready = 1'b1;
        @(negedge clk);
        samples_ready = 1'b0;

        #4000;

        $finish;
    end

    initial begin
        cycles = 1'b0;
        forever begin
            @(posedge clk);
            cycles = cycles + 1'b1;
        end
    end

endmodule
