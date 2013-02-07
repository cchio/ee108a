module next_midi_note_tb();

    reg clk, rst;
    reg [3:0] playing;
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
        playing = ~4'b0;
        @(negedge rst);
        @(negedge clk);
        $monitor("clk %b, playing %b, count %d, note %d", clk, playing, next.count,
          note);

        playing = 4'h7;
        $display("should output 3");
        #360;
        playing = 4'hE;
        $display("should output 0");
        #360;
        playing = 4'h3;
        $display("should output 2");
        #360;

        $finish;
    end

endmodule
