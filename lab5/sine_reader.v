`define MAX_ADDR 20'b11111111111111111111
`define MIN_ADDR 20'b0
`define ONE 20'b00000000010000000000

module sine_reader(
    input clk,
    input reset,
    input [19:0] step_size,
    input generate_next,

    output sample_ready,
    output [15:0] sample
);

    wire [21:0] curAddr;
    reg [21:0] nextAddr;

    dffre #(.WIDTH(22)) addr(
        .clk(clk),
        .r(reset),
        .en(generate_next),
        .d(nextAddr),
        .q(curAddr)
    );

    always @(*) begin
        case (curAddr[21:20])
            2'b00: begin
              nextAddr[19:0] = ((`MAX_ADDR - step_size) < curAddr[19:0]) ?
                (`MAX_ADDR - (curAddr[19:0] + step_size + `ONE)) :
                (curAddr[19:0] + step_size);

              nextAddr[21:20] = ((`MAX_ADDR - step_size) <= curAddr[19:0]) ?
                2'b01 : 2'b00;
            end
            2'b01: begin
              nextAddr[19:0] = ((`MIN_ADDR + step_size) > curAddr[19:0]) ?
                (`MIN_ADDR - (curAddr[19:0] - step_size - `ONE)) :
                (curAddr[19:0] - step_size);

              nextAddr[21:20] = ((`MIN_ADDR + step_size) >= curAddr[19:0]) ?
                2'b10 : 2'b01;
            end
            2'b10: begin
              nextAddr[19:0] = ((`MAX_ADDR - step_size) < curAddr[19:0]) ?
                (`MAX_ADDR - (curAddr[19:0] + step_size + `ONE)) :
                (curAddr[19:0] + step_size);

              nextAddr[21:20] = ((`MAX_ADDR - step_size) <= curAddr[19:0]) ?
                2'b11 : 2'b10;
            end
            2'b11: begin
              nextAddr[19:0] = ((`MIN_ADDR + step_size) > curAddr[19:0]) ?
                (`MIN_ADDR - (curAddr[19:0] - step_size - `ONE)) :
                (curAddr[19:0] - step_size);

              nextAddr[21:20] = ((`MIN_ADDR + step_size) >= curAddr[19:0]) ?
                2'b00 : 2'b11;
            end
        endcase
    end

    // Instantiate the sine_rom
    wire [15:0] sine_out;

    sine_rom srom(
        .clk(clk),
        .addr(curAddr[19:10]),
        .dout(sine_out)
    );

    assign sample = ((curAddr[21:20] == 2'b10) | (curAddr[21:20] == 2'b11)) ?
        (16'b0 - sine_out) : sine_out;

    // Use a duration_timer to wait for the sine_rom to change outputs
    duration_timer d(
        .clk(clk),
        .reset(reset),
        .beat(clk),
	.pause(1'b0),
        .load_new_duration(generate_next),
        .duration(6'b10),
        .done(sample_ready)
    );

endmodule
