`define MAX_ADDR2 20'b11111111111111111111
`define MIN_ADDR2 20'b0
`define ONE2 20'b00000000010000000000
`define ROM_CYCLES 2'd3


module midi_wave_reader (
    input clk,
    input reset,
    input generate_next,
    input zero,
    input [19:0] step1,
    input [19:0] step2,
    input [19:0] step3,
    input [19:0] step4,
    input [19:0] step5,
    input [19:0] step6,
    input [19:0] step7,
    input [19:0] step8,

    output samples_ready,
    output signed [15:0] sample1,
    output signed [15:0] sample2,
    output signed [15:0] sample3,
    output signed [15:0] sample4,
    output signed [15:0] sample5,
    output signed [15:0] sample6,
    output signed [15:0] sample7,
    output signed [15:0] sample8
);

    reg [21:0] next1, next2, next3, next4, next5, next6, next7, next8;
    wire [21:0] curr1, curr2, curr3, curr4, curr5, curr6, curr7, curr8;
    wire [21:0] curr_array [7:0];
    wire [15:0] rom_out [7:0];
    wire [15:0] out_val;
    reg [3:0] next_state;
    wire [3:0] state;
    wire [1:0] count;


    // assigns
    assign {curr_array[7], curr_array[6], curr_array[5], curr_array[4], curr_array[3],
      curr_array[2], curr_array[1], curr_array[0]} = {curr8, curr7, curr6, curr5, curr4,
      curr3, curr2, curr1};
    assign samples_ready = (count == `ROM_CYCLES) && (state == 4'd8);
    assign  rom_out[0] = (state == 4'd1)
      ? out_val
      : (reset)
        ? 16'b0 : sample1;
    assign  rom_out[1] = (state == 4'd2)
      ? out_val
      : (reset)
        ? 16'b0 : sample2;
    assign  rom_out[2] = (state == 4'd3)
      ? out_val
      : (reset)
        ? 16'b0 : sample3;
    assign  rom_out[3] = (state == 4'd4)
      ? out_val
      : (reset)
        ? 16'b0 : sample4;
    assign  rom_out[4] = (state == 4'd5)
      ? out_val
      : (reset)
        ? 16'b0 : sample5;
    assign  rom_out[5] = (state == 4'd6)
      ? out_val
      : (reset)
        ? 16'b0 : sample6;
    assign  rom_out[6] = (state == 4'd7)
      ? out_val
      : (reset)
        ? 16'b0 : sample7;
    assign  rom_out[7] = (state == 4'd8)
      ? out_val
      : (reset)
        ? 16'b0 : sample8;


    // ROM/FF

    dffr #(.WIDTH(4)) state_ff (
        .clk(clk),
        .r(reset || zero),
        .d(next_state),
        .q(state)
    );


    dffr #(.WIDTH(2)) counter (
        .clk(clk),
        .r(reset || zero),
        .d(((state == 4'b0) || (count == `ROM_CYCLES)) ? 2'b0 : count + 2'b1),
        .q(count)
    );


    dffre #(.WIDTH(22)) addr1 (
        .clk(clk),
        .r(reset || zero),
        .en(generate_next | zero),
        .d(next1),
        .q(curr1)
    );


    dffre #(.WIDTH(22)) addr2 (
        .clk(clk),
        .r(reset || zero),
        .en(generate_next | zero),
        .d(next2),
        .q(curr2)
    );


    dffre #(.WIDTH(22)) addr3 (
        .clk(clk),
        .r(reset || zero),
        .en(generate_next | zero),
        .d(next3),
        .q(curr3)
    );


    dffre #(.WIDTH(22)) addr4 (
        .clk(clk),
        .r(reset || zero),
        .en(generate_next | zero),
        .d(next4),
        .q(curr4)
    );


    dffre #(.WIDTH(22)) addr5 (
        .clk(clk),
        .r(reset || zero),
        .en(generate_next | zero),
        .d(next5),
        .q(curr5)
    );


    dffre #(.WIDTH(22)) addr6 (
        .clk(clk),
        .r(reset || zero),
        .en(generate_next | zero),
        .d(next6),
        .q(curr6)
    );


    dffre #(.WIDTH(22)) addr7 (
        .clk(clk),
        .r(reset || zero),
        .en(generate_next | zero),
        .d(next7),
        .q(curr7)
    );


    dffre #(.WIDTH(22)) addr8 (
        .clk(clk),
        .r(reset || zero),
        .en(generate_next | zero),
        .d(next8),
        .q(curr8)
    );


    dffr #(.WIDTH(16)) sample1_ff (
        .clk(clk),
        .r(reset || zero),
        .d(((curr1[21:20] == 2'b10) | (curr1[21:20] == 2'b11))
          ? (16'b0 - rom_out[0]) : rom_out[0]),
        .q(sample1)
    );


    dffr #(.WIDTH(16)) sample2_ff (
        .clk(clk),
        .r(reset || zero),
        .d(((curr2[21:20] == 2'b10) | (curr2[21:20] == 2'b11))
          ? (16'b0 - rom_out[1]) : rom_out[1]),
        .q(sample2)
    );


    dffr #(.WIDTH(16)) sample3_ff (
        .clk(clk),
        .r(reset || zero),
        .d(((curr3[21:20] == 2'b10) | (curr3[21:20] == 2'b11))
          ? (16'b0 - rom_out[2]) : rom_out[2]),
        .q(sample3)
    );


    dffr #(.WIDTH(16)) sample4_ff (
        .clk(clk),
        .r(reset || zero),
        .d(((curr4[21:20] == 2'b10) | (curr4[21:20] == 2'b11))
          ? (16'b0 - rom_out[3]) : rom_out[3]),
        .q(sample4)
    );


    dffr #(.WIDTH(16)) sample5_ff (
        .clk(clk),
        .r(reset || zero),
        .d(((curr5[21:20] == 2'b10) | (curr5[21:20] == 2'b11))
          ? (16'b0 - rom_out[4]) : rom_out[4]),
        .q(sample5)
    );


    dffr #(.WIDTH(16)) sample6_ff (
        .clk(clk),
        .r(reset || zero),
        .d(((curr6[21:20] == 2'b10) | (curr6[21:20] == 2'b11))
          ? (16'b0 - rom_out[5]) : rom_out[5]),
        .q(sample6)
    );


    dffr #(.WIDTH(16)) sample7_ff (
        .clk(clk),
        .r(reset || zero),
        .d(((curr7[21:20] == 2'b10) | (curr7[21:20] == 2'b11))
          ? (16'b0 - rom_out[6]) : rom_out[6]),
        .q(sample7)
    );


    dffr #(.WIDTH(16)) sample8_ff (
        .clk(clk),
        .r(reset || zero),
        .d(((curr8[21:20] == 2'b10) | (curr8[21:20] == 2'b11))
          ? (16'b0 - rom_out[7]) : rom_out[7]),
        .q(sample8)
    );


    sine_rom srom (
        .clk(clk),
        .addr((state == 4'b0) ? 10'b0 : curr_array[state-4'b1][19:10]),
        .dout(out_val)
    );


    // blocks to calculate each address

    always @(*) begin
        if (zero | reset) next1 = 22'b0;
        else begin
          case (curr1[21:20])
              2'b00: begin
                next1[19:0] = ((`MAX_ADDR2 - step1) < curr1[19:0]) ?
                  (`MAX_ADDR2 - (curr1[19:0] + step1 + `ONE2)) :
                  (curr1[19:0] + step1);

                next1[21:20] = ((`MAX_ADDR2 - step1) <= curr1[19:0]) ?
                2'b01 : 2'b00;
              end
              2'b01: begin
                next1[19:0] = ((`MIN_ADDR2 + step1) > curr1[19:0]) ?
                  (`MIN_ADDR2 - (curr1[19:0] - step1 - `ONE2)) :
                  (curr1[19:0] - step1);

                next1[21:20] = ((`MIN_ADDR2 + step1) >= curr1[19:0]) ?
                  2'b10 : 2'b01;
              end
              2'b10: begin
                next1[19:0] = ((`MAX_ADDR2 - step1) < curr1[19:0]) ?
                  (`MAX_ADDR2 - (curr1[19:0] + step1 + `ONE2)) :
                  (curr1[19:0] + step1);

                next1[21:20] = ((`MAX_ADDR2 - step1) <= curr1[19:0]) ?
                  2'b11 : 2'b10;
              end
              2'b11: begin
                next1[19:0] = ((`MIN_ADDR2 + step1) > curr1[19:0]) ?
                  (`MIN_ADDR2 - (curr1[19:0] - step1 - `ONE2)) :
                  (curr1[19:0] - step1);

                next1[21:20] = ((`MIN_ADDR2 + step1) >= curr1[19:0]) ?
                  2'b00 : 2'b11;
              end
          endcase
        end
    end


    always @(*) begin
        if (zero | reset) next2 = 22'b0;
        else begin
          case (curr2[21:20])
              2'b00: begin
                next2[19:0] = ((`MAX_ADDR2 - step2) < curr2[19:0]) ?
                  (`MAX_ADDR2 - (curr2[19:0] + step2 + `ONE2)) :
                  (curr2[19:0] + step2);

                next2[21:20] = ((`MAX_ADDR2 - step2) <= curr2[19:0]) ?
                2'b01 : 2'b00;
              end
              2'b01: begin
                next2[19:0] = ((`MIN_ADDR2 + step2) > curr2[19:0]) ?
                  (`MIN_ADDR2 - (curr2[19:0] - step2 - `ONE2)) :
                  (curr2[19:0] - step2);

                next2[21:20] = ((`MIN_ADDR2 + step2) >= curr2[19:0]) ?
                  2'b10 : 2'b01;
              end
              2'b10: begin
                next2[19:0] = ((`MAX_ADDR2 - step2) < curr2[19:0]) ?
                  (`MAX_ADDR2 - (curr2[19:0] + step2 + `ONE2)) :
                  (curr2[19:0] + step2);

                next2[21:20] = ((`MAX_ADDR2 - step2) <= curr2[19:0]) ?
                  2'b11 : 2'b10;
              end
              2'b11: begin
                next2[19:0] = ((`MIN_ADDR2 + step2) > curr2[19:0]) ?
                  (`MIN_ADDR2 - (curr2[19:0] - step2 - `ONE2)) :
                  (curr2[19:0] - step2);

                next2[21:20] = ((`MIN_ADDR2 + step2) >= curr2[19:0]) ?
                  2'b00 : 2'b11;
              end
          endcase
        end
    end


    always @(*) begin
        if (zero | reset) next3 = 22'b0;
        else begin
          case (curr3[21:20])
              2'b00: begin
                next3[19:0] = ((`MAX_ADDR2 - step3) < curr3[19:0]) ?
                  (`MAX_ADDR2 - (curr3[19:0] + step3 + `ONE2)) :
                  (curr3[19:0] + step3);

                next3[21:20] = ((`MAX_ADDR2 - step3) <= curr3[19:0]) ?
                2'b01 : 2'b00;
              end
              2'b01: begin
                next3[19:0] = ((`MIN_ADDR2 + step3) > curr3[19:0]) ?
                  (`MIN_ADDR2 - (curr3[19:0] - step3 - `ONE2)) :
                  (curr3[19:0] - step3);

                next3[21:20] = ((`MIN_ADDR2 + step3) >= curr3[19:0]) ?
                  2'b10 : 2'b01;
              end
              2'b10: begin
                next3[19:0] = ((`MAX_ADDR2 - step3) < curr3[19:0]) ?
                  (`MAX_ADDR2 - (curr3[19:0] + step3 + `ONE2)) :
                  (curr3[19:0] + step3);

                next3[21:20] = ((`MAX_ADDR2 - step3) <= curr3[19:0]) ?
                  2'b11 : 2'b10;
              end
              2'b11: begin
                next3[19:0] = ((`MIN_ADDR2 + step3) > curr3[19:0]) ?
                  (`MIN_ADDR2 - (curr3[19:0] - step3 - `ONE2)) :
                  (curr3[19:0] - step3);

                next3[21:20] = ((`MIN_ADDR2 + step3) >= curr3[19:0]) ?
                  2'b00 : 2'b11;
              end
          endcase
        end
    end


    always @(*) begin
        if (zero | reset) next4 = 22'b0;
        else begin
          case (curr4[21:20])
              2'b00: begin
                next4[19:0] = ((`MAX_ADDR2 - step4) < curr4[19:0]) ?
                  (`MAX_ADDR2 - (curr4[19:0] + step4 + `ONE2)) :
                  (curr4[19:0] + step4);

                next4[21:20] = ((`MAX_ADDR2 - step4) <= curr4[19:0]) ?
                2'b01 : 2'b00;
              end
              2'b01: begin
                next4[19:0] = ((`MIN_ADDR2 + step4) > curr4[19:0]) ?
                  (`MIN_ADDR2 - (curr4[19:0] - step4 - `ONE2)) :
                  (curr4[19:0] - step4);

                next4[21:20] = ((`MIN_ADDR2 + step4) >= curr4[19:0]) ?
                  2'b10 : 2'b01;
              end
              2'b10: begin
                next4[19:0] = ((`MAX_ADDR2 - step4) < curr4[19:0]) ?
                  (`MAX_ADDR2 - (curr4[19:0] + step4 + `ONE2)) :
                  (curr4[19:0] + step4);

                next4[21:20] = ((`MAX_ADDR2 - step4) <= curr4[19:0]) ?
                  2'b11 : 2'b10;
              end
              2'b11: begin
                next4[19:0] = ((`MIN_ADDR2 + step4) > curr4[19:0]) ?
                  (`MIN_ADDR2 - (curr4[19:0] - step4 - `ONE2)) :
                  (curr4[19:0] - step4);

                next4[21:20] = ((`MIN_ADDR2 + step4) >= curr4[19:0]) ?
                  2'b00 : 2'b11;
              end
          endcase
        end
    end


    always @(*) begin
        if (zero | reset) next5 = 22'b0;
        else begin
          case (curr5[21:20])
              2'b00: begin
                next5[19:0] = ((`MAX_ADDR2 - step5) < curr5[19:0]) ?
                  (`MAX_ADDR2 - (curr5[19:0] + step5 + `ONE2)) :
                  (curr5[19:0] + step5);

                next5[21:20] = ((`MAX_ADDR2 - step5) <= curr5[19:0]) ?
                2'b01 : 2'b00;
              end
              2'b01: begin
                next5[19:0] = ((`MIN_ADDR2 + step5) > curr5[19:0]) ?
                  (`MIN_ADDR2 - (curr5[19:0] - step5 - `ONE2)) :
                  (curr5[19:0] - step5);

                next5[21:20] = ((`MIN_ADDR2 + step5) >= curr5[19:0]) ?
                  2'b10 : 2'b01;
              end
              2'b10: begin
                next5[19:0] = ((`MAX_ADDR2 - step5) < curr5[19:0]) ?
                  (`MAX_ADDR2 - (curr5[19:0] + step5 + `ONE2)) :
                  (curr5[19:0] + step5);

                next5[21:20] = ((`MAX_ADDR2 - step5) <= curr5[19:0]) ?
                  2'b11 : 2'b10;
              end
              2'b11: begin
                next5[19:0] = ((`MIN_ADDR2 + step5) > curr5[19:0]) ?
                  (`MIN_ADDR2 - (curr5[19:0] - step5 - `ONE2)) :
                  (curr5[19:0] - step5);

                next5[21:20] = ((`MIN_ADDR2 + step5) >= curr5[19:0]) ?
                  2'b00 : 2'b11;
              end
          endcase
        end
    end


    always @(*) begin
        if (zero | reset) next6 = 22'b0;
        else begin
          case (curr6[21:20])
              2'b00: begin
                next6[19:0] = ((`MAX_ADDR2 - step6) < curr6[19:0]) ?
                  (`MAX_ADDR2 - (curr6[19:0] + step6 + `ONE2)) :
                  (curr6[19:0] + step6);

                next6[21:20] = ((`MAX_ADDR2 - step6) <= curr6[19:0]) ?
                2'b01 : 2'b00;
              end
              2'b01: begin
                next6[19:0] = ((`MIN_ADDR2 + step6) > curr6[19:0]) ?
                  (`MIN_ADDR2 - (curr6[19:0] - step6 - `ONE2)) :
                  (curr6[19:0] - step6);

                next6[21:20] = ((`MIN_ADDR2 + step6) >= curr6[19:0]) ?
                  2'b10 : 2'b01;
              end
              2'b10: begin
                next6[19:0] = ((`MAX_ADDR2 - step6) < curr6[19:0]) ?
                  (`MAX_ADDR2 - (curr6[19:0] + step6 + `ONE2)) :
                  (curr6[19:0] + step6);

                next6[21:20] = ((`MAX_ADDR2 - step6) <= curr6[19:0]) ?
                  2'b11 : 2'b10;
              end
              2'b11: begin
                next6[19:0] = ((`MIN_ADDR2 + step6) > curr6[19:0]) ?
                  (`MIN_ADDR2 - (curr6[19:0] - step6 - `ONE2)) :
                  (curr6[19:0] - step6);

                next6[21:20] = ((`MIN_ADDR2 + step6) >= curr6[19:0]) ?
                  2'b00 : 2'b11;
              end
          endcase
        end
    end


    always @(*) begin
        if (zero | reset) next7 = 22'b0;
        else begin
          case (curr7[21:20])
              2'b00: begin
                next7[19:0] = ((`MAX_ADDR2 - step7) < curr7[19:0]) ?
                  (`MAX_ADDR2 - (curr7[19:0] + step7 + `ONE2)) :
                  (curr7[19:0] + step7);

                next7[21:20] = ((`MAX_ADDR2 - step7) <= curr7[19:0]) ?
                2'b01 : 2'b00;
              end
              2'b01: begin
                next7[19:0] = ((`MIN_ADDR2 + step7) > curr7[19:0]) ?
                  (`MIN_ADDR2 - (curr7[19:0] - step7 - `ONE2)) :
                  (curr7[19:0] - step7);

                next7[21:20] = ((`MIN_ADDR2 + step7) >= curr7[19:0]) ?
                  2'b10 : 2'b01;
              end
              2'b10: begin
                next7[19:0] = ((`MAX_ADDR2 - step7) < curr7[19:0]) ?
                  (`MAX_ADDR2 - (curr7[19:0] + step7 + `ONE2)) :
                  (curr7[19:0] + step7);

                next7[21:20] = ((`MAX_ADDR2 - step7) <= curr7[19:0]) ?
                  2'b11 : 2'b10;
              end
              2'b11: begin
                next7[19:0] = ((`MIN_ADDR2 + step7) > curr7[19:0]) ?
                  (`MIN_ADDR2 - (curr7[19:0] - step7 - `ONE2)) :
                  (curr7[19:0] - step7);

                next7[21:20] = ((`MIN_ADDR2 + step7) >= curr7[19:0]) ?
                  2'b00 : 2'b11;
              end
          endcase
        end
    end


    always @(*) begin
        if (zero | reset) next8 = 22'b0;
        else begin
          case (curr8[21:20])
              2'b00: begin
                next8[19:0] = ((`MAX_ADDR2 - step8) < curr8[19:0]) ?
                  (`MAX_ADDR2 - (curr8[19:0] + step8 + `ONE2)) :
                  (curr8[19:0] + step8);

                next8[21:20] = ((`MAX_ADDR2 - step8) <= curr8[19:0]) ?
                2'b01 : 2'b00;
              end
              2'b01: begin
                next8[19:0] = ((`MIN_ADDR2 + step8) > curr8[19:0]) ?
                  (`MIN_ADDR2 - (curr8[19:0] - step8 - `ONE2)) :
                  (curr8[19:0] - step8);

                next8[21:20] = ((`MIN_ADDR2 + step8) >= curr8[19:0]) ?
                  2'b10 : 2'b01;
              end
              2'b10: begin
                next8[19:0] = ((`MAX_ADDR2 - step8) < curr8[19:0]) ?
                  (`MAX_ADDR2 - (curr8[19:0] + step8 + `ONE2)) :
                  (curr8[19:0] + step8);

                next8[21:20] = ((`MAX_ADDR2 - step8) <= curr8[19:0]) ?
                  2'b11 : 2'b10;
              end
              2'b11: begin
                next8[19:0] = ((`MIN_ADDR2 + step8) > curr8[19:0]) ?
                  (`MIN_ADDR2 - (curr8[19:0] - step8 - `ONE2)) :
                  (curr8[19:0] - step8);

                next8[21:20] = ((`MIN_ADDR2 + step8) >= curr8[19:0]) ?
                  2'b00 : 2'b11;
              end
          endcase
        end
    end


    // block to shift through states

    always @(*) begin
        if (reset || zero) next_state = 4'b0;
        else if (state == 4'b0) begin
            if (generate_next) next_state = 4'b1;
            else next_state = state;
        end
        else begin
            if (count == `ROM_CYCLES)
                next_state = (state == 4'd8) ? 4'b0 : state + 4'b1;
            end
            else next_state = state;
        end
    end

endmodule
