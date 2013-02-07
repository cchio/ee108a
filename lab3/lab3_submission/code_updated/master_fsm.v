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

    wire [2:0] fsm_state, state_out;
    reg [2:0] next1;

    dffr #(3'd3) flop (.clk(clk), .r(reset), .d(next1), .q(state_out));
    
    assign fsm_state = reset ? 3'b0 : state_out;

    //Flipflop logic to avoid changing state more than once for one press of next
    wire stateChanged, stateChangeOut;
    reg stateChanged1;

    dffr stateChange(.clk(clk), .r(reset), .d(stateChanged), .q(stateChangeOut));
    assign stateChanged = reset ? 1'b0 : stateChanged1;

    always @(*) begin
	if(next & ~stateChangeOut) begin
		next1 = (fsm_state != 3'b101) ? (fsm_state + 1) : 3'b000;
		stateChanged1 = 1'b1;
	end
	
	else begin
		next1 = fsm_state;
		stateChanged1 = 1'b0;
	end
    end
    
    // Instantiations of the one_pulse module for each shift outputs
    wire leftin, rightin;

    one_pulse leftpulse(.clk(clk), .reset(reset),.in(down_button),.out(leftin));
    one_pulse rightpulse(.clk(clk),.reset(reset),.in(up_button),.out(rightin));

    // use an always block to modify the state when necessary
 /*   always @(*) begin
        if (reset)
        begin
            next1 = 3'b000;
        end

        if (next)
        begin
            if (fsm_state != 3'b101)
                fsm_state = fsm_state + 1'b1;
            else
                fsm_state = 3'b000;
        end

	else if(next) begin
		case(fsm_state)
			3'b000: next1 = 3'b001;
    	  		3'b001: next1 = 3'b010;
          		3'b010: next1 = 3'b011;
         		3'b011: next1 = 3'b100;
		        3'b100: next1 = 3'b101;
     		        3'b101: next1 = 3'b000;
     	     		default: next1 = 3'b000;
		endcase
	end
	
	else begin
		next1 = fsm_state;
	end
    end
*/
    // This always block sets the mux_sel output based on the state
    always @(*) begin
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
    assign left1 = (leftin & (fsm_state == 3'b011));
    assign right1 = (rightin & (fsm_state == 3'b011));
    assign left2 = (leftin & (fsm_state == 3'b101));
    assign right2 = (rightin & (fsm_state == 3'b101));

endmodule
