module wave_capture (
    input clk,
    input reset,
    input new_sample_ready,
    input [15:0] new_sample_in,
    input wave_display_idle,
    output [8:0] write_address,
    output write_enable,
    output [7:0] write_sample,
    output read_index
);
    // counter for addressing
    wire [7:0] counter;

    wire done_writing;
    wire curr_state_out;
    reg curr_state_in;
    wire flip_index;
    reg [2:0] write_enable_in;
    wire [2:0] write_enable_out;

    // This portion keeps track of the current and previous sample (for watching
    // for zero crossings)
    wire [15:0] curr_sample_out, prev_sample_out;
    reg [15:0] curr_sample_in, prev_sample_in;
    wire zero_crossing = ((prev_sample_out[15] == 1'b1) &&
      (curr_sample_out[15] == 1'b0));

    // flip flops for sample tracking
    dffr #(.WIDTH(16)) currSample (
        .clk(clk),
        .r(reset),
        .d(curr_sample_in),
        .q(curr_sample_out)
    );

    dffr #(.WIDTH(16)) prevSample (
        .clk(clk),
        .r(reset),
        .d(prev_sample_in),
        .q(prev_sample_out)
    );

    // Change sample values each time a new sample is ready
    always @(*) begin
        if (reset) begin
            curr_sample_in = 16'b0;
            prev_sample_in = 16'b0;
        end
        else if (new_sample_ready) begin
            prev_sample_in = curr_sample_out;
            curr_sample_in = new_sample_in;
        end
        else begin
            curr_sample_in = curr_sample_out;
            prev_sample_in = prev_sample_out;
        end
    end

// This portion handles setting the write outputs
    //assign write_sample = (new_sample_in[15] == 1'b1) ? 8'd127 + {1'b0, new_sample_in[14:8]} : 8'd127 - new_sample_in[15:8];
    assign write_sample = 8'd127 - new_sample_in[15:8];
    assign write_address = {~read_index, counter};

    preset_counter #(.WIDTH(8),.MAX(~8'b0)) cnt (
        .clk(clk),
        .reset(reset),
        .beat(new_sample_ready),
        .enable(curr_state_out || (counter != 8'b0)),
        .count(counter)
    );

    // handle timing for write_enable

    dffr #(.WIDTH(3)) wr_en (
        .clk(clk),
        .r(reset),
        .d(write_enable_in),
        .q(write_enable_out)
    );

    assign write_enable = (write_enable_out == 2'b11) ? 1'b1 : 1'b0;

    always @(*) begin
        if (new_sample_ready && curr_state_out) write_enable_in = 1'b1;
        else if (~new_sample_ready & ~curr_state_out & zero_crossing)
            write_enable_in = 1'b1;
        else if (write_enable_out == 3'b100) write_enable_in = 1'b0;
        else if (write_enable_out) write_enable_in = write_enable_out + 1'b1;
        else write_enable_in = write_enable_out;
    end

    // This portion handles the wave_capture FSM
    
    // State flip flop
    dffr fsm (
        .clk(clk),
        .r(reset),
        .d(curr_state_in),
        .q(curr_state_out)
    );

// Switch to armed mode when done writing samples

    assign done_writing = (curr_state_out && write_enable && (counter == ~(8'b0))) ?
      1'b1 : 1'b0;

    // handles switching states appropriately
    always @(*) begin
        if (curr_state_out == 1'b0)
            curr_state_in = (zero_crossing) ? 1'b1 : 1'b0;
        else
            curr_state_in = (done_writing) ? 1'b0 : 1'b1;
    end

    // This portion handles flipping read_index appropriately

    // instantiation of flip_conditioner
    flip_conditioner fc (
        .clk(clk),
        .reset(reset),
        .wave_display_idle(wave_display_idle),
        .wave_capture_fsm_is_active(curr_state_out),
        .flip_read_index(flip_index)
    );

    // flip flop for holding read_index state
//    reg read_index_in;

    dffre index (
        .clk(clk),
        .r(reset),
        .en(flip_index),
        .d(~read_index),
        .q(read_index)
    );

/*    always @(*) begin
        if (reset) read_index_in = 1'b0;
        else if (flip_index || (read_index != read_index_in))
            read_index_in = ~read_index;
        else read_index_in = read_index;
    end
*/


endmodule
