module rs232_tb();

    reg clk, reset, rx, data_ready;
    wire flag, tx, busy;
    wire [7:0] byte;
    reg [7:0] tx_byte;

    rs232 r (
        .clk(clk),
        .reset(reset),
        .rx_pin(rx),
        .rx_flag(flag),
        .rx_data_byte(byte),
        .tx_pin(tx),
        .tx_byte(tx_byte),
        .tx_data_ready(data_ready),
        .tx_busy(busy)
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
        rx = 1'b0;
        tx_byte = 8'b0;
        data_ready = 1'b0;
        @(negedge reset);
        @(negedge clk);
        $monitor("rxstate %b, rx %b, flag %b, rxdata %b, txstate %b, tx %b, txdata %b, busy %b, ready %b", r.rx_state, rx, flag, byte, r.tx_state, tx, r.tx_data_byte, busy, data_ready);

        #100;
        @(negedge clk);
        rx = 1'b1;
        #10000;
        // writing 8'b01010101
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b1;
        #8670;
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b1;
        #8670;
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b1;
        #8670;
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b1;
        #8670;
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b1;

        #20000;
        // writing 8'b11000110
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b1;
        #8670;
        @(negedge clk);
        rx = 1'b1;
        #8670;
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b0;
        #8670;
        @(negedge clk);
        rx = 1'b1;
        #8670;
        @(negedge clk);
        rx = 1'b1;
        #8670;
        @(negedge clk);
        rx = 1'b1;
        #15000;

        // Transmit value 8'b01100101
        tx_byte = 8'b01100101;
        @(negedge clk);
        data_ready = 1'b1;
        @(negedge clk);
        data_ready = 1'b0;
        #30000;
        tx_byte = 8'b0;
        @(negedge clk);
        data_ready = 1'b1;
        @(negedge clk);
        data_ready = 1'b0;
        while (busy) @(negedge clk);

        #30000;
        // Transmit value 8'b00111001
        tx_byte = 8'b00111001;
        @(negedge clk);
        data_ready = 1'b1;
        @(negedge clk);
        data_ready = 1'b0;
        #30000;
        tx_byte = 8'b0;
        @(negedge clk);
        data_ready = 1'b1;
        @(negedge clk);
        data_ready = 1'b0;
        while (busy) @(negedge clk);
        #10000;

        $finish;
    end

endmodule
