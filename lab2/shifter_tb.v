module shifter_tb();

    reg [4:0] in;
    reg [2:0] distance;
    reg dir;
    wire [4:0] out;
    shifter sh(.in(in), .distance(distance), .direction(dir), .out(out));

    initial begin
        in = 5'b11111;
        distance = 0;
        dir = 0;
        $monitor("in %b, distance %b, dir %b, out %b",
          in, distance, dir, out);

        #100;
        distance = 1;
        #100;
        distance = 4;
        #100;
        distance = 6;
        #100;
        distance = 0;
        dir = 1;
        #100;
        distance = 1;
        #100;
        distance = 4;
        #100;
        distance = 6;
        #100;

        $finish;
    end

endmodule
