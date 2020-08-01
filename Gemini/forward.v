module forward(
	input                    first_wb_en,          //寄存器使能，当前位于主流水线写回阶段的指令需要写寄存器时，该信号置为1
	input  [ 4:0]            first_wb_addr,        //当前位于主流水线写回阶段的指令需要写的寄存器号
	input  [31:0]            first_wb_data,        //当前位于主流水线写回阶段的结果
	input                    first_mem_en,         //寄存器使能，当前位于主流水线访存阶段的指令需要写寄存器时，该信号置为1
	input  [ 4:0]            first_mem_addr,       //当前位于主流水线访存阶段的指令需要写的寄存器号
	input  [31:0]            first_mem_data,       //当前位于主流水线访存阶段的结果

	input                    second_mem_en,        //寄存器使能，当前位于辅流水线访存阶段的指令需要写寄存器时，该信号置为1
	input  [ 4:0]            second_mem_addr,      //当前位于辅流水线访存阶段的指令需要写的寄存器号
	input  [31:0]            second_mem_data,      //当前位于辅流水线访存阶段的结果
	input                    second_wb_en,         //寄存器使能，当前位于辅流水线写回阶段的指令需要写寄存器时，该信号置为1
	input  [ 4:0]            second_wb_addr,       //当前位于辅流水线写回阶段的指令需要写的寄存器号
	input  [31:0]            second_wb_data,       //当前位于辅流水线写回阶段的结果

	input  [ 4:0]            reg_addr,             //执行阶段需要读的寄存器号
	input  [31:0]            reg_data,             //从寄存器中读出的结果

	output wire  [31:0]            result_data           //前推后的结果
);
	reg  [31:0]result_data_temp;

	assign result_data = result_data_temp;
	
	always @ ( * ) begin
		if( reg_addr != 5'd0 ) begin

			if( second_mem_en && second_mem_addr == reg_addr )
				result_data_temp = second_mem_data;
			else if( first_mem_en && first_mem_addr == reg_addr )
				begin
				//$display("forwading-----first_mem,reg_addr=%5b,result=0x%8h",reg_addr,result_data);
				result_data_temp = first_mem_data;
				end
			else if( second_wb_en && second_wb_addr == reg_addr )
				result_data_temp = second_wb_data;
			else if( first_wb_en && first_wb_addr == reg_addr )
				result_data_temp = first_wb_data;
			else
				result_data_temp = reg_data;
		end
		else begin
			result_data_temp = 32'd0;
		end
	end
endmodule