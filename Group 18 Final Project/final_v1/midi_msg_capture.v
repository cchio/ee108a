`define CAPTURE_IDLE 3'd0
`define DELAY1 3'd1
`define CAPTURE_ONE 3'd2
`define DELAY2 3'd3
`define CAPTURE_TWO 3'd4
`define CAPTURE_DONE 3'd5

module midi_msg_capture (
    input clk,
    input reset,
    input new_byte_ready,
    input [7:0] new_byte,
    output new_msg,
    output [23:0] msg
);

    reg [23:0] midi_msg1;
    wire [23:0] midi_msg;
    wire [1:0] data_len;
    reg [2:0] next_state;
    wire [2:0] curr_state;

    assign msg = midi_msg;
    assign new_msg = (curr_state == `CAPTURE_DONE);

    // ROM and flip flop instantiations

    dffr #(.WIDTH(3)) state (
        .clk(clk),
        .r(reset),
        .d(next_state),
        .q(curr_state)
    );

    dffr #(.WIDTH(24)) msg_ff (
        .clk(clk),
        .r(reset),
        .d(midi_msg1),
        .q(midi_msg)
    );

    midi_data_len_lookup msg_data_len (
        .clk(clk),
        .command(midi_msg[7:0]),
        .len(data_len)
    );

    // This block handles capturing incoming midimessages
    always @(*) begin
        if (reset) begin
            next_state = `CAPTURE_IDLE;
            midi_msg1 = 24'b0;
        end
        else if (curr_state == `CAPTURE_IDLE) begin
            if (new_byte_ready) begin
                midi_msg1 = {16'b0, new_byte};
                next_state = `DELAY1;
            end
            else begin
                next_state = curr_state;
                midi_msg1 = midi_msg;
            end
        end
        else if (curr_state == `DELAY1) begin
            next_state = `CAPTURE_ONE;
            midi_msg1 = midi_msg;
        end
        else if (curr_state == `CAPTURE_ONE) begin
            if ((data_len > 2'b0) & new_byte_ready) begin
                midi_msg1 = midi_msg | {8'b0, new_byte, 8'b0};
                next_state = `DELAY2;
            end
            else if (data_len == 2'b0) begin
                next_state = `CAPTURE_DONE;
                midi_msg1 = midi_msg;
            end
            else begin
                next_state = curr_state;
                midi_msg1 = midi_msg;
            end
        end
        else if (curr_state == `DELAY2) begin
            next_state = `CAPTURE_TWO;
            midi_msg1 = midi_msg;
        end
        else if (curr_state == `CAPTURE_TWO) begin
            if ((data_len > 2'b1) & new_byte_ready) begin
                midi_msg1 = midi_msg | {new_byte, 16'b0};
                next_state = `CAPTURE_DONE;
            end
            else if (data_len < 2'd2) begin
                midi_msg1 = midi_msg;
                next_state = `CAPTURE_DONE;
            end
            else begin
                midi_msg1 = midi_msg;
                next_state = curr_state;
            end
        end
        else begin
            midi_msg1 = midi_msg;
            next_state = `CAPTURE_IDLE;
        end
    end

endmodule
