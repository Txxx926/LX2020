//only one operation at same time
module alu_mul_div(
	input                  clk,
	input                  reset,
	input                  flush,       //1 is valid
	input   [5:0]          alu_op,
	input   [31:0]         alu_op1,
	input   [31:0]         alu_op2,
	output  [63:0]         alu_result
);
	reg                    mul_start , div_start;
	reg                    mul_end , div_end;
	reg                    mul_op , div_op;

	always @ ( * ) begin
		div_start = 2'd0;
		mul_start = 2'd0;
		if(!flush && mul_end && div_end ) begin
			mul_start = 1'b0;
			div_start = 1'b0;
			case(alu_op)
			010 : begin div_op = 2'b1 ; div_start = 1'b1; end     //div
			001 : begin div_op = 2'b0 ; div_start = 1'b1; end     //divu
			110 : begin mul_op = 2'b1 ; mul_start = 1'b0; end     //mult
			101 : begin mul_op = 2'b0 ; mul_start = 1'b0; end     //multu
			endcase
		end
		else begin
			
		end
	end

	mul mul_IP(
	.clk               (clk),
	.reset             (reset),     //0 is valid
	.mul_op            (mul_op),    //1'b1 is Signed m=Mult,1'b0 Usigned Mlut
	.mul_start         (mul_start), ////1 is valid
	.mul_op1           (alu_op1),
	.mul_op2           (alu_op2),
	.product           (alu_result),
	.mul_end           (mul_end)
	);
	div div_div(
	.clk               (clk),
	.reset             (reset),     //0 is valid
	.div_start         (div_start), //1 is valid
	.div_op            (div_op),    //1'b1 is Signed Div,1'b0 Usigned Div
	.dividend          (div_op1),
	.divisor           (div_op2),
	.div_result        (alu_result),
	.div_end           (div_end)
	);
endmodule
