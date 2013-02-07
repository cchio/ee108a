/* Module: float_add
 * ---------------------
 * Adds two floating point
 * numbers, a and b. */

module float_add(input wire [7:0] aIn,
		 input wire [7:0] bIn,
		 output wire [7:0] result);

wire [7:0] largest;
wire [7:0] smallest;
wire [4:0] mantissa_Lg;
wire [2:0] exponent_Lg;
wire [4:0] mantissa_Sm;
wire [2:0] exponent_Sm;
wire [4:0] mant_adj;
wire [2:0] distance1;//, distance2;
wire [4:0] mant_sum;
wire dir;
wire [3:0] exp_ex;
//wire [4:0] mant_final_above_zero;
//wire [4:0] mant_final_below_zero;
reg [4:0] mant_final;
reg [2:0] exp_final;

`define RIGHT 1'b1

//Determine which number has the largest exponent
big_number_first bigger(.ain(aIn), .bin(bIn),
			.aout(largest), .bout(smallest));

//Separate exponent and mantissa
assign {exponent_Lg, mantissa_Lg} = largest;
assign {exponent_Sm, mantissa_Sm} = smallest;

/* Find the number of bits by which the mantissa of the smaller
 * number must be shifted*/
assign distance1 = exponent_Lg - exponent_Sm;

//Shift the mantissa of the smaller number
shifter sh(  .in(mantissa_Sm), .distance(distance1),
	.direction(`RIGHT), .out(mant_adj));

//Add the mantissas
adder add(   .a(mantissa_Lg), .b(mant_adj),
	 /*.shift(distance2),*/ .dir(dir), .sum(mant_sum)); 

//Shift the mantissa and exponent, checking for overflow or zero
//exp.

assign exp_ex =  {1'b0, exponent_Lg};
reg [3:0] var;


//shifter sh2(.in(mant_sum), .distance(distance2),
			// .direction(dir), .out(mant_final_above_zero));
//shifter sh3(.in(mant_sum), .distance(exponent_Lg),
			//  .direction(dir), .out(mant_final_below_zero));

always @(*) begin

//If there was overflow from the mantissa addition
if (dir) begin
	var = exp_ex + 4'b0001;
	
	if(var[3]) begin //Overflow case
		mant_final = 5'b11111;
		exp_final = 3'b111;
	end

	else begin
		exp_final = var[2:0];
		mant_final = mant_sum;
	end
end

else begin
	var = 4'b0000; //So that var has a value
	exp_final = exponent_Lg;
	mant_final = mant_sum;

	//The final exponent > 0
	/*if(exponent_Lg >= distance2) begin 
		exp_final = exponent_Lg - distance2;
		mant_final = mant_final_above_zero;
	end

	else begin
		exp_final = 3'b000;
		mant_final = mant_final_below_zero;
	end */
end
	
end //End of always block (for clarity)

assign result = {exp_final, mant_final};

endmodule
