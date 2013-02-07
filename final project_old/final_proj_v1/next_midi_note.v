module next_midi_note (
    input clk,
    input reset,
    input [31:0] notes_playing,
    output reg [4:0] note
);

    reg [4:0] count1;
    wire [4:0] count;

    dffr #(.WIDTH(5)) counter (
        .clk(clk),
        .r(reset),
        .d(count1),
        .q(count)
    );

    // scan for the first available note
    always @(*) begin
        if (reset) begin
            count1 = 5'b0;
            note = 5'b0;
        end
        if (~notes_playing[count]) begin
            count1 = 5'b0;
            note = count;
        end
        else count1 = (count == 5'd31) ? 5'b0 : count + 1; 
    end

endmodule
