module shifter(input [4:0] in,
    input [2:0] distance,
    input direction,
    output wire [4:0] out
);

    assign out = direction ? in>>distance : in<<distance;

endmodule