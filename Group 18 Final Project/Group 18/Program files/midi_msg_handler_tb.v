module midi_msg_handler_tb();

    reg clk, rst, ready_to_update, update_mixer, new_msg;
    reg [3:0] playing;
    reg [23:0] msg;
    wire [13:0] controller, note_values;
    wire update_all, wr_en;
    wire [4:0] write_addr;
    wire [7:0] mult;
    wire [3:0] update_note;

    midi_msg_handler handler (
        .clk(clk),
        .reset(rst),
        .new_msg(new_msg),
        .msg(msg),
        .notes_playing(playing),
        .ready_to_update(ready_to_update),
        .update_mixer(update_mixer),
        .controller_values(controller),
        .multiplier(mult),
        .update_all(update_all),
        .write_addr(write_addr),
        .write_values(note_values),
        .write_en(wr_en),
        .update_note(update_note)
    );

    // clocking and reset
    initial begin
        rst = 1'b1;
        clk = 1'b0;
        repeat(4) #5 clk = ~clk;
        rst = 1'b0;
        forever #5 clk = ~clk;
    end

    // tests
    initial begin
        new_msg = 1'b0;
        playing = 4'b0;
        msg = 24'b0;
        ready_to_update = 1'b0;
        update_mixer = 1'b0;
        @(negedge rst);
        @(negedge clk);
        $monitor("new_msg %b, msg %h, playing %b\nready %b, update_mix %b, update_all %b, control %h, addr %d, value %h, wr_en %b, mult %d\nupdate_note %b\n", new_msg, msg, playing, ready_to_update, update_mixer, update_all, controller, write_addr, note_values, wr_en, mult, update_note);

        $display("the controller value should be written with %h", {7'd64,7'd64});
        msg = {8'h40, 8'h40, 8'hB0};
        new_msg = 1'b1;
        @(negedge clk);
        new_msg = 1'b0;
        #100;
        update_mixer = 1'b1;
        @(negedge clk);
        update_mixer = 1'b0;
        #20;
        @(negedge clk);
        ready_to_update = 1'b1;
        @(negedge clk);
        ready_to_update = 1'b0;
        #100;
        @(negedge clk);
        playing = 4'b1;
        #100;
        @(negedge clk);
        update_mixer = 1'b1;
        @(negedge clk);
        update_mixer = 1'b0;
        #20;
        @(negedge clk);
        ready_to_update = 1'b1;
        @(negedge clk);
        ready_to_update = 1'b0;
        #100;
        $display("should write to note 1");
        msg = {8'h40, 8'h3C, 8'h90};
        @(negedge clk);
        new_msg = 1'b1;
        @(negedge clk);
        new_msg = 1'b0;
        #360;
        update_mixer = 1'b1;
        @(negedge clk);
        update_mixer = 1'b0;
        #20;
        @(negedge clk);
        ready_to_update = 1'b1;
        @(negedge clk);
        ready_to_update = 1'b0;
        #100;
        playing = 4'd3;
        #100;
        @(negedge clk);
        update_mixer = 1'b1;
        @(negedge clk);
        update_mixer = 1'b0;
        #20;
        @(negedge clk);
        ready_to_update = 1'b1;
        @(negedge clk);
        ready_to_update = 1'b0;
        #100;
        $display("should write to note 2");
        msg = {8'h7F, 8'h40, 8'h90};
        @(negedge clk);
        new_msg = 1'b1;
        @(negedge clk);
        new_msg = 1'b0;
        #360;
        update_mixer = 1'b1;
        @(negedge clk);
        update_mixer = 1'b0;
        #20;
        @(negedge clk);
        ready_to_update = 1'b1;
        @(negedge clk);
        ready_to_update = 1'b0;
        #100;
        playing = 4'd7;
        #100;
        @(negedge clk);
        update_mixer = 1'b1;
        @(negedge clk);
        update_mixer = 1'b0;
        #20;
        @(negedge clk);
        ready_to_update = 1'b1;
        @(negedge clk);
        ready_to_update = 1'b0;
        #100;
        @(negedge clk);
        msg = {8'h00, 8'h3C, 8'h90};
        new_msg = 1'b1;
        $display("note 1 should be written with %h", {7'd0,7'h3C});
        @(negedge clk);
        new_msg = 1'b0;
        #360;
        update_mixer = 1'b1;
        @(negedge clk);
        update_mixer = 1'b0;
        #20;
        @(negedge clk);
        ready_to_update = 1'b1;
        @(negedge clk);
        ready_to_update = 1'b0;
        #100;
        playing = 4'd5;
        #100;
        @(negedge clk);
        update_mixer = 1'b1;
        @(negedge clk);
        update_mixer = 1'b0;
        #20;
        @(negedge clk);
        ready_to_update = 1'b1;
        @(negedge clk);
        ready_to_update = 1'b0;
        #100;

        $finish;
    end

endmodule
