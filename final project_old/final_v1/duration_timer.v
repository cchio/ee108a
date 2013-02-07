module duration_timer(
    input clk,
    input reset,
    input beat,
    input pause,
    input load_new_duration,
    input [5:0] duration,
    output done
);

    wire [5:0] counter;
    reg [5:0] next;

    dffr #(.WIDTH(6)) cnt(
        .clk(clk),
        .r(reset),
        .d(next),
        .q(counter)
    );

    always @(*) begin
        if (reset) next = 6'b0;
        else if (load_new_duration) next = duration;
        else if (pause) next = counter;
        else if (beat) next = (counter == 6'b0) ? 6'b0 : counter - 1'b1;
        else next = counter;
    end

    // Handle outputting when notes are finished
    wire last_value, in_value;

    dffr finished(
        .clk(clk),
        .r(reset),
        .d(in_value),
        .q(last_value)
    );

    assign done = ~last_value & in_value;
    assign in_value = ((counter == 6'b0) & ~load_new_duration);// ? /*(1'b1 &*/ ~reset : 1'b0;

endmodule
