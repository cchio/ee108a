module linear_scale_rom_tb();

    reg clk;
    reg [3:0] addr;
    wire [7:0] dout;

    linear_scale_rom lin_rom (
        .clk(clk),
        .addr(addr),
        .dout(dout)
    );

    // clocking
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // tests
    initial begin
        addr = 4'b0;
        $monitor("clk %b, addr %d, dout %d", clk, addr, dout);

        repeat (15) begin
            #40;
            addr = addr + 4'b1;
        end
        #40;

        $finish;
    end

endmodule
