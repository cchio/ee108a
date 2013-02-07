module midi_data_len_lookup (
    input clk,
    input [7:0] command,
    output reg [1:0] len
);

    always @(posedge clk) begin
        case (command[7:4])
            4'h8: len = 2'd2;
            4'h9: len = 2'd2;
            4'ha: len = 2'd2;
            4'hb: len = 2'd2;
            4'hc: len = 2'd1;
            4'hd: len = 2'd1;
            4'he: len = 2'd2;
            default: len = 2'd0;
        endcase
    end

endmodule
