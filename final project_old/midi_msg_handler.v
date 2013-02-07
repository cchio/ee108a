// midi_msg_handler
// This module reacts to all received midi messages.
// The module accepts new messages and a signal to report when updating may
// occur.
// Updating of states is done before this signal, but note modules will not be
// notified until later. So note modules must store inputs in registers and not
// just on wires.
// An external module must receive note updates and output them to each note 
// module.


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
    input [31:0] notes_playing,
    input ready_to_update,
    output reg [7:0] multiplier,
    output reg [15:0] controller_values,
    output [4:0] write_addr,
    output [15:0] write_values,
    output reg write_en,
    output reg update_all,
    output reg [31:0] update_note
);

    wire [5:0] num_notes = notes_playing[0] + notes_playing[1]
      + notes_playing[2] + notes_playing[3] + notes_playing[4] + notes_playing[5]
      + notes_playing[6] + notes_playing[7] + notes_playing[8] + notes_playing[9]
      + notes_playing[10] + notes_playing[11] + notes_playing[12]
      + notes_playing[13] + notes_playing[14] + notes_playing[15]
      + notes_playing[16] + notes_playing[17] + notes_playing[18]
      + notes_playing[19] + notes_playing[20] + notes_playing[21]
      + notes_playing[22] + notes_playing[23] + notes_playing[24]
      + notes_playing[25] + notes_playing[26] + notes_playing[27]
      + notes_playing[28] + notes_playing[29] + notes_playing[30]
      + notes_playing[31];

    reg [3:0] next_state;
    wire [3:0] curr_state;
    wire [4:0] open_note;
    wire [7:0] temp_mult;
    reg note_tracker_en;
    wire [4:0] note_tracker_dout;
    reg [31:0] track_updates;
    reg track_update_all;

    // wire assignments
    assign write_addr = ((msg[7:4] == 4'h8) || (msg[23:16] == 8'h00))
      ? note_tracker_dout : open_note;
    assign write_values = (msg[7:4] == 4'h9) ? msg[23:8] : {8'b0, msg[15:8]};


    // RAM/ROM/FF instantiations

    dffr #(.WIDTH(4)) fsm_state (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(curr_state)
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
            controller_values = 14'b0;
            write_en = 1'b0;
            update_all = 1'b0;
            track_update_all = 1'b0;
            update_note = 32'b0;
            track_updates = 32'b0;
            multiplier = 8'b0;
            note_tracker_en = 1'b0;
        end
        else if (curr_state == `IDLE) begin
            update_all = 1'b0;
            track_update_all = 1'b0;
            update_note = 32'b0;
            track_updates = 32'b0;

            if (ready_to_update) multiplier = temp_mult;

            if (new_msg) next_state = `HANDLE;
            else next_state = curr_state;
        end
        else if (curr_state == `HANDLE) begin
            casex (msg[7:0])
              8'h8x: next_state = `NOTE_OFF;
              8'h9x: begin
                if (msg[23:16] == 8'b0) next_state = `NOTE_OFF;
                else next_state = `NOTE_ON;
              end
              8'hBx: next_state = `CONTROLLER;
              default: next_state = IDLE;
            endcase
        end
        else if (curr_state == `NOTE_OFF) begin
            write_en = 1'b1;
            track_updates[note_tracker_dout] = 1'b1;
            next_state = `WAIT;
        end
        else if (curr_state == `NOTE_ON) begin
            if (num_notes == 6'd32) next_state = `IDLE;
            else begin
                note_tracker_en = 1'b1;
                write_en = 1'b1;
                track_updates[open_note] = 1'b1;
                next_state = `WAIT;
            end
        end
        else if (curr_state == `CONTROLLER) begin
            controller_values = msg[23:8];
            track_update_all = 1'b1;
            next_state = `WAIT;
        end
        else if (curr_state == `WAIT) begin
            note_tracker_en = 1'b0;
            write_en = 1'b0;

            if (ready_to_update) next_state = `DONE;
        end
        else begin
            update_all = track_update_all;
            update_note = track_updates;
            multiplier = temp_mult;
            next_state = `IDLE;
        end
    end

endmodule
