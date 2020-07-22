//Todo: 给出除法运算的结果后，div_end信号会循环（34个时钟周期），下次数据进来只能等到div_end信号为1的时候才可以计算，假如在等待的时间里有下一组数据，就会导致整个流水线等待除法瞎跑。
//原因：start信号一直为1，只需要start信号一个时钟周期后变为0即可解决
// 34 clk cycles
module div(
	input                  clk,
	input                  reset,        //0 is valid
	input                  div_start,
	input                  div_op,       //1'b1 is Signed Div,1'b0 Usigned Div
	input   [31:0]         dividend,
	input   [31:0]         divisor,

	output  [63:0]         div_result,
	output                 div_end
	
);	wire    [31:0]         div_quo;
	wire    [31:0]         div_rem;
	reg     [31:0]         divsior_data;
	reg     [31:0]         divsidend_data;
	reg                    div_sign;
	reg                    dividend_sign;
	wire    [63:0]         div_US_result;
	reg     [ 5:0]         div_con;

	//结果的符号
	//被除数的符号和余数相同
	assign div_quo    = div_sign ?      ( ~div_US_result[63:32] + 32'd1 ) : div_US_result[63:32];
	assign div_rem    = dividend_sign ? ( ~div_US_result[31: 0] + 32'd1 ) : div_US_result[31: 0];
	assign div_end    = ( div_con == 6'd0 );
	assign div_result = { div_rem , div_quo };

	always @(posedge clk) begin
		if( !reset ) begin
			div_con        <= 6'd0;
			divsidend_data <= 32'd0;
			divsior_data   <= 32'd0;
			div_sign       <= 1'b0;
		end
		else begin
			if( !div_end )
				div_con <= div_con - 1;
			else begin
				if(div_start == 1) begin
					div_con <= 6'd34;
				end
			end
		end
	end
	always @ ( * ) begin
		if( div_op == 0 ) begin 
			div_sign       = 1'b0;
			divsidend_data = dividend;
			divsior_data   = divisor;
			dividend_sign  = 1'b0;
		end
		else begin
			div_sign       = divisor[31]  ^ dividend[31];
			divsidend_data = dividend[31] ? ~dividend + 1 : dividend;
			divsior_data   = divisor[31]  ? ~divisor + 1  : divisor;
			dividend_sign  = dividend[31];
		end
	end
	//无符号IP核
	div_gen_0 div(
		.aclk                         (clk), 
		//.aresetn                     (reset),
		.aclken                       (div_start),
		.s_axis_divisor_tdata         (divsior_data),
		.s_axis_divisor_tvalid        (1'd1),
		.s_axis_dividend_tdata        (divsidend_data),
		.s_axis_dividend_tvalid       (1'd1),
		.m_axis_dout_tdata            (div_US_result)
	);
endmodule
