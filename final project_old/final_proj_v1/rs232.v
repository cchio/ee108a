// rs232
// This module handles receiving/sending rx_data over RS232
//
// Baudrate: 115200

`define HALF_PER 10'd433
`define FULL_PER 10'd867

module rs232 (
    input clk,
    input reset,

    input rx_pin,
    output reg rx_flag, // high for one clock cycle when new rx_data byte is ready
    output [7:0] rx_data_byte, // last rx_data received

    input tx_data_ready, // high for 1 clock cycle when rx_data is ready to be sent
    input [7:0] tx_byte, // rx_data to be sent
    output reg tx_pin,
    output reg tx_busy // high when sending rx_data
);
    // this portion handles RX functionality
    // wires/regs and flip flops for the rx_state and rx_data output
    reg [9:0] rx_next_count;
    wire [9:0] rx_curr_count;
    reg [3:0] rx_next_state;
    wire [3:0] rx_state;
    reg [7:0] rx_data;
    reg rx_data_wr1;
    wire rx_data_wr;

    dffr #(8) rx_byte (
        .clk(clk),
        .r(reset),
        .d(rx_data),
        .q(rx_data_byte)
    );

    dffr rx_rcvd (
        .clk(clk),
        .r(reset),
        .d(rx_data_wr1),
        .q(rx_data_wr)
    );

    dffr #(10) rx_counter (
        .clk(clk),
        .r(reset),
        .d(rx_next_count),
        .q(rx_curr_count)
    );

    dffr #(4) rx_fsm (
        .clk(clk),
        .r(reset),
        .d(rx_next_state),
        .q(rx_state)
    );

    // handle rx_state switchcing, counter incrementing and rx_data reading
    always @(*) begin
        if (reset) begin
            rx_next_state = 4'b0;
            rx_next_count = 10'b0;
            rx_data = 8'b0;
            rx_flag = 1'b0;
            rx_data_wr1 = 1'b0;
        end
        else if ((rx_state == 4'b0) && rx_pin) begin // detects a serial device
            rx_next_state = 4'b0001;
            rx_next_count = 10'b0;
            rx_data = 8'b0;
        end
        else if (rx_state == 4'b0001) begin
            if (~rx_pin) begin
                rx_next_state = rx_state + 1;
                rx_next_count = 10'b0;
                rx_data = rx_data_byte;
            end
            else begin
                rx_next_state = rx_state;
                rx_next_count = 10'b0;
                rx_data = rx_data_byte;
            end

            rx_flag = 1'b0;
        end
        else if (rx_state == 4'b0010) begin
            if (rx_curr_count >= `HALF_PER) begin
                rx_next_state = rx_state + 1;
                rx_next_count = 10'b0;
                rx_data = rx_data_byte;
            end
            else begin
                rx_next_state = rx_state;
                rx_next_count = rx_curr_count + 1;
                rx_data = rx_data_byte;
            end
        end
        else if (rx_state <= 4'd10) begin
            if (rx_curr_count >= `FULL_PER) begin
                if (~rx_data_wr) begin
                    rx_data[rx_state - 3] = rx_pin;
                    rx_data_wr1 = 1'b1;
                end
                else begin
                    rx_next_state = rx_state + 1;
                    rx_next_count = 10'b0;
                    rx_data_wr1 = 1'b0;
                end
            end
            else begin
                rx_next_state = rx_state;
                rx_next_count = rx_curr_count + 1;
                rx_data = rx_data_byte;
            end
        end
        else begin
            if (rx_curr_count >= `FULL_PER) begin
                rx_next_state = 4'b0001;
                rx_next_count = 10'b0;
                rx_data = rx_data_byte;
                rx_flag = 1'b1;
            end
            else begin
                rx_next_state = rx_state;
                rx_next_count = rx_curr_count + 1;
                rx_data = rx_data_byte;
            end
        end
    end


    // this portion handles TX rx_data transmition
    reg [9:0] tx_next_count;
    wire [9:0] tx_curr_count;
    reg [3:0] tx_next_state;
    wire [3:0] tx_state;
    reg [7:0] tx_next_data;
    wire [7:0] tx_data_byte;

    dffr #(8) tx_data (
        .clk(clk),
        .r(reset),
        .d(tx_next_data),
        .q(tx_data_byte)
    );

    dffr #(10) tx_counter (
        .clk(clk),
        .r(reset),
        .d(tx_next_count),
        .q(tx_curr_count)
    );

    dffr #(4) tx_fsm (
        .clk(clk),
        .r(reset),
        .d(tx_next_state),
        .q(tx_state)
    );

    // handle rx_state switchcing, counter incrementing and rx_data writing
    always @(*) begin
        if (reset) begin
            tx_next_state = 4'b0;
            tx_next_count = 10'b0;
            tx_busy = 1'b0;
            tx_pin = 1'b1;
            tx_next_data = 8'b0;
        end
        else if (tx_state == 4'b0) begin
            if (tx_data_ready) begin
                tx_next_data = tx_byte;
                tx_busy = 1'b1;
                tx_next_state = tx_state + 1;
                tx_next_count = 10'b0;
            end
            else begin
                tx_busy = 1'b0;
                tx_next_state = tx_state;
                tx_next_count = 10'b0;
            end
        end
        else if (tx_state == 4'b0001) begin
            if (tx_curr_count == `FULL_PER) begin
                tx_next_state = tx_state + 1;
                tx_next_count = 10'b0;
            end
            else begin
                tx_next_state = tx_state;
                tx_next_count = tx_curr_count + 1;
                tx_pin = 1'b0;
            end
        end
        else if (tx_state <= 4'd9) begin
            if (tx_curr_count == `FULL_PER) begin
                tx_next_state = tx_state + 1;
                tx_next_count = 10'b0;
            end
            else begin
                tx_pin = tx_data_byte[tx_state - 2];
                tx_next_state = tx_state;
                tx_next_count = tx_curr_count + 1;
            end
        end
        else begin
            if (tx_curr_count == `FULL_PER) begin
                tx_next_state = 4'b0;
                tx_next_count = 10'b0;
                tx_pin = 1'b1;
                tx_busy = 1'b0;
            end
            else begin
                tx_pin = 1'b1;
                tx_next_state = tx_state;
                tx_next_count = tx_curr_count + 1;
            end
        end
    end


endmodule
