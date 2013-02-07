// master_fsm_tb.v
// test bench for the master_fsm module

module master_fsm_tb();
    reg clk, reset, up_button, down_button, next;
    wire left1, right1, left2, right2;
    wire [1:0] mux_sel;
    wire nextOut;

    master_fsm fsm(
        .clk(clk), .reset(reset),
        .up_button(up_button), .down_button(down_button),
        .next(nextOut), .left1(left1),
        .right1(right1), .left2(left2),
        .right2(right2), .mux_sel(mux_sel)
    );

    one_pulse p(.clk(clk), .reset(reset), .in(next), .out(nextOut));

    initial begin
        clk = 0;

        forever #1 clk = ~clk;
    end

    initial begin
        up_button = 0;
        down_button = 0;
        next = 0;
        $monitor("reset %b, up %b, down %b, next %b, l1 %b, r1 %b, l2 %b, r2 %b, mux %b",
        reset, up_button, down_button, nextOut, left1, right1, left2, right2,
        mux_sel);

        // initial reset
        reset = 1;
        #10;
        reset = 0;
        #10;

        repeat(7) begin
            #10;
            $display("Going to next state");
            next = 1;
            #10;
            next = 0;
            $display("Testing incrementing blinking speed in current state");
            up_button = 1;
            #10;
            up_button = 0;
            down_button = 1;
            #10;
            down_button = 0;
            #10;
        end

        $display("Testing reset");
        reset = 1;
        #10;
        $finish;
    end

endmodule
