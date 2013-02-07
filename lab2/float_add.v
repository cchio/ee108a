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
wire [2:0] distance1, distance2;
wire [4:0] mant_sum;
wire dir;
wire [3:0] exp_ex;
reg [4:0] mant_final;
reg [2:0] exp_final;

`define RIGHT = 1'b1;

//Determine which number has the largest exponent
big_number_first bigger(.ain(aIn), .bin(bIn),
			.aout(largest), .bout(smallest));

//Separate exponent and mantissa
assign {exponent_Lg, mantissa_Lg} = largest;
assign {exponent_Sm, mantissa_Sm} = smallest;

/* Find the number of bits by which the mantissa of the smaller
 * number must be shifted*/
assign distance = exponent_Lg - exponent_Sm;

//Shift the mantissa of the smaller number
shift sh(  .in(mantissa_Sm), .distance(distance1),
	.direction(RIGHT), .out(mant_adj));

//Add the mantissas
adder add(   .a(mantissa_Lg), .b(mant_adj),
	 .shift(distance2), .dir(dir), .sum(mant_sum)); 

//Shift the mantissa and exponent, checking for overflow or zero
//exp.

assign exp_ex =  {1'b0, exponent_Lg};
reg [3:0] var;

always @(*) begin

//If there was overflow from the mantissa addition
if (dir) begin
	var = exp_ex + 4'b0001;
	
	if(var[3]) begin //Overflow case
		assign mant_final = 5'b11111;
		assign exp_final = 3'b111;
	end

	else begin
		assign exp_final = var[2:0];
		assign mant_final = mant_sum;
	end
end

else begin
	assign var = 4'b0000; //So that var has a value

	//The final exponent > 0
	if(exponent_Lg >= distance2) begin 
		assign exp_final = exponent_Lg - distance2;
		shift sh(.in(mant_sum), .distance(distance2),
			 .direction(dir), .out(mant_final);
	end

	else begin
		assign exp_final = 3'b000;
		shift sh2(.in(mant_sum), .distance(exponent_Lg),
			  .direction(dir), .out(mant_final);
	end
end
	
end //End of always block (for clarity)

assign result = {exp_final, mant_final};

endmodule