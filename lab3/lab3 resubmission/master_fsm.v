//  master_fsm
// This module is the state machine which outputs a mix selector and blinker shift (left and right)
// outputs
//
// Inputs
// clk -- the system clock
// reset -- resets the state to a default off state
// up_button -- increments the blink rate up
// down_button -- decrements the blink rate
// next -- moves the state machine to the next state
//
// Output:
// left1, right1 -- increment/decrement outputs to be passed to blinker modules
// left2, right2 -- increment/decrement outputs to be passed to a second blinker module
// mux_sel -- outputs a two bit mix selector (00 for off, 01 for on, 10 for blinker one, 11 for blinker 2)
//

module master_fsm(
    input clk,
    input reset,
    input up_button,
    input down_button,
    input next,
    output wire left1,
    output wire right1,
    output wire left2,
    output wire right2,
    output reg [1:0] mux_sel
);

	wire [2:0] fsm_state;
    reg [2:0] next1;
    dffr #(2'd3) flop (.clk(clk), .r(reset), .d(next1), .q(fsm_state));
    
    
    // Instantiations of the one_pulse module for each shift outputs
    wire left1in, right1in, left2in, right2in;

    one_pulse left1pulse(.clk(clk), .reset(reset),.in(left1in),.out(left1));
    one_pulse right1pulse(.clk(clk),.reset(reset),.in(right1in),.out(right1));
    one_pulse left2pulse(.clk(clk),.reset(reset),.in(left2in),.out(left2));
    one_pulse right2pulse(.clk(clk),.reset(reset),.in(right2in),.out(right2));

    // use an always block to modify the state when necessary
    always @(*) begin
        if (reset)
        begin
            next1 = 3'b000;
        end
/*
        if (next)
        begin
            if (fsm_state != 3'b101)
                fsm_state = fsm_state + 1'b1;
            else
                fsm_state = 3'b000;
        end*/

	else if(next) begin
		case(fsm_state)
			3'b000: next1 = 3'b001;
    	  		3'b001: next1 = 3'b001;
          		3'b010: next1 = 3'b010;
         		3'b011: next1 = 3'b011;
		        3'b100: next1 = 3'b100;
     		        3'b101: next1 = 3'b000;
     	     		default: next1 = 3'b000;
		endcase
	end
	
	else begin
	end
    end

    // This always block sets the mux_sel output based on the state
    always @(*)
    begin

        case (fsm_state)
          3'b000: mux_sel = 2'b00;
          3'b001: mux_sel = 2'b01;
          3'b010: mux_sel = 2'b00;
          3'b011: mux_sel = 2'b10;
          3'b100: mux_sel = 2'b00;
          3'b101: mux_sel = 2'b11;
          default: mux_sel = 2'b00;
        endcase
    end

    // This always block controls the left1/right1 and left2/right2 outputs based
    // on button and FSM states
    assign left1in = (up_button & (fsm_state == 3'b011));
    assign right1in = (down_button & (fsm_state == 3'b011));
    assign left2in = (up_button & (fsm_state == 3'b101));
    assign right2in = (down_button & (fsm_state == 3'b101));

endmodule
