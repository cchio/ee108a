module mix_multiplier_rom_tb();

    reg clk;
    reg [5:0] addr;
    wire [7:0] dout;

    mix_multiplier_rom m (
        .clk(clk),
        .addr(addr),
        .dout(dout)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        $monitor("clk %b, addr %d, out %d", clk, addr, dout);

        @(negedge clk);
        addr = 6'b0;
        #20;
        @(negedge clk);
        addr = 6'd1;
        #20;
        @(negedge clk);
        addr = 6'd31;
        #20;
        @(negedge clk);

    $finish;
    end

endmodule
