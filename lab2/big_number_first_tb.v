module big_number_first_tb();

    reg [7:0] ain, bin;
    wire [7:0] aout, bout;
    big_number_first bnf(.ain(ain), .bin(bin), .aout(aout), .bout(bout));

    initial begin
        ain = 8'b0;
        bin = 8'b0;
        $monitor("ain %b, bin %b, aout %b, bout %b",
          ain, bin, aout, bout);

        #100;
        ain = 8'b00110000;
        #100;
        bin = 8'b00110001;
        #100;
        ain = 8'b11100000;
        bin = 8'b11111111;
        #100;
        ain = 8'b00000000;
        #100;
        ain = 8'b11111111;
        #100;

        $finish;
    end

endmodule
