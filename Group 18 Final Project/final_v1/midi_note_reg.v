`include "num_notes.v"

module midi_note_reg (
    input clk,
    input [4:0] addr,
    input [13:0] din,
    input write_en,
    // individual note outputs
    output [13:0] note0,
    output [13:0] note1,
    output [13:0] note2,
    output [13:0] note3
/*    output [13:0] note4,
    output [13:0] note5,
    output [13:0] note6,
    output [13:0] note7,
    output [13:0] note8,
    output [13:0] note9,
    output [13:0] note10,
    output [13:0] note11,
    output [13:0] note12,
    output [13:0] note13,
    output [13:0] note14,
    output [13:0] note13,
    output [13:0] note16,
    output [13:0] note17,
    output [13:0] note18,
    output [13:0] note19,
    output [13:0] note20,
    output [13:0] note21,
    output [13:0] note22,
    output [13:0] note23,
    output [13:0] note24,
    output [13:0] note25,
    output [13:0] note26,
    output [13:0] note27,
    output [13:0] note28,
    output [13:0] note29,
    output [13:0] note30,
    output [13:0] note31
*/
);

    reg [13:0] note_reg [`NUM_NOTES-1:0];

    always @(posedge clk) 
        if (write_en) note_reg[addr] <= din;

    // all output assigns
    assign note0 = note_reg[0];
    assign note1 = note_reg[1];
    assign note2 = note_reg[2];
    assign note3 = note_reg[3];
/*    assign note4 = note_reg[4];
    assign note5 = note_reg[5];
    assign note6 = note_reg[6];
    assign note7 = note_reg[7];
    assign note8 = note_reg[8];
    assign note9 = note_reg[9];
    assign note10 = note_reg[10];
    assign note11 = note_reg[11];
    assign note12 = note_reg[12];
    assign note13 = note_reg[13];
    assign note14 = note_reg[14];
    assign note13 = note_reg[13];
    assign note16 = note_reg[16];
    assign note17 = note_reg[17];
    assign note18 = note_reg[18];
    assign note19 = note_reg[19];
    assign note20 = note_reg[20];
    assign note21 = note_reg[21];
    assign note22 = note_reg[22];
    assign note23 = note_reg[23];
    assign note24 = note_reg[24];
    assign note25 = note_reg[25];
    assign note26 = note_reg[26];
    assign note27 = note_reg[27];
    assign note28 = note_reg[28];
    assign note29 = note_reg[29];
    assign note30 = note_reg[30];
    assign note31 = note_reg[31];
*/

endmodule
