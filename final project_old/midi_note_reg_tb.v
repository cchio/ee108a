module midi_note_reg_tb();

    reg clk, wr_en;
    reg [4:0] addr;
    reg [15:0] value;
    wire [15:0] out [31:0];

    midi_note_reg note_register (
        .clk(clk),
        .addr(addr),
        .din(value),
        .write_en(wr_en),
        .note0(out[0]),
        .note1(out[1]),
        .note2(out[2]),
        .note3(out[3]),
        .note4(out[4]),
        .note5(out[5]),
        .note6(out[6]),
        .note7(out[7]),
        .note8(out[8]),
        .note9(out[9]),
        .note10(out[10]),
        .note11(out[11]),
        .note12(out[12]),
        .note13(out[13]),
        .note14(out[14]),
        .note15(out[15]),
        .note16(out[16]),
        .note17(out[17]),
        .note18(out[18]),
        .note19(out[19]),
        .note20(out[20]),
        .note21(out[21]),
        .note22(out[22]),
        .note23(out[23]),
        .note24(out[24]),
        .note25(out[25]),
        .note26(out[26]),
        .note27(out[27]),
        .note28(out[28]),
        .note29(out[29]),
        .note30(out[30]),
        .note31(out[31])
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
        value = 16'h403C;
        @(negedge clk);
        $monitor("clk %b, wr_en %b, addr %d, value %h, note0 %h, note1 %h",
          clk, wr_en, addr, value, out[0], out[1]);


        $display("should write note1 to 0x403C");
        wr_en = 1'b1;
        @(negedge clk);
        wr_en = 1'b0;
        #40;
        @(negedge clk);
        addr = 5'b0;
        value = 16'h7F40;
        $display("should write note0 to 0x7F40");
        wr_en = 1'b1;
        @(negedge clk);
        wr_en = 1'b0;
        #40;
        @(negedge clk);
        addr = 5'b1;
        $display("should write note1 to 0x7F40");
        wr_en = 1'b1;
        @(negedge clk);
        wr_en = 1'b0;
        #20;

        $finish;
    end

endmodule
