module big_number_first(input [7:0] ain,
    input [7:0] bin,
    output [7:0] aout,
    output [7:0] bout
);

    assign aout = (ain >= bin) ? ain : bin;
    assign bout = (ain >= bin) ? bin : ain;

endmodule
