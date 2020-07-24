module dual_issue_ctrl(
	//可以采用宏定义的方式将所有指令的类型统一定义，在传指令类型时，只需要传值即可，就不需要将不同指令的信号分开
	//1 is valid
	//first pipeline information
	input         first_en,
	input         first_inst_priv,          //第一条流水线指令是特权指令
	input         first_inst_hilo,          //第一条流水线指令要用到HILO
	input         first_inst_wb_en,         //第一条流水线指令是否要写回
	input [4 :0]  first_inst_rd,            //第一条流水线指令的目的寄存器
	input [1 :0]  first_inst_load,          //第一条流水线指令是不是load指令
	input [4 :0]  first_inst_load_rt,       //load 指令要写的目的寄存器，可以考虑将该信号给first_inst_rd
	//second pipline information
	input [4 :0]  second_inst_rs,           //第二条流水线指令的第一个源寄存器
	input [4 :0]  second_inst_rt,           //第二条流水线指令的第二个源寄存器
	input         second_inst_priv,         //第二条流水线指令是特权指令
	input         second_inst_branch,       //第二条流水线指令是分支跳转指令
	input         second_inst_hilo,         //第二条流水线指令要用到HILO
	input [1 :0]  second_inst_mem_type,     //第二条指令访存类型，01为load,10为store，00为其他
	//fifo information
	input         fifo_empty,               //FIFO为空
	input         fifo_one,                 //FIFO中只有一条指令
	//output
	output        second_en                 //第二条流水线可以发射
);
	reg second_en_temp;
	wire unfifo;
	reg second_en_temp_load;

	assign unfifo = ( fifo_empty || fifo_one );
	assign second_en = second_en_temp ;

	always @( * ) begin
		//指令fifo中指令不够
		//第一条流水线没发射，第一条流水线是特权指令，
		//第二条流水线要访存，是分支跳转指令，用到HILO，是特权指令
		//second_inst_mem_type != 2'b00 即第二流水线的指令是load或者store
		if( unfifo ||
		    ( !first_en )                   ||                                           first_inst_priv   ||
		    (second_inst_mem_type != 2'b00) || second_inst_branch || second_inst_hilo || second_inst_priv     )
		begin
			second_en_temp = 1'b0;
		end
		else begin
			//RAW
			//第一条流水线要写 且 不是 $0 寄存器,第二条流水线的源寄存器是第一条流水线的目的寄存器
			//第一条流水线是load指令并且load指令的目的寄存器是第二条流水线的源寄存器
			if( first_inst_wb_en && first_inst_rd != 5'b0 && (second_inst_rs == first_inst_rd || second_inst_rt == first_inst_rd) || 
				( first_inst_load == 2'b01 && first_inst_load_rt != 5'b0 && ( second_inst_rs == first_inst_load_rt || second_inst_rt == first_inst_load_rt )))
			begin
				second_en_temp = 1'b0;
			end
			else begin
				second_en_temp = 1'b1;
			end
		end
	end
endmodule