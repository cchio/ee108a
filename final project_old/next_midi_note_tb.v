module next_midi_note_tb();

    reg clk, rst;
    reg [31:0] playing;
    wire [4:0] note;

    next_midi_note next (
        .clk(clk),
        .reset(rst),
        .notes_playing(playing),
        .note(note)
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
        playing = ~32'b0;
        @(negedge rst);
        @(negedge clk);
        $monitor("clk %b, playing %b, count %d, note %d", clk, playing, next.count,
          note);

        playing = ~32'd32;
        $display("should output 5");
        #360;
        playing = ~5'd8;
        $display("should output 3");
        #360;
        playing = ~5'b1;
        $display("should output 0");
        #360;

        $finish;
    end

endmodule
