module duration_timer2_tb();

    reg [5:0] len;
    reg clk, hbeat, rst, paused, new_duration;
    wire new_duration1, done;

    one_pulse p(.clk(hbeat), .reset(rst), .in(new_duration), .out(new_duration1));

    duration_timer2 d(
        .clk(clk), .reset(rst), .beat(hbeat), .pause(paused), .load_new_duration(new_duration1),
    .duration(len), .done(done));

    initial begin
        hbeat = 1'b0;

        forever #10 hbeat = ~hbeat;
    end

    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    initial begin
        paused = 1'b0;
        len = 6'd16;
        new_duration = 1'b0;

        $monitor("rst %b, beat %b, clk %b, pause %b, count %d, done %b", rst, hbeat, clk, paused,
        d.counter, done);
        rst = 1'b1;
        #40;
        rst = 1'b0;
        #20;

        @(negedge clk);
        new_duration = 1'b1;
        @(negedge clk);
        new_duration = 1'b0;
        #400;
        len = 6'd30;
        @(negedge clk);
        new_duration = 1'b1;
        @(negedge clk);
        new_duration = 1'b0;
        #200;
        paused = 1'b1;
        #100;
        paused = 1'b0;
        #450;

        $finish;
    end

endmodule
