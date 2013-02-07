// midi_msg_handler
// This module reacts to all received midi messages.
// The module accepts new messages and a signal to report when updating may
// occur.
// Updating of states is done before this signal, but note modules will not be
// notified until later. So note modules must store inputs in registers and not
// just on wires.
// An external module must receive note updates and output them to each note
// module.


`include "num_notes.v"
`define IDLE 4'd0
`define HANDLE 4'd1
`define NOTE_OFF 4'd2
`define NOTE_ON 4'd3
`define CONTROLLER 4'd4
`define WAIT 4'd5
`define DONE 4'd6

module midi_msg_handler (
    input clk,
    input reset,
    input new_msg,
    input [23:0] msg,
    input [`NUM_NOTES-1:0] notes_playing,
    input ready_to_update,
    input update_mixer,

    output [7:0] multiplier,
    output [13:0] controller_values,
    output [4:0] write_addr,
    output [13:0] write_values,
    output write_en,
    output update_all,
    output [`NUM_NOTES-1:0] update_note,
    output reg waiting
);

    wire [5:0] num_notes = notes_playing[0] + notes_playing[1]
      + notes_playing[2] + notes_playing[3];
/*      + notes_playing[4] + notes_playing[5]
      + notes_playing[6] + notes_playing[7] + notes_playing[8] + notes_playing[9]
      + notes_playing[10] + notes_playing[11] + notes_playing[12]
      + notes_playing[13] + notes_playing[14] + notes_playing[15]
      + notes_playing[16] + notes_playing[17] + notes_playing[18]
      + notes_playing[19] + notes_playing[20] + notes_playing[21]
      + notes_playing[22] + notes_playing[23] + notes_playing[24]
      + notes_playing[25] + notes_playing[26] + notes_playing[27]
      + notes_playing[28] + notes_playing[29] + notes_playing[30]
      + notes_playing[31];
*/

    reg [3:0] next_state;
    wire [3:0] curr_state;
    wire [4:0] open_note;
    wire [7:0] temp_mult;
    reg [5:0] prev_num_notes1;
    wire [5:0] prev_num_notes;
    reg [7:0] multiplier1;
    wire note_tracker_en;
    wire [4:0] note_tracker_dout;
    reg [`NUM_NOTES-1:0] track_updates1;
    wire [`NUM_NOTES-1:0] track_updates;
    reg track_update_all1;
    wire track_update_all;
    reg [13:0] controller_values1;

    // wire assignments
    assign write_addr = ((msg[7:4] == 4'h8) || (msg[23:16] == 8'h00))
      ? note_tracker_dout : open_note;
    assign write_values = (msg[7:4] == 4'h9) ? {msg[22:16], msg[14:8]}
      : {7'b0, msg[14:8]};
    assign write_en = (curr_state == `NOTE_OFF) ||
      ((curr_state == `NOTE_ON) && (num_notes != 6'd32));
    assign note_tracker_en = (curr_state == `NOTE_ON) &&
      (num_notes != `NUM_NOTES);
    assign update_all = (curr_state == `DONE)
      ? track_update_all : 1'b0;
    assign update_note = (curr_state == `DONE)
      ? track_updates : 4'b0; //cop-out fix


    // RAM/ROM/FF instantiations

    dffr #(.WIDTH(4)) fsm_state (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(curr_state)
    );


    dffr #(.WIDTH(`NUM_NOTES)) note_updates_ff (
        .clk(clk),
        .r(reset),
        .d(track_updates1),
        .q(track_updates)
    );

    dffr #(.WIDTH(14)) controller_values_ff (
        .clk(clk),
        .r(reset),
        .d(controller_values1),
        .q(controller_values)
    );


    dffr update_all_ff (
        .clk(clk),
        .r(reset),
        .d(track_update_all1),
        .q(track_update_all)
    );


    dffr #(.WIDTH(8)) multiplier_ff (
        .clk(clk),
        .r(reset),
        .d(multiplier1),
        .q(multiplier)
    );


    dffr #(.WIDTH(6)) prev_num_notes_ff (
        .clk(clk),
        .r(reset),
        .d(prev_num_notes1),
        .q(prev_num_notes)
    );


    mix_multiplier_rom mult_rom (
        .clk(clk),
        .addr((num_notes > 6'b0) ? (num_notes-6'b1) : 6'b0),
        .dout(temp_mult)
    );

    ram_1w2r #(.WIDTH(5),.DEPTH(7)) note_tracker (
        .clka(clk),
        .wea(note_tracker_en),
        .addra(msg[14:8]),
        .douta(note_tracker_dout),
        .dina(open_note),
        .clkb(),
        .addrb(),
        .doutb()
    );

    next_midi_note available_note (
        .clk(clk),
        .reset(reset),
        .notes_playing(notes_playing),
        .note(open_note)
    );

    // this block handles new messages as they come in
    always @(*) begin
        if (reset) begin
            next_state = `IDLE;
            controller_values1 = 14'b0;
            track_update_all1 = 1'b0;
            track_updates1 = 4'b0; //cop-out fix
	    waiting = 1'b0;
        end
        else if (curr_state == `IDLE) begin
            controller_values1 = controller_values;
            track_update_all1 = 1'b0;
            track_updates1 = 4'b0; //cop-out fix
	    waiting = 1'b0;

            if (new_msg) next_state = `HANDLE;
            else next_state = curr_state;
        end
        else if (curr_state == `HANDLE) begin
            controller_values1 = controller_values;
            track_updates1 = track_updates;
            track_update_all1 = track_update_all;
	    waiting = 1'b0;
            casex (msg[7:0])
              8'h8x: next_state = `NOTE_OFF;
              8'h9x: begin
                if (msg[23:16] == 8'b0) next_state = `NOTE_OFF;
                else next_state = `NOTE_ON;
              end
              8'hBx: next_state = `CONTROLLER;
              default: next_state = `IDLE;
            endcase
        end
        else if (curr_state == `NOTE_OFF) begin
            controller_values1 = controller_values;
            //track_updates1[note_tracker_dout] = 1'b1; //BIT!!!
            track_updates1 = track_updates | (1 << note_tracker_dout);
            track_update_all1 = track_update_all;
            next_state = `WAIT;
	    waiting = 1'b0;
        end
        else if (curr_state == `NOTE_ON) begin
            controller_values1 = controller_values;
            track_update_all1 = track_update_all;
	    waiting = 1'b0;
            if (num_notes == `NUM_NOTES) begin
                next_state = `IDLE;
                track_updates1 = track_updates;
            end
            else begin
                //track_updates1[open_note] = 1'b1; //BIT!!!
                track_updates1 = track_updates | (1 << open_note);
                next_state = `WAIT;
            end
        end
        else if (curr_state == `CONTROLLER) begin
            track_updates1 = track_updates;
            controller_values1 = {msg[22:16], msg[14:8]};
            track_update_all1 = 1'b1;
            next_state = `WAIT;
	    waiting = 1'b0;
        end
        else if (curr_state == `WAIT) begin
            controller_values1 = controller_values;
            track_update_all1 = track_update_all;
            track_updates1 = track_updates;
	    waiting = 1'b1;
            if (ready_to_update) next_state = `DONE;
            else next_state = curr_state;
        end
        else begin
            controller_values1 = controller_values;
            track_update_all1 = track_update_all;
            next_state = `IDLE;
            track_updates1 = track_updates;
	    waiting = 1'b0;
        end
    end


    // This block updates the multiplier for the mixer when the number of notes
    // changes
    always @(*) begin
        if (reset) begin
            multiplier1 = 8'b0;
            prev_num_notes1 = 6'b0;
        end
        else if (num_notes != prev_num_notes) begin
            if (update_mixer) begin
                multiplier1 = temp_mult;
                prev_num_notes1 = num_notes;
            end
            else begin
                multiplier1 = multiplier;
                prev_num_notes1 = prev_num_notes;
            end
        end
        else begin
            multiplier1 = temp_mult;
            prev_num_notes1 = num_notes;
        end
    end

endmodule
