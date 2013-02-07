module midi_data_len_lookup_tb();

    reg clk;
    reg [7:0] command;
    wire [1:0] data_len;

    midi_data_len_lookup len (
        .clk(clk),
        .command(command),
        .len(data_len)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        command = 8'b0;
        $monitor("clk %b, command %h, data_len %d", clk, command, data_len);

        $display("len should equal 0");
        #20;
        $display("len should equal 2");
        command = 8'h80;
        #20;
        $display("len should equal 1");
        command = 8'hC1;
        #20;
        $display("len should equal 0");
        command = 8'hFE;
        #20;

        $finish;
    end

endmodule
