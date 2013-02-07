////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2010 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: M.63c
//  \   \         Application: netgen
//  /   /         Filename: mcu_synthesis.v
// /___/   /\     Timestamp: Thu Dec  6 02:34:52 2012
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -intstyle ise -insert_glbl true -w -dir netgen/synthesis -ofmt verilog -sim mcu.ngc mcu_synthesis.v 
// Device	: xc5vlx110t-1-ff1136
// Input file	: mcu.ngc
// Output file	: /afs/ir.stanford.edu/class/ee108a/groups/18/final_v1/netgen/synthesis/mcu_synthesis.v
// # of Modules	: 1
// Design Name	: mcu
// Xilinx        : /opt/xilinx/ISE_DS/ISE/
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Command Line Tools User Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module mcu (
  clk, reset, song_done, reset_player, play_button, play, next_button, song
);
  input clk;
  input reset;
  input song_done;
  output reset_player;
  input play_button;
  output play;
  input next_button;
  output [1 : 0] song;
  wire clk_BUFGP_1;
  wire next_button_IBUF_3;
  wire not_play;
  wire play_button_IBUF_10;
  wire reset_IBUF_12;
  wire reset_player_OBUF_14;
  wire song_done_IBUF_20;
  wire [1 : 0] next_song;
  wire [0 : 0] \playFlipFlop/q ;
  wire [1 : 0] \songFlipFlop/q ;
  FDR   \songFlipFlop/q_1  (
    .C(clk_BUFGP_1),
    .D(next_song[1]),
    .R(reset_IBUF_12),
    .Q(\songFlipFlop/q [1])
  );
  FDR   \songFlipFlop/q_0  (
    .C(clk_BUFGP_1),
    .D(next_song[0]),
    .R(reset_IBUF_12),
    .Q(\songFlipFlop/q [0])
  );
  FDR   \playFlipFlop/q_0  (
    .C(clk_BUFGP_1),
    .D(not_play),
    .R(reset_IBUF_12),
    .Q(\playFlipFlop/q [0])
  );
  LUT4 #(
    .INIT ( 16'hFF54 ))
  reset_player_reg1 (
    .I0(play_button_IBUF_10),
    .I1(next_button_IBUF_3),
    .I2(song_done_IBUF_20),
    .I3(reset_IBUF_12),
    .O(reset_player_OBUF_14)
  );
  LUT5 #(
    .INIT ( 32'h000100F0 ))
  not_play1 (
    .I0(song_done_IBUF_20),
    .I1(next_button_IBUF_3),
    .I2(play_button_IBUF_10),
    .I3(reset_IBUF_12),
    .I4(\playFlipFlop/q [0]),
    .O(not_play)
  );
  LUT5 #(
    .INIT ( 32'h00AB0054 ))
  \next_song<0>1  (
    .I0(play_button_IBUF_10),
    .I1(next_button_IBUF_3),
    .I2(song_done_IBUF_20),
    .I3(reset_IBUF_12),
    .I4(\songFlipFlop/q [0]),
    .O(next_song[0])
  );
  LUT6 #(
    .INIT ( 64'h00AB005400FF0000 ))
  \next_song<1>1  (
    .I0(play_button_IBUF_10),
    .I1(song_done_IBUF_20),
    .I2(next_button_IBUF_3),
    .I3(reset_IBUF_12),
    .I4(\songFlipFlop/q [1]),
    .I5(\songFlipFlop/q [0]),
    .O(next_song[1])
  );
  IBUF   reset_IBUF (
    .I(reset),
    .O(reset_IBUF_12)
  );
  IBUF   song_done_IBUF (
    .I(song_done),
    .O(song_done_IBUF_20)
  );
  IBUF   play_button_IBUF (
    .I(play_button),
    .O(play_button_IBUF_10)
  );
  IBUF   next_button_IBUF (
    .I(next_button),
    .O(next_button_IBUF_3)
  );
  OBUF   reset_player_OBUF (
    .I(reset_player_OBUF_14),
    .O(reset_player)
  );
  OBUF   play_OBUF (
    .I(\playFlipFlop/q [0]),
    .O(play)
  );
  OBUF   song_1_OBUF (
    .I(\songFlipFlop/q [1]),
    .O(song[1])
  );
  OBUF   song_0_OBUF (
    .I(\songFlipFlop/q [0]),
    .O(song[0])
  );
  BUFGP   clk_BUFGP (
    .I(clk),
    .O(clk_BUFGP_1)
  );
endmodule


`ifndef GLBL
`define GLBL

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

`endif

