module linear_scale_rom (
    input clk,
    input [3:0] addr,
    output reg [7:0] dout
);

    wire [7:0] memory [15:0];

    always @(posedge clk)
        dout = memory[addr];

    assign memory[0] = 8'd128;
    assign memory[1] = 8'd119;
    assign memory[2] = 8'd110;
    assign memory[3] = 8'd101;
    assign memory[4] = 8'd92;
    assign memory[5] = 8'd83;
    assign memory[6] = 8'd74;
    assign memory[7] = 8'd65;
    assign memory[8] = 8'd56;
    assign memory[9] = 8'd47;
    assign memory[10] = 8'd38;
    assign memory[11] = 8'd29;
    assign memory[12] = 8'd20;
    assign memory[13] = 8'd11;
    assign memory[14] = 8'd5;
    assign memory[15] = 8'd0;

endmodule
