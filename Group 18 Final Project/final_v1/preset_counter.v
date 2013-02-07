module preset_counter #(parameter WIDTH=4,parameter MAX=15) (
    input clk,
    input reset,
    input beat,
    input enable,
    output [WIDTH-1:0] count
);

    reg  [WIDTH-1:0] next_cnt;

    dffr #(.WIDTH(WIDTH)) cnt(
        .clk(clk),
        .r(reset),
        .d(next_cnt),
        .q(count)
    );

    // Update the count output with each beat if enabled
    always @(*) begin
        if (reset) next_cnt = 0;
        else if (enable && beat) next_cnt = (count == MAX) ? 0 : count + 1;
        else next_cnt = count;
    end

endmodule
