module midi_msg_capture_tb();

    reg clk, rst, byte_ready;
    reg [7:0] byte;
    wire msg_ready;
    wire [23:0] msg;

    midi_msg_capture cap (
        .clk(clk),
        .reset(rst),
        .new_byte_ready(byte_ready),
        .new_byte(byte),
        .new_msg(msg_ready),
        .msg(msg)
    );

    // clocking and reset
    initial begin
        rst = 1'b1;
        clk = 1'b0;
        repeat(4) #5 clk = ~clk;
        rst = 1'b0;
        forever #5 clk = ~clk;
    end

    // tests
    initial begin
        byte_ready = 1'b0;
        byte = 8'h90;
        @(negedge rst);
        @(negedge clk);
        $monitor("clk %b, new_byte %b, byte %h, new_msg %b, msg %h", clk,
          byte_ready, byte, msg_ready, msg);

        @(negedge clk);
        $display("msg should equal 403C90");
        byte_ready = 1'b1;
        @(negedge clk);
        byte_ready = 1'b0;
        #40;
        @(negedge clk);
        byte = 8'h3C;
        byte_ready = 1'b1;
        @(negedge clk);
        byte_ready = 1'b0;
        #40;
        @(negedge clk);
        byte = 8'h40;
        byte_ready = 1'b1;
        @(negedge clk);
        byte_ready = 1'b0;
        #80;
        @(negedge clk);
        $display("msg should equal 0074C1");
        byte = 8'hC1;
        byte_ready = 1'b1;
        @(negedge clk);
        byte_ready = 1'b0;
        #40;
        @(negedge clk);
        byte = 8'h74;
        byte_ready = 1'b1;
        @(negedge clk);
        byte_ready = 1'b0;
        #80;
        @(negedge clk);
        $display("msg should equal 0000FE");
        byte = 8'hFE;
        byte_ready = 1'b1;
        @(negedge clk);
        byte_ready = 1'b0;
        #80;

        $finish;
    end

endmodule
