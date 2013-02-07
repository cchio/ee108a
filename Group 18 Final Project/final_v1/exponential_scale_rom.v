module exponential_scale_rom (
    input clk,
    input [3:0] addr,
    output reg [7:0] dout
);

    wire [7:0] memory [15:0];

    always @(posedge clk)
        dout = memory[addr];

    assign memory[0] = 8'd128;
    assign memory[1] = 8'd127;
    assign memory[2] = 8'd127;
    assign memory[3] = 8'd127;
    assign memory[4] = 8'd127;
    assign memory[5] = 8'd126;
    assign memory[6] = 8'd125;
    assign memory[7] = 8'd122;
    assign memory[8] = 8'd118;
    assign memory[9] = 8'd111;
    assign memory[10] = 8'd103;
    assign memory[11] = 8'd91;
    assign memory[12] = 8'd76;
    assign memory[13] = 8'd56;
    assign memory[14] = 8'd31;
    assign memory[15] = 8'd0;

endmodule
