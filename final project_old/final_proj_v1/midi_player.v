module midi_player (
    input clk,
    input reset,
    input new_frame,
    input new_byte_ready,
    input [7:0] new_byte,

    output [15:0] sample_out,
    output new_sample_generated
);

    wire new_msg, update_all, write_en, latch_sample, samples_ready;
    wire generate_next;
    wire [23:0] msg;
    wire [31:0] notes_playing, update_note;
    wire [7:0] multiplier;
    wire [4:0] write_addr;
    wire [15:0] write_values, next_sample, controller_values;
    wire [15:0] note_values [31:0];
    wire [511:0] samples;


    // assigns
    assign new_sample_generated = generate_next;


    // midi message capture
    midi_msg_capture msg_capture (
        .clk(clk),
        .reset(reset),
        .new_byte_ready(new_byte_ready),
        .new_byte(new_byte),
        .new_msg(new_msg),
        .msg(msg)
    );

    // midi message handler
    midi_msg_handler msg_handler (
        .clk(clk),
        .reset(reset),
        .new_msg(new_msg),
        .msg(msg),
        .notes_playing(notes_playing),
        .ready_to_update(latch_sample),
        .update_mixer(samples_ready),

        .multiplier(multiplier),
        .controller_values(controller_values),
        .write_addr(write_addr),
        .write_values(write_values),
        .write_en(write_en),
        .update_all(update_all),
        .update_note(update_note)
    );


    // note status register
    midi_note_reg note_reg (
        .clk(clk),
        .addr(write_addr),
        .din(write_values),
        .write_en(write_en),

        .note0(note_values[0]),
        .note1(note_values[1]),
        .note2(note_values[2]),
        .note3(note_values[3]),
        .note4(note_values[4]),
        .note5(note_values[5]),
        .note6(note_values[6]),
        .note7(note_values[7]),
        .note8(note_values[8]),
        .note9(note_values[9]),
        .note10(note_values[10]),
        .note11(note_values[11]),
        .note12(note_values[12]),
        .note13(note_values[13]),
        .note14(note_values[14]),
        .note15(note_values[15]),
        .note16(note_values[16]),
        .note17(note_values[17]),
        .note18(note_values[18]),
        .note19(note_values[19]),
        .note20(note_values[20]),
        .note21(note_values[21]),
        .note22(note_values[22]),
        .note23(note_values[23]),
        .note24(note_values[24]),
        .note25(note_values[25]),
        .note26(note_values[26]),
        .note27(note_values[27]),
        .note28(note_values[28]),
        .note29(note_values[29]),
        .note30(note_values[30]),
        .note31(note_values[31])
    );


    // 32 polyphony mixer
    polyphony32_mixer mixer (
        .clk(clk),
        .reset(reset),
        .multiplier(multiplier),
        .samples_ready(samples_ready),
        .samples(samples),
        .sample_ready(latch_sample),
        .sample(next_sample)
    );


    // codec conditioner
    codec_conditioner conditioner (
        .clk(clk),
        .reset(reset),
        .new_sample_in(next_sample),
        .latch_new_sample_in(latch_sample),
        .new_frame(new_frame),
        .generate_next_sample(generate_next),
        .valid_sample(sample_out)
    );

    // 32 notes

    midi_note note0 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[0]),
        .controller_values(controller_values),
        .note_values(note_values[0]),
        .generate_next(generate_next),

        .note_playing(notes_playing[0]),
        .sample_out_ready(samples_ready),
        .sample_out(samples[15:0])
    );


    midi_note note1 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[1]),
        .controller_values(controller_values),
        .note_values(note_values[1]),
        .generate_next(generate_next),

        .note_playing(notes_playing[1]),
        .sample_out_ready(),
        .sample_out(samples[31:16])
    );


    midi_note note2 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[2]),
        .controller_values(controller_values),
        .note_values(note_values[2]),
        .generate_next(generate_next),

        .note_playing(notes_playing[2]),
        .sample_out_ready(),
        .sample_out(samples[47:32])
    );


    midi_note note3 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[3]),
        .controller_values(controller_values),
        .note_values(note_values[3]),
        .generate_next(generate_next),

        .note_playing(notes_playing[3]),
        .sample_out_ready(),
        .sample_out(samples[63:48])
    );


    midi_note note4 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[4]),
        .controller_values(controller_values),
        .note_values(note_values[4]),
        .generate_next(generate_next),

        .note_playing(notes_playing[4]),
        .sample_out_ready(),
        .sample_out(samples[79:64])
    );


    midi_note note5 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[5]),
        .controller_values(controller_values),
        .note_values(note_values[5]),
        .generate_next(generate_next),

        .note_playing(notes_playing[5]),
        .sample_out_ready(),
        .sample_out(samples[95:80])
    );


    midi_note note6 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[6]),
        .controller_values(controller_values),
        .note_values(note_values[6]),
        .generate_next(generate_next),

        .note_playing(notes_playing[6]),
        .sample_out_ready(),
        .sample_out(samples[111:96])
    );


    midi_note note7 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[7]),
        .controller_values(controller_values),
        .note_values(note_values[7]),
        .generate_next(generate_next),

        .note_playing(notes_playing[7]),
        .sample_out_ready(),
        .sample_out(samples[127:112])
    );


    midi_note note8 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[8]),
        .controller_values(controller_values),
        .note_values(note_values[8]),
        .generate_next(generate_next),

        .note_playing(notes_playing[8]),
        .sample_out_ready(),
        .sample_out(samples[143:128])
    );


    midi_note note9 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[9]),
        .controller_values(controller_values),
        .note_values(note_values[9]),
        .generate_next(generate_next),

        .note_playing(notes_playing[9]),
        .sample_out_ready(),
        .sample_out(samples[159:144])
    );


    midi_note note10 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[10]),
        .controller_values(controller_values),
        .note_values(note_values[10]),
        .generate_next(generate_next),

        .note_playing(notes_playing[10]),
        .sample_out_ready(),
        .sample_out(samples[175:160])
    );


    midi_note note11 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[11]),
        .controller_values(controller_values),
        .note_values(note_values[11]),
        .generate_next(generate_next),

        .note_playing(notes_playing[11]),
        .sample_out_ready(),
        .sample_out(samples[191:176])
    );


    midi_note note12 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[12]),
        .controller_values(controller_values),
        .note_values(note_values[12]),
        .generate_next(generate_next),

        .note_playing(notes_playing[12]),
        .sample_out_ready(),
        .sample_out(samples[207:192])
    );


    midi_note note13 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[13]),
        .controller_values(controller_values),
        .note_values(note_values[13]),
        .generate_next(generate_next),

        .note_playing(notes_playing[13]),
        .sample_out_ready(),
        .sample_out(samples[223:208])
    );


    midi_note note14 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[14]),
        .controller_values(controller_values),
        .note_values(note_values[14]),
        .generate_next(generate_next),

        .note_playing(notes_playing[14]),
        .sample_out_ready(),
        .sample_out(samples[239:224])
    );


    midi_note note15 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[15]),
        .controller_values(controller_values),
        .note_values(note_values[15]),
        .generate_next(generate_next),

        .note_playing(notes_playing[15]),
        .sample_out_ready(),
        .sample_out(samples[255:240])
    );


    midi_note note16 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[16]),
        .controller_values(controller_values),
        .note_values(note_values[16]),
        .generate_next(generate_next),

        .note_playing(notes_playing[16]),
        .sample_out_ready(),
        .sample_out(samples[271:256])
    );


    midi_note note17 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[17]),
        .controller_values(controller_values),
        .note_values(note_values[17]),
        .generate_next(generate_next),

        .note_playing(notes_playing[17]),
        .sample_out_ready(),
        .sample_out(samples[287:272])
    );


    midi_note note18 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[18]),
        .controller_values(controller_values),
        .note_values(note_values[18]),
        .generate_next(generate_next),

        .note_playing(notes_playing[18]),
        .sample_out_ready(),
        .sample_out(samples[303:288])
    );


    midi_note note19 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[19]),
        .controller_values(controller_values),
        .note_values(note_values[19]),
        .generate_next(generate_next),

        .note_playing(notes_playing[19]),
        .sample_out_ready(),
        .sample_out(samples[319:304])
    );


    midi_note note20 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[20]),
        .controller_values(controller_values),
        .note_values(note_values[20]),
        .generate_next(generate_next),

        .note_playing(notes_playing[20]),
        .sample_out_ready(),
        .sample_out(samples[335:320])
    );


    midi_note note21 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[21]),
        .controller_values(controller_values),
        .note_values(note_values[21]),
        .generate_next(generate_next),

        .note_playing(notes_playing[21]),
        .sample_out_ready(),
        .sample_out(samples[351:336])
    );


    midi_note note22 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[22]),
        .controller_values(controller_values),
        .note_values(note_values[22]),
        .generate_next(generate_next),

        .note_playing(notes_playing[22]),
        .sample_out_ready(),
        .sample_out(samples[367:352])
    );


    midi_note note23 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[23]),
        .controller_values(controller_values),
        .note_values(note_values[23]),
        .generate_next(generate_next),

        .note_playing(notes_playing[23]),
        .sample_out_ready(),
        .sample_out(samples[383:368])
    );


    midi_note note24 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[24]),
        .controller_values(controller_values),
        .note_values(note_values[24]),
        .generate_next(generate_next),

        .note_playing(notes_playing[24]),
        .sample_out_ready(),
        .sample_out(samples[399:384])
    );


    midi_note note25 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[25]),
        .controller_values(controller_values),
        .note_values(note_values[25]),
        .generate_next(generate_next),

        .note_playing(notes_playing[25]),
        .sample_out_ready(),
        .sample_out(samples[415:400])
    );


    midi_note note26 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[26]),
        .controller_values(controller_values),
        .note_values(note_values[26]),
        .generate_next(generate_next),

        .note_playing(notes_playing[26]),
        .sample_out_ready(),
        .sample_out(samples[431:416])
    );


    midi_note note27 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[27]),
        .controller_values(controller_values),
        .note_values(note_values[27]),
        .generate_next(generate_next),

        .note_playing(notes_playing[27]),
        .sample_out_ready(),
        .sample_out(samples[447:432])
    );


    midi_note note28 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[28]),
        .controller_values(controller_values),
        .note_values(note_values[28]),
        .generate_next(generate_next),

        .note_playing(notes_playing[28]),
        .sample_out_ready(),
        .sample_out(samples[463:448])
    );


    midi_note note29 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[29]),
        .controller_values(controller_values),
        .note_values(note_values[29]),
        .generate_next(generate_next),

        .note_playing(notes_playing[29]),
        .sample_out_ready(),
        .sample_out(samples[479:464])
    );


    midi_note note30 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[30]),
        .controller_values(controller_values),
        .note_values(note_values[30]),
        .generate_next(generate_next),

        .note_playing(notes_playing[30]),
        .sample_out_ready(),
        .sample_out(samples[495:480])
    );


    midi_note note31 (
        .clk(clk),
        .reset(reset),
        .update_all_notes(update_all),
        .update_note(update_note[31]),
        .controller_values(controller_values),
        .note_values(note_values[31]),
        .generate_next(generate_next),

        .note_playing(notes_playing[31]),
        .sample_out_ready(),
        .sample_out(samples[511:496])
    );

endmodule
