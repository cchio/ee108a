// Lab 4 testbench
module lab4_top_tb();
    reg clk, reset, next_button, play_button;
    wire new_frame;
    wire [15:0] sample;

    lab4_top #(.BPU_WIDTH(1), .BEAT_COUNT(1000)) dut(
        .clk(clk),
        .left_button(~play_button),
        .right_button(~next_button),
        .up_button(~reset),
        .AC97Clk(1'b0),
        .SData_In(1'b0),
        .AC97Reset_n(),
        .SData_Out(),
        .Sync(),
        .leds_l(),
        .leds_r()
    );

    // Clock and reset
    initial begin
        clk = 1'b0;
        reset = 1'b1;
        repeat (4) #5 clk = ~clk;
        reset = 1'b0;
        forever #5 clk = ~clk;
    end

    // Tests
    integer delay;
    initial begin
        delay = 2000000;
        play_button = 1'b0;
        next_button = 1'b0;
        @(negedge reset);
        @(negedge clk);

        repeat (25) begin
            @(negedge clk);
        end 

        // Start playing
        $display("Starting playing song 0...");
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay) begin
            @(negedge clk);
        end

        // Pause  
        $display("Pause...");
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay/4) begin
            @(negedge clk);
        end


        // Play 
        $display("Resume playing song 0..."); 
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay) begin
            @(negedge clk);
        end



        // Next Song  
        $display("Next song...");
        @(negedge clk);
        next_button = 1'b1;
        @(negedge clk);
        next_button = 1'b0;

        repeat (delay/8) begin
            @(negedge clk);
        end


        // Play
        $display("Starting playing song 1...");  
        @(negedge clk);
        play_button = 1'b1;
        @(negedge clk);
        play_button = 1'b0;

        repeat (delay) begin
            @(negedge clk);
        end

        $finish;
    end

endmodule
