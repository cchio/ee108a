module mix_multiplier_rom (
    input clk,
    input [5:0] addr,
    output reg [7:0] dout
);

    wire [7:0] memory [31:0];

    always @(posedge clk)
        dout = memory[addr];

    assign memory[0] = 8'd0;
    assign memory[1] = 8'd128;
    assign memory[2] = 8'd171;
    assign memory[3] = 8'd192;
    assign memory[4] = 8'd205;
    assign memory[5] = 8'd214;
    assign memory[6] = 8'd220;
    assign memory[7] = 8'd224;
    assign memory[8] = 8'd228;
    assign memory[9] = 8'd231;
    assign memory[10] = 8'd233;
    assign memory[11] = 8'd235;
    assign memory[12] = 8'd236;
    assign memory[13] = 8'd238;
    assign memory[14] = 8'd239;
    assign memory[15] = 8'd240;
    assign memory[16] = 8'd241;
    assign memory[17] = 8'd242;
    assign memory[18] = 8'd243;
    assign memory[19] = 8'd244;
    assign memory[20] = 8'd244;
    assign memory[21] = 8'd245;
    assign memory[22] = 8'd245;
    assign memory[23] = 8'd246;
    assign memory[24] = 8'd246;
    assign memory[25] = 8'd247;
    assign memory[26] = 8'd247;
    assign memory[27] = 8'd247;
    assign memory[28] = 8'd248;
    assign memory[29] = 8'd248;
    assign memory[30] = 8'd248;
    assign memory[31] = 8'd248;

endmodule
