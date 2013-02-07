`include "num_notes.v"

module next_midi_note (
    input clk,
    input reset,
    input [`NUM_NOTES-1:0] notes_playing,
    output [4:0] note
);

    reg [4:0] note1;
    reg [4:0] count1;
    wire [4:0] count;

    dffr #(.WIDTH(5)) counter (
        .clk(clk),
        .r(reset),
        .d(count1),
        .q(count)
    );

    dffr #(.WIDTH(5)) note_ff (
        .clk(clk),
        .r(reset),
        .d(note1),
        .q(note)
    );

    // scan for the first available note
    always @(*) begin
        if (reset) begin
            count1 = 5'b0;
            note1 = 5'b0;
        end
        if (~notes_playing[count]) begin
            count1 = 5'b0;
            note1 = count;
        end
        else begin
            count1 = (count == (`NUM_NOTES-1)) ? 5'b0 : count + 1; 
            note1 = note;
        end
    end

endmodule
