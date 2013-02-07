module midi_note_reg_tb();

    reg clk, wr_en;
    reg [4:0] addr;
    reg [13:0] value;
    wire [13:0] out [3:0];

    midi_note_reg note_register (
        .clk(clk),
        .addr(addr),
        .din(value),
        .write_en(wr_en),
        .note0(out[0]),
        .note1(out[1]),
        .note2(out[2]),
        .note3(out[3])
    );

    // clocking
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // tests
    initial begin
        addr = 5'b1;
        wr_en = 1'b0;
        value = {7'd64,7'd60};
        @(negedge clk);
        $monitor("clk %b, wr_en %b, addr %d, value %h, note0 %h, note1 %h",
          clk, wr_en, addr, value, out[0], out[1]);


        $display("should write note1 to %h", {7'd64,7'd60});
        wr_en = 1'b1;
        @(negedge clk);
        wr_en = 1'b0;
        #40;
        @(negedge clk);
        addr = 5'b0;
        value = {7'd127,7'd64};
        $display("should write note0 to %h", {7'd127,7'd64});
        wr_en = 1'b1;
        @(negedge clk);
        wr_en = 1'b0;
        #40;
        @(negedge clk);
        addr = 5'b1;
        $display("should write note1 to %h", value);
        wr_en = 1'b1;
        @(negedge clk);
        wr_en = 1'b0;
        #20;

        $finish;
    end

endmodule
