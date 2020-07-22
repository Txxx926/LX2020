//Todo: 给出乘法运算的结果后，mul_end信号会循环（五个时钟周期），下次数据进来只能等到mul_end信号为1的时候才可以计算，假如在等待的时间里有下一组乘法数据，就会导致整个流水线等待乘法。
//原因：start信号一直为1，只需要start信号一个时钟周期后变为0即可
//5 clk cycles
module mul (
	input          clk,
	input          reset,       //0 is valid
	input          mul_op,      //mul_op==b'1,Signed Mul,else Usigned Mul
	input          mul_start,   //1 is valid
	input  [31:0]  mul_op1,
	input  [31:0]  mul_op2,
	output         mul_end,
	output [63:0]  product
);
	reg    [31:0]  op1_data;
	reg    [31:0]  op2_data;
	wire   [63:0]  p_data;
	reg            p_sign;
	reg    [2 :0]  mul_con;

	assign product = p_sign ? -p_data : p_data;
	assign mul_end = (mul_con == 3'd0);

	always @( posedge clk ) begin
		if( !reset ) begin
			op1_data <= 0;
			op2_data <= 0;
			p_sign   <= 1'b0;
			mul_con  <= 3'd0;
		end
		else if( !mul_end ) begin
			mul_con  <= mul_con - 3'd1;
		end
		else if( mul_start ) begin
			mul_con  <= 3'd5;
		end
	end
	always @ ( * ) begin
		if(mul_op == 0 ) begin  
			op1_data = mul_op1;
			op2_data = mul_op2;
			p_sign   = 0;
		end
		else begin
			op1_data = mul_op1[31] ? ~mul_op1+1 : mul_op1;
			op2_data = mul_op2[31] ? ~mul_op2+1 : mul_op2;
			p_sign   = mul_op1[31] ^ mul_op2[31];
		end
	end
	//无符号IP核
	Us_mult_IP Umul(
	.clk    (clk),
	.A      (op1_data),
	.B      (op2_data),
	.CE     (mul_start),
	//.SCLR   (reset),
	.P      (p_data)
	);
	//有符号IP核
	/*S_mult_IP Smul(
	.clk    (clk),·
	.A      (op1_data),
	.B      (op2_data),
	.CE     (mul_start),
	//.SCLR   (reset),
	.P      (p_data)
	);*/
endmodule