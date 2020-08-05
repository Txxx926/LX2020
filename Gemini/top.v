module cpu_top(
        input wire clk ,  
        input wire resetn,
        input wire [5:0]int_,
        output wire [1:0] inst_en,
        output wire [31:0] inst_addr,//     ),output [31:0]
        input wire ibus_ready_1,
        input wire ibus_ready_2,//  ( inst_rdata    ),input 
        input wire [31:0 ]ibus_rdata_1,//  ( inst_rdata    ),input [31:0]
        input wire [31:0] ibus_rdata_2,//  ( inst_rdata    ),input [31:0]
        input ibus_stall ,//    ( inst_streq    ),input
        output ibus_cached,//   ( inst_cached   ),output
        
        output  [1:0] dbus_en, // 
        output  [3:0] dbus_wen,//      ( data_wen      ),output [3:0]
        output  [31:0] dbus_addr,//      ( data_addr     ),output [31:0]
        output  [31:0] dbus_wdata,//    ( data_wdata    ),output [31:0]
        input  wire [31:0] dbus_rdata,//     ( data_rdata    ),input  [31:0]
        output  [2:0] dbus_size,//     ( data_size     ),output [2:0]
        input wire dbus_stall,//     ( data_streq    ),input  
        output  dbus_cached,//    ( data_cached   ) output
        output   [31:0] debug_pc_master,
        output   [31:0] debug_pc_slave,
        output   [3:0] debug_wb_rf_wen_master,
        output   [4:0] debug_wb_rf_wnum_master,
        output   [3:0] debug_wb_rf_wen_slave,
        output   [4:0] debug_wb_rf_wnum_slave,
        output   [31:0] debug_wb_rf_wdata_master,
        output   [31:0] debug_wb_rf_wdata_slave,
        output   stall_icache
    );
    wire first_is_in_delayslot_from_fifo;
    reg [31:0] pc_first_from_fifo_prev;
    reg [31:0] pc_second_from_fifo_prev;


    wire [31:0] write_reg_data_first;
wire [31:0] write_reg_data_second;

    //mem_wb
wire write_reg_enable_first_wb,write_reg_enable_second_wb;
wire [1:0] ls_first_wb;
wire [4:0] write_reg_addr_first_wb,write_reg_addr_second_wb;
wire [31:0] memout_first_wb;
wire [31:0] aluout_first_wb,aluout_second_wb;
wire [7:0] cp0_write_addr_first_wb;
wire write_cp0_enable_first_wb;
wire [63:0] write_hilo_data_first_wb;
wire [31:0] pc_first_wb;
wire [31:0] pc_first_wb_i;
wire [1:0] ls_first_wb_i;
wire write_reg_enable_second_wb_i,write_reg_enable_first_wb_i,write_cp0_enable_first_wb_i;
wire [4:0] write_reg_addr_first_wb_i,write_reg_addr_second_wb_i;
wire [31:0] memout_first_wb_i,aluout_first_wb_i,aluout_second_wb_i;
wire [7:0] cp0_write_addr_first_wb_i;
wire [63:0] write_hilo_data_first_wb_i;
    //ex_mem
wire [31:0] pc_first_mem_i,aluout_first_mem_i,aluout_second_mem_i;
wire [1:0] ls_first_mem_i,write_hilo_first_mem_i;
wire [3:0] ls_size_first_mem_i;
wire ls_signed_first_mem_i,write_reg_enable_first_mem_i,write_reg_enable_second_mem_i;
wire [13:0] exp_first_mem_i,exp_second_mem_i;
wire [63:0] WHILO_data_mem_i;
wire [4:0] write_reg_addr_first_mem_i,write_reg_addr_second_mem_i;
wire [31:0] reg_rt_first_mem_i;
wire Write_CP0_Enable_first_mem_i;
wire [7:0] Write_CP0_addr_first_ex,Write_CP0_addr_first_mem_i;
wire [3:0] branch_type_first_mem_i;
wire first_is_in_delayslot_mem_i;
wire [31:0] pc_second_mem_i;
wire en_second_mem_i;
    //id-ex 
wire en_second_ex;
wire [15:0] imm_first_ex,imm_second_ex;
wire imm_extend_signed_first_ex,imm_extend_signed_second_ex;
wire [1:0] alu_src_first_ex,alu_src_second_ex;
wire [13:0] exp_first_ex,exp_second_ex;
wire [31:0] pc_first_ex,instr_first_ex;
wire [3:0] branch_type_first_ex;
wire [1:0] ls_first_ex,write_hilo_first_ex;
wire [3:0] ls_size_first_ex;
wire ls_signed_first_ex;
wire write_reg_enable_first_ex,write_reg_enable_second_ex;
wire [4:0] write_reg_addr_first_ex,write_reg_addr_second_ex;
wire [6:0] aluop_first_ex,aluop_second_ex;
wire [7:0] CP0_addr_first_ex;
wire Write_CP0_Enable_first_ex;
wire [31:0] reg_rs_first_ex,reg_rt_first_ex,reg_rs_second_ex,reg_rt_second_ex;
wire [4:0] rs_first_ex,rt_first_ex,rs_second_ex,rt_second_ex;
wire [31:0] pc_second_ex;
wire en_second_ex2id;






wire is_Branch_Instr_first,is_Branch_Instr_second,is_Trap_Priv_Instr_first,is_Trap_Priv_Instr_second;
wire is_HiLoRelated_Instr_first,is_HiLoRelated_Instr_second;
wire [4:0] rs_first_id_out,rt_first_id_out,rs_second_id_out,rt_second_id_out;
wire [1:0] LS_first_id_out,LS_second_id_out;
wire [13:0] exp_first_id_out,exp_second_id_out;
wire [6:0] aluop_first_id_out,aluop_second_id_out;
wire [1:0] alu_src_first_id_out,alu_src_second_id_out;
wire if_signed_extend_first_id_out,if_signed_extend_second_id_out,LS_Signed_first_id_out;
wire [4:0]Write_Reg_Addr_first_id_out,Write_Reg_Addr_Second_id_out;
wire Write_Reg_Enable_First_id_out,Write_Reg_Enable_Second_id_out;
wire Write_CP0_Enable_first_id_out;
wire [7:0] CP0_Addr_first_id_out;
wire [3:0] LS_SIZE_first_id_out,Branch_type_first_id_out;
wire [1:0] Write_HiLo_first_id_out;
wire [15:0] imm_first_id_out,imm_second_id_out;

wire first_is_in_delayslot_id_out=first_is_in_delayslot_from_fifo;
wire first_is_in_delayslot_ex;
wire id_branch_taken;
    //右边的input/output就是相对于cpu而言
wire [31:0] addr_pc,instr_data_1,instr_data_2;
wire i_ready_1_mmu2pc,i_ready_2_mmu2pc;
wire [1:0] i_en_pc;
wire en_if,en_if_id,en_id_ex,en_ex_mem,en_mem_wb;
wire i_stall_cpu,d_stall_cpu,ex_stall;
wire [31:0] d_rdata_mem,d_addr_mem,d_wdata_mem;
wire [3:0] w_b_s_mem;
wire [1:0] d_en_mem;
wire [2:0] d_size_mem;
 mmu mmu0(
    .addr_pc(addr_pc),//from pc 32bit pc address
    .i_ready_1_pc(i_ready_1_mmu2pc),//to pc
    .i_ready_2_pc(i_ready_2_mmu2pc),//to pc
    .i_en_pc(i_en_pc),//from pc 2 bit
    //to ICache
    .i_ready_1_ICache(ibus_ready_1),//input             i_ready_1_ICache,
    .i_ready_2_ICache(ibus_ready_2),//input             i_ready_2_ICache,
    .i_data_1_ICache(ibus_rdata_1),//input  [31:0]     i_data_1_ICache,
    .i_data_2_ICache(ibus_rdata_2),//input  [31:0]     i_data_2_ICache,
    .i_stall(ibus_stall),//input             i_stall,
    .cached_ICache(ibus_cached),//output reg        cached_ICache,
    .i_addr(inst_addr),//output reg [31:0] i_addr,
    .i_en(inst_en),//output [1:0]      i_en,
    //to DCache
    .d_stall(dbus_stall),//input             d_stall,
    .d_rdata(dbus_rdata),//input  [31:0]     d_rdata,
    .d_addr(dbus_addr),//output reg [31:0] d_addr,
    .w_b_s(dbus_wen),//output [3:0]      w_b_s,
    .d_en(dbus_en),//output [1:0]      d_en,
    .d_wdata(dbus_wdata),//output [31:0]     d_wdata,
    .d_size(dbus_size),//output [2:0]      d_size,
    .cached_DCache(dbus_cached),//output reg        cached_DCache,
    //to mem
    .d_rdata_mem(d_rdata_mem),//output [31:0]     d_rdata_mem,
    .d_addr_mem(d_addr_mem),//input  [31:0]     d_addr_mem,
    .w_b_s_mem(w_b_s_mem),//input  [3:0]      w_b_s_mem,
    .d_en_mem(d_en_mem),//input  [1:0]      d_en_mem,
    .d_wdata_mem(d_wdata_mem),//input  [31:0]     d_wdata_mem,
    .d_size_mem(d_size_mem),//input  [2:0]      d_size_mem,
    //to others
    .i_data_1_if(instr_data_1),//output [31:0]     i_data_1_if,
    .i_data_2_if(instr_data_2),//output [31:0]     i_data_2_if,
    .i_stall_cpu(i_stall_cpu),//output            i_stall_cpu,
    .d_stall_cpu(d_stall_cpu)//output            d_stall_cpu
);
//fifo wire 
wire fifo_full;
wire Branch_Taken;
wire [31:0] Branch_Address;
wire has_exp;
wire [31:0] Exception_JUMP_PC;
 pc pc0(
        .clk(clk),
        .i_stall_cpu(i_stall_cpu),
        .d_stall_cpu(d_stall_cpu),
        .resetn(resetn),
        .en(en_if),// global if_enable
        .i_ready_1(i_ready_1_mmu2pc),//from mmu
        .i_ready_2(i_ready_2_mmu2pc),//from mmu
        .full(fifo_full),//from fifo
        .is_branch(Branch_Taken),//from ex branch
        .addr_branch(Branch_Address),//32 from ex branch
        .is_exception(has_exp),//from exception
        .addr_exception(Exception_JUMP_PC),//32 from exception
        .pc(addr_pc),//to mmu 
        .i_en(i_en_pc)//to mmu
);
wire [31:0]rs_rdata_first_id,rt_rdata_first_id,rs_rdata_second_ex,rt_rdata_second_ex;

//Regfile
Regfile Regfile0(
    .clk(clk),
    .resetn(resetn),
    .count(count),
    .Wen_First(write_reg_enable_first_wb),//signals from wb
    //.Wen_Second(write_reg_enable_second_wb),
    .WData_First(write_reg_data_first),
    //.WData_Second(write_reg_data_second),
    .WAddr_First(write_reg_addr_first_wb),
    //.WAddr_Second(write_reg_addr_second_wb),
    .Read_Addr_First_Rs(rs_first_id_out),//changed from id
    .Read_Addr_First_Rt(rt_first_id_out),//changed from id
    //.Read_Addr_Second_Rs(rs_second_id_out),//changed from id
    //.Read_Addr_Second_Rt(rt_second_id_out),//changed from id
    .RData_First_Rs(rs_rdata_first_id),
    .RData_First_Rt(rt_rdata_first_id)
    //.RData_Second_Rs(rs_rdata_second_ex),
    //.RData_Second_Rt(rt_rdata_second_ex)
);
//

//HILO Reg 
wire [63:0] HILO_Data_To_Ex;
wire [63:0]write_hilo_data_first_mem;
wire [1:0] write_hilo_enable_first_wb,write_hilo_enable_first_wb_i;
wire [1:0] write_hilo_enable_first_mem;
HILO_Reg HILO_Reg0(
    .clk(clk),
    .resetn(resetn),
    .Wb_HILO(write_hilo_enable_first_wb_i),//2 bit
    .Wb_HILO_Data(write_hilo_data_first_wb_i),//64 bit 
    .Mem_HILO(write_hilo_first_mem_i),//2 bit
    .Mem_HILO_Data(WHILO_data_mem_i),//64 bit
    .HILO_Data_To_Ex(HILO_Data_To_Ex)//64 bit to EX
);
wire fifo_empty,fifo_1_left,fifo_2_left;
wire [31:0] Instr_First_id_in,Instr_Second_id_in;
wire [31:0] reg_rs_first_id,reg_rt_first_id;

//global control 
global_control gc0(
        .clk(clk),
        .resetn(resetn),
        .icache_stall(i_stall_cpu),
        .ex_stall(ex_stall),
        .mem_stall(d_stall_cpu),
        .id_ex_alu_op(aluop_first_ex),
        .id_ex_mem_type(ls_first_ex),
        .id_ex_mem_wb_reg_dest(write_reg_addr_first_ex),
        .ex_mem_cp0_wen(Write_CP0_Enable_first_mem_i),
        .ex_mem_mem_type(ls_first_mem_i),
        .ex_mem_mem_wb_reg_dest(write_reg_addr_first_mem_i),
        .id_rs(rs_first_id_out),
        .id_rt(rt_first_id_out),
        .ex_branch_taken(Branch_Taken),
        .fifo_full(fifo_full),
        .exp_detect(has_exp),
        .en_if(en_if),//output wire        en_if,
        .en_if_id(en_if_id),//output wire        en_if_id,
        .en_id_ex(en_id_ex),//output wire        en_id_ex,
        .en_ex_mem(en_ex_mem),//output wire        en_ex_mem,
        .en_mem_wb(en_mem_wb),//output wire        en_mem_wb
        .fifo_1_left(fifo_1_left),
        .Branch_first(is_Branch_Instr_first),
        .fifo_2_left(fifo_2_left)
        //.Instr_First_id_in(Instr_First_id_in)
);

//
//if-id wire 
wire [13:0] Exp_First_old_id_in,Exp_Second_old_id_in;
wire [31:0] pc_first_from_fifo,pc_second_from_fifo;
wire [13:0] exp_first_from_fifo,exp_second_from_fifo;
wire second_en_id;
//FIFO
instruction_fifo fifo(
        .clk(clk),
        .debug_rst(),
        .resetn(resetn&&(~Branch_Taken || !en_if_id)&&~has_exp),
        .master_is_branch(is_Branch_Instr_first),//
        .read_en1(en_if_id),
        .read_en2(second_en_id),
        .en_id_ex(en_id_ex),
        .write_en_1(ibus_ready_1),
        .write_en_2(ibus_ready_2),
        .write_inst1(instr_data_1),//32 bit
        .write_inst_exp1(14'h0),// bits 12->14
        .write_pc1(addr_pc),//32 bit,from pc 
        .write_inst2(instr_data_2),//32 bit
        .write_pc2(addr_pc+32'd4),//32 bit

        .output_inst1(Instr_First_id_in),//32 bit
        .output_inst2(Instr_Second_id_in),
        .output_pc1(pc_first_from_fifo),
        .output_pc2(pc_second_from_fifo),
        .inst_exp1(exp_first_from_fifo),//bit 12->14
        .inst_exp2(exp_second_from_fifo),//bit 12->14
        .delay_slot_out1(first_is_in_delayslot_from_fifo),//1 bit
        .fifo_empty(fifo_empty),
        .fifo_1_left(fifo_1_left),
        .fifo_full(fifo_full),
        .fifo_2_left(fifo_2_left)
);



//
//id stage
Id_stage Id_stage0(
    .Instr_First(Instr_First_id_in),
    .Instr_Second(Instr_Second_id_in),
    .Exp_First_old(exp_first_from_fifo),
    .Exp_Second_old(exp_second_from_fifo),//[13:0]
    .PC_First_in(pc_first_from_fifo),//[31:0]
    .PC_Second_in(pc_second_from_fifo),//[31:0]
    .reg_rs_first(reg_rs_first_id),
    .reg_rt_first(reg_rt_first_id),
    .is_Branch_Instr_first(is_Branch_Instr_first),//to Issue Judge
    .is_Trap_Priv_Instr_first(is_Trap_Priv_Instr_first),//to Issue Judge
    .is_HiLoRelated_Instr_first(is_HiLoRelated_Instr_first),//to Issue Judge
    .is_Branch_Instr_second(is_Branch_Instr_second),//to Issue Judge
    .is_Trap_Priv_Instr_second(is_Trap_Priv_Instr_second),//to Issue Judge
    .is_HiLoRelated_Instr_second(is_HiLoRelated_Instr_second),//to Issue Judge
    .imm_first(imm_first_id_out),
    .imm_second(imm_second_id_out),
    .Exp_First_new(exp_first_id_out),
    .aluop_first(aluop_first_id_out),
    .alu_src_first(alu_src_first_id_out),
    .if_signed_extend_first(if_signed_extend_first_id_out),
    .Write_Reg_Enable_first(Write_Reg_Enable_First_id_out),
    .Write_Reg_Addr_first(Write_Reg_Addr_first_id_out),
    .Write_CP0_Enable_first(Write_CP0_Enable_first_id_out),
    .CP0_Addr_first(CP0_Addr_first_id_out),//8 bit
    .LS_first(LS_first_id_out),//2 bit
    .LS_SIZE_first(LS_SIZE_first_id_out),//4 bit
    .LS_Signed_first(LS_Signed_first_id_out),
    .LS_second(LS_second_id_out),
    .Write_HiLo_first(Write_HiLo_first_id_out),//2 bit
    .Branch_type_first(Branch_type_first_id_out),//4 bit
    .Exp_Second_new(exp_second_id_out),
    .aluop_second(aluop_second_id_out),//7 bit
    .alu_src_second(alu_src_second_id_out),
    .if_signed_extend_second(if_signed_extend_second_id_out),
    .Write_Reg_Enable_second(Write_Reg_Enable_Second_id_out),
    .Write_Reg_Addr_second(Write_Reg_Addr_Second_id_out),
    .rs_first(rs_first_id_out),
    .rt_first(rt_first_id_out),
    .rs_second(rs_second_id_out),
    .rt_second(rt_second_id_out),
    .id_branch_taken(id_branch_taken)
);
//dual engine 
dual_issue_ctrl dic0(
	.first_en(en_if_id),
	.first_inst_priv(is_Trap_Priv_Instr_first),          //第一条流水线指令是特权指�???
	.first_inst_hilo(is_HiLoRelated_Instr_first),          //第一条流水线指令要用到HILO
	.first_inst_wb_en(Write_Reg_Enable_First_id_out),         //第一条流水线指令是否要写�???
	.first_inst_rd(Write_Reg_Addr_first_id_out),            //第一条流水线指令的目的寄存器
	.first_inst_load(LS_first_id_out),          //第一条流水线指令是不是load指令
	.first_inst_load_rt(rt_first_id_out),       //load 指令要写的目的寄存器，可以�?�虑将该信号给first_inst_rd
	//second pipline information
	.second_inst_rs(rs_second_id_out),           //第二条流水线指令的第�???个源寄存�???
	.second_inst_rt(rt_second_id_out),           //第二条流水线指令的第二个源寄存器
	.second_inst_priv(is_Trap_Priv_Instr_second),         //第二条流水线指令是特权指�???
	.second_inst_branch(is_Branch_Instr_second),       //第二条流水线指令是分支跳转指�???
	.second_inst_hilo(is_HiLoRelated_Instr_second),         //第二条流水线指令要用到HILO
	.second_inst_mem_type(LS_second_id_out),     //第二条指令访存类型，01为load,10为store�???00为其�???
	//fifo information
	.fifo_empty(fifo_empty),               //FIFO为空
	.fifo_one(fifo_1_left),                 //FIFO中只有一条指�???
	//output
	.second_en(second_en_id)                 //第二条流水线可以发射
);
//
assign en_second_ex2id=en_second_ex;
wire [31:0] rs_rdata_first_ex,rt_rdata_first_ex;
id_ex id_ex0(
    .clk(clk),
    .resetn(resetn),
    .flush(has_exp&&en_ex_mem),//exception
    .en_id_ex(en_id_ex),
    .en_ex_mem(en_ex_mem),
    .ex_branch_taken(Branch_Taken),
    .id_second_en(second_en_id),
    .ex_second_en_i(en_second_ex2id),
    .rs_first_id(rs_first_id_out),
    .rt_first_id(rt_first_id_out),
    .rs_second_id(rs_second_id_out),
    .rt_second_id(rt_second_id_out),
    .imm_first_id(imm_first_id_out),
    .imm_second_id(imm_second_id_out),
    .imm_extend_signed_first_id(if_signed_extend_first_id_out),
    .imm_extend_signed_second_id(if_signed_extend_second_id_out),
    .aluop_first_id(aluop_first_id_out),
    .aluop_second_id(aluop_second_id_out),
    .alu_src_first_id(alu_src_first_id_out),
    .alu_src_second_id(alu_src_second_id_out),
    .exp_first_id(exp_first_id_out),
    .exp_second_id(exp_second_id_out),
    .pc_first_id(pc_first_from_fifo),
    .pc_second_id(pc_second_from_fifo),
    .read_reg_rs_first_id(reg_rs_first_id),
    .read_reg_rt_first_id(reg_rt_first_id),
    .read_reg_rs_first_ex(reg_rs_first_ex),
    .read_reg_rt_first_ex(reg_rt_first_ex),
    .pc_second_ex(pc_second_ex),
    .instr_first_id(Instr_First_id_in),
    .branch_type_first_id(Branch_type_first_id_out),
    .ls_first_id(LS_first_id_out),
    .ls_size_first_id(LS_SIZE_first_id_out),
    .ls_signed_first_id(LS_Signed_first_id_out),
    .write_hilo_first_id(Write_HiLo_first_id_out),
    .write_reg_addr_first_id(Write_Reg_Addr_first_id_out),
    .write_reg_enable_first_id(Write_Reg_Enable_First_id_out),
    .write_reg_addr_second_id(Write_Reg_Addr_Second_id_out),
    .write_reg_enable_second_id(Write_Reg_Enable_Second_id_out),
    .CP0_addr_first_id(CP0_Addr_first_id_out),
    .Write_CP0_Enable_first_id(Write_CP0_Enable_first_id_out),
    .first_is_in_delayslot_id(first_is_in_delayslot_id_out),
    .first_is_in_delayslot_ex(first_is_in_delayslot_ex),
    .Write_CP0_Enable_first_ex(Write_CP0_Enable_first_ex),
    .CP0_addr_first_ex(CP0_addr_first_ex),// to CP0
    .ex_second_en(en_second_ex),
    .aluop_first_ex(aluop_first_ex),
    .aluop_second_ex(aluop_second_ex),
    .rs_first_ex(rs_first_ex),
    .rt_first_ex(rt_first_ex),
    .rs_second_ex(rs_second_ex),
    .rt_second_ex(rt_second_ex),
    .imm_first_ex(imm_first_ex),
    .imm_second_ex(imm_second_ex),
    .imm_extend_signed_first_ex(imm_extend_signed_first_ex),
    .imm_extend_signed_second_ex(imm_extend_signed_second_ex),
    .alu_src_first_ex(alu_src_first_ex),
    .alu_src_second_ex(alu_src_second_ex),
    .exp_first_ex(exp_first_ex),
    .exp_second_ex(exp_second_ex),
    .pc_first_ex(pc_first_ex),
    .instr_first_ex(instr_first_ex),
    .branch_type_first_ex(branch_type_first_ex),
    .ls_first_ex(ls_first_ex),
    .ls_size_first_ex(ls_size_first_ex),
    .ls_signed_first_ex(ls_signed_first_ex),
    .write_hilo_first_ex(write_hilo_first_ex),
    .write_reg_addr_first_ex(write_reg_addr_first_ex),
    .write_reg_enable_first_ex(write_reg_enable_first_ex),
    .write_reg_addr_second_ex(write_reg_addr_second_ex),
    .write_reg_enable_second_ex(write_reg_enable_second_ex),
    .mul_div_new(mul_div_new)
); 
//



wire [13:0] exp_first_ex_o,exp_second_ex_o;
wire [31:0] aluout_first_ex,aluout_second_ex;
wire [63:0] WHILO_Data_ex;
wire [31:0] cp0_data_to_ex;
wire [31:0] reg_rt_first_ex_o;
//ex stage
Ex_Stage Ex0(
    .mul_div_new(mul_div_new),
    .clk(clk),
    .resetn(resetn),
    .flush(has_exp),
    .reg_rs_first(reg_rs_first_ex),//the result of forwarding 32 bit
    .reg_rt_first(reg_rt_first_ex),//32 bit
    .imm_first(imm_first_ex),//16 bit
    .imm_extend_signed_first(imm_extend_signed_first_ex),
    .alu_src_first(alu_src_first_ex),
    .reg_rs_second(reg_rs_second_ex),
    .reg_rt_second(reg_rt_second_ex),
    .imm_second(imm_second_ex),
    .imm_extend_signed_second(imm_extend_signed_second_ex),
    .alu_src_second(alu_src_second_ex), 
    .Exp_First_old(exp_first_ex),
    .Exp_Second_old(exp_second_ex),
    .aluop_first(aluop_first_ex),
    .aluop_second(aluop_second_ex),
    .pc_first(pc_first_ex),
    .Instr_first(instr_first_ex),
    .Branch_Type_first(branch_type_first_ex),
    .HiLo(HILO_Data_To_Ex),//from HiLo reg 64 bit
    .CP0_Data(cp0_data_to_ex),//from cp0
    .Exp_First_new_end(exp_first_ex_o),//output exp
    .Exp_Second_new(exp_second_ex_o),//
    .Out_First(aluout_first_ex),
    .Out_Second(aluout_second_ex),
    .WHILO_Data(WHILO_Data_ex),//64 bit
    .Branch_Taken(Branch_Taken),// to pc
    .Branch_Address(Branch_Address),//to pc 32 bit
    .reg_rt_first_o(reg_rt_first_ex_o),
    .ex_stall(ex_stall)
);

// always@(posedge clk)begin
//     if(resetn)begin
//     $display("-------debug frowarding");
//     $display("MEM stage First:pc=0x%8h,wen=%1b,wad=%5b,aluout=0x%8h",pc_first_mem_i,write_reg_enable_first_mem_i,write_reg_addr_first_mem_i,aluout_first_mem_i);
//     $display("rt_first_ex=%5b,rt_rdata=0x%8h,reg_rt_first_ex=0x%8h",rt_first_ex,rt_rdata_first_ex,reg_rt_first_ex);
//     $display("MEM stage second:wen=%1b,wad=%5b,aluout=0x%8h",write_reg_enable_second_mem_i,write_reg_addr_second_mem_i,aluout_second_mem_i);
//     $display("------debug end-------");
//     end
// end

//
forward forward_first_rs(
	.first_ex_en(write_reg_enable_first_ex),          //寄存器使能，当前位于主流水线写回阶段的指令需要写寄存器时，该信号置为1
	.first_ex_addr(write_reg_addr_first_ex),        //当前位于主流水线写回阶段的指令需要写的寄存器�???,5 bit
	.first_ex_data(aluout_first_ex),        //当前位于主流水线写回阶段的结�??? 32 bit
	.first_mem_en(write_reg_enable_first_mem_i),         //寄存器使能，当前位于主流水线访存阶段的指令需要写寄存器时，该信号置为1
	.first_mem_addr(write_reg_addr_first_mem_i),       //当前位于主流水线访存阶段的指令需要写的寄存器�??? 5 bit 
	.first_mem_data(aluout_first_mem_i),       //当前位于主流水alu阶段的结�??? 32 bit

	// .second_mem_en(write_reg_enable_second_mem_i),        //寄存器使能，当前位于辅流水线访存阶段的指令需要写寄存器时，该信号置为1
	// .second_mem_addr(write_reg_addr_second_mem_i),      //当前位于辅流水线访存阶段的指令需要写的寄存器�???
	// .second_mem_data(aluout_second_mem_i),      //当前位于辅流水线访存阶段的结�???
	// .second_wb_en(write_reg_enable_second_wb),         //寄存器使能，当前位于辅流水线写回阶段的指令需要写寄存器时，该信号置为1
	// .second_wb_addr(write_reg_addr_second_wb),       //当前位于辅流水线写回阶段的指令需要写的寄存器�???
	// .second_wb_data(write_reg_data_second),       //当前位于辅流水线写回阶段的结�???


	.reg_addr(rs_first_id_out),             //执行阶段�???要读的寄存器�???
	.reg_data(rs_rdata_first_id),             //从寄存器中读出的结果

	.result_data(reg_rs_first_id)           //前推后的结果
);
forward forward_first_rt(
	.first_ex_en(write_reg_enable_first_ex),          //寄存器使能，当前位于主流水线写回阶段的指令需要写寄存器时，该信号置为1
	.first_ex_addr(write_reg_addr_first_ex),        //当前位于主流水线写回阶段的指令需要写的寄存器�???,5 bit
	.first_ex_data(aluout_first_ex),        //当前位于主流水线写回阶段的结�??? 32 bit
	.first_mem_en(write_reg_enable_first_mem_i),         //寄存器使能，当前位于主流水线访存阶段的指令需要写寄存器时，该信号置为1
	.first_mem_addr(write_reg_addr_first_mem_i),       //当前位于主流水线访存阶段的指令需要写的寄存器�??? 5 bit 
	.first_mem_data(aluout_first_mem_i),       //当前位于主流水alu阶段的结�??? 32 bit


	// .second_mem_en(write_reg_enable_second_mem_i),        //寄存器使能，当前位于辅流水线访存阶段的指令需要写寄存器时，该信号置为1
	// .second_mem_addr(write_reg_addr_second_mem_i),      //当前位于辅流水线访存阶段的指令需要写的寄存器�???
	// .second_mem_data(aluout_second_mem_i),      //当前位于辅流水线访存阶段的结�???
	// .second_wb_en(write_reg_enable_second_wb),         //寄存器使能，当前位于辅流水线写回阶段的指令需要写寄存器时，该信号置为1
	// .second_wb_addr(write_reg_addr_second_wb),       //当前位于辅流水线写回阶段的指令需要写的寄存器�???
	// .second_wb_data(write_reg_data_second),       //当前位于辅流水线写回阶段的结�???



	.reg_addr(rt_first_id_out),             //执行阶段�???要读的寄存器�???
	.reg_data(rt_rdata_first_id),             //从寄存器中读出的结果

	.result_data(reg_rt_first_id)           //前推后的结果
);
// forward forward_second_rs(
// 	.first_wb_en(write_reg_enable_first_wb),          //寄存器使能，当前位于主流水线写回阶段的指令需要写寄存器时，该信号置为1
// 	.first_wb_addr(write_reg_addr_first_wb),        //当前位于主流水线写回阶段的指令需要写的寄存器�???,5 bit
// 	.first_wb_data(write_reg_data_first),        //当前位于主流水线写回阶段的结�??? 32 bit
// 	.first_mem_en(write_reg_enable_first_mem_i),         //寄存器使能，当前位于主流水线访存阶段的指令需要写寄存器时，该信号置为1
// 	.first_mem_addr(write_reg_addr_first_mem_i),       //当前位于主流水线访存阶段的指令需要写的寄存器�??? 5 bit 
// 	.first_mem_data(aluout_first_mem_i),       //当前位于主流水alu阶段的结�??? 32 bit

// 	.second_mem_en(write_reg_enable_second_mem_i),        //寄存器使能，当前位于辅流水线访存阶段的指令需要写寄存器时，该信号置为1
// 	.second_mem_addr(write_reg_addr_second_mem_i),      //当前位于辅流水线访存阶段的指令需要写的寄存器�???
// 	.second_mem_data(aluout_second_mem_i),      //当前位于辅流水线访存阶段的结�???
// 	.second_wb_en(write_reg_enable_second_wb),         //寄存器使能，当前位于辅流水线写回阶段的指令需要写寄存器时，该信号置为1
// 	.second_wb_addr(write_reg_addr_second_wb),       //当前位于辅流水线写回阶段的指令需要写的寄存器�???
// 	.second_wb_data(write_reg_data_second),       //当前位于辅流水线写回阶段的结�???

// 	.reg_addr(rs_second_id_out),             //执行阶段�???要读的寄存器�???
// 	.reg_data(rs_rdata_second_ex),             //从寄存器中读出的结果

// 	.result_data(reg_rs_second_ex)           //前推后的结果
// );
// forward forward_second_rt(
// 	.first_wb_en(write_reg_enable_first_wb),          //寄存器使能，当前位于主流水线写回阶段的指令需要写寄存器时，该信号置为1
// 	.first_wb_addr(write_reg_addr_first_wb),        //当前位于主流水线写回阶段的指令需要写的寄存器�???,5 bit
// 	.first_wb_data(write_reg_data_first),        //当前位于主流水线写回阶段的结�??? 32 bit
// 	.first_mem_en(write_reg_enable_first_mem_i),         //寄存器使能，当前位于主流水线访存阶段的指令需要写寄存器时，该信号置为1
// 	.first_mem_addr(write_reg_addr_first_mem_i),       //当前位于主流水线访存阶段的指令需要写的寄存器�??? 5 bit 
// 	.first_mem_data(aluout_first_mem_i),       //当前位于主流水alu阶段的结�??? 32 bit

// 	.second_mem_en(write_reg_enable_second_mem_i),        //寄存器使能，当前位于辅流水线访存阶段的指令需要写寄存器时，该信号置为1
// 	.second_mem_addr(write_reg_addr_second_mem_i),      //当前位于辅流水线访存阶段的指令需要写的寄存器�???
// 	.second_mem_data(aluout_second_mem_i),      //当前位于辅流水线访存阶段的结�???
// 	.second_wb_en(write_reg_enable_second_wb),         //寄存器使能，当前位于辅流水线写回阶段的指令需要写寄存器时，该信号置为1
// 	.second_wb_addr(write_reg_addr_second_wb),       //当前位于辅流水线写回阶段的指令需要写的寄存器�???
// 	.second_wb_data(write_reg_data_second),       //当前位于辅流水线写回阶段的结�???

// 	.reg_addr(rt_second_id_out),             //执行阶段�???要读的寄存器�???
// 	.reg_data(rt_rdata_second_ex),             //从寄存器中读出的结果

// 	.result_data(reg_rt_second_ex)           //前推后的结果
// );

ex_mem ex_mem0(
    .clk(clk),
    .resetn(resetn),
    .en_ex_mem(en_ex_mem),
    .en_mem_wb(en_mem_wb),
    .flush(has_exp&&en_ex_mem),//exception
    .reg_rt_first_ex(reg_rt_first_ex_o),
    .write_hilo_first_ex(write_hilo_first_ex),
    .write_reg_enable_first_ex(write_reg_enable_first_ex),
    .write_reg_enable_second_ex(write_reg_enable_second_ex),
    .write_reg_addr_first_ex(write_reg_addr_first_ex),
    .write_reg_addr_second_ex(write_reg_addr_second_ex),
    .WHILO_Data_ex(WHILO_Data_ex),
    .aluout_first_ex(aluout_first_ex),
    .aluout_second_ex(aluout_second_ex),
    .Write_CP0_Enable_first_ex(Write_CP0_Enable_first_ex),
    .Write_CP0_addr_first_ex(CP0_addr_first_ex),
    .Branch_type_first_ex(branch_type_first_ex),
    .first_is_in_delayslot_ex(first_is_in_delayslot_ex),
    .first_is_in_delayslot_mem_i(first_is_in_delayslot_mem_i),
    .Branch_type_first_mem_i(branch_type_first_mem_i),
    .Write_CP0_addr_first_mem_i(Write_CP0_addr_first_mem_i),
    .Write_CP0_Enable_first_mem_i(Write_CP0_Enable_first_mem_i),
    .exp_first_ex(exp_first_ex_o),
    .exp_second_ex(exp_second_ex_o),
    .pc_second_ex(pc_second_ex),
    .pc_second_mem_i(pc_second_mem_i),
    .ls_first_ex(ls_first_ex),
    .ls_size_first_ex(ls_size_first_ex),
    .ls_signed_first_ex(ls_signed_first_ex),
    .pc_first_ex(pc_first_ex),
    .en_second_ex(en_second_ex),
    .en_second_mem_i(en_second_mem_i),
    .reg_rt_first_mem_i(reg_rt_first_mem_i),
    .pc_first_mem_i(pc_first_mem_i),
    .ls_first_mem_i(ls_first_mem_i),
    .ls_size_first_mem_i(ls_size_first_mem_i),
    .ls_signed_first_mem_i(ls_signed_first_mem_i),
    .exp_first_mem_i(exp_first_mem_i),
    .exp_second_mem_i(exp_second_mem_i),
    .aluout_first_mem_i(aluout_first_mem_i),
    .aluout_second_mem_i(aluout_second_mem_i),
    .WHILO_Data_mem_i(WHILO_data_mem_i),
    .write_reg_addr_first_mem_i(write_reg_addr_first_mem_i),
    .write_reg_addr_second_mem_i(write_reg_addr_second_mem_i),
    .write_reg_enable_first_mem_i(write_reg_enable_first_mem_i),
    .write_reg_enable_second_mem_i(write_reg_enable_second_mem_i),
    .write_hilo_first_mem_i(write_hilo_first_mem_i)
);
wire [31:0] memout_first_mem;
wire is_exp_first,is_exp_second;
//mem_stage
Mem_Stage mem0(
    .clk(clk),
    .resetn(resetn),
    .int_(int_),
    .aluout_first(aluout_first_mem_i),//from first
    .reg_rt(reg_rt_first_mem_i),
    .signed_load(ls_signed_first_mem_i),
    .first_is_in_delayslot(first_is_in_delayslot_mem_i),
    .Exp_First(exp_first_mem_i),
    .Exp_Second(exp_second_mem_i),
    .mem_type_First(ls_first_mem_i),
    .PC_First(pc_first_mem_i),
    .Branch_type_First(branch_type_first_mem_i),
    .PC_Second(pc_second_mem_i),
    .mem_byte_select(ls_size_first_mem_i),
    .cp0_addr(CP0_addr_first_ex),//from ex
    .cp0_write_addr(cp0_write_addr_first_wb_i),//from wb
    .write_cp0_enable(write_cp0_enable_first_wb_i),
    .write_cp0_data(aluout_first_wb_i),
    .cp0_data(cp0_data_to_ex),//to ex
    .is_exp_first(is_exp_first),
    .is_exp_second(is_exp_second),
    .d_addr(d_addr_mem),
    .d_wdata(d_wdata_mem),
    .d_size(d_size_mem),
    .d_en(d_en_mem),
    .w_byte_select(w_b_s_mem),
    .d_rdata(d_rdata_mem),
    .data_mem(memout_first_mem),//to wb
    .has_exp(has_exp),//flush the previous stages
    .Exception_JUMP_PC(Exception_JUMP_PC)//32 bit 
);
//


mem_wb mem_wb0(
    .clk(clk),
    .resetn(resetn),
    .has_exp(has_exp),
    .is_exp_first(is_exp_first),
    .is_exp_second(is_exp_second),
    .en_mem_wb(en_mem_wb),

    .write_reg_enable_first_mem(write_reg_enable_first_mem_i),
    .write_reg_enable_second_mem(write_reg_enable_second_mem_i),
    .write_hilo_enable_first_mem(write_hilo_first_mem_i),
    .write_reg_addr_first_mem(write_reg_addr_first_mem_i),
    .write_reg_addr_second_mem(write_reg_addr_second_mem_i),
    .memout_first_mem(memout_first_mem),
    .aluout_first_mem(aluout_first_mem_i),
    .aluout_second_mem(aluout_second_mem_i),
    .cp0_write_addr_first_mem(Write_CP0_addr_first_mem_i),
    .write_cp0_enable_first_mem(Write_CP0_Enable_first_mem_i),
    .write_hilo_data_first_mem(WHILO_data_mem_i),
    .ls_first_mem(ls_first_mem_i),
    .pc_first_mem_i(pc_first_mem_i),
    .pc_first_wb(pc_first_wb_i),
    .ls_first_wb(ls_first_wb_i),
    .write_reg_enable_first_wb(write_reg_enable_first_wb_i),
    .write_reg_enable_second_wb(write_reg_enable_second_wb_i),
    .write_hilo_enable_first_wb(write_hilo_enable_first_wb_i),
    .write_reg_addr_first_wb(write_reg_addr_first_wb_i),
    .write_reg_addr_second_wb(write_reg_addr_second_wb_i),
    .memout_first_wb(memout_first_wb_i),
    .aluout_first_wb(aluout_first_wb_i),
    .aluout_second_wb(aluout_second_wb_i),
    .cp0_write_addr_first_wb(cp0_write_addr_first_wb_i),
    .write_cp0_enable_first_wb(write_cp0_enable_first_wb_i),
    .write_hilo_data_first_wb(write_hilo_data_first_wb_i)
);



//wb_stage
Wb_Stage Wb_0(
    .Write_Reg_Enable_First(write_reg_enable_first_wb_i),
    .Write_Reg_Enable_Second(write_reg_enable_second_wb_i),
    .Wrtie_Reg_Address_First(write_reg_addr_first_wb_i),//5 bit
    .Write_Reg_Address_Second(write_reg_addr_second_wb_i),//5 bit
    .Write_HILO_Enable_First(write_hilo_enable_first_wb_i),//2 bit
    .Write_HILO_Data(write_hilo_data_first_wb_i),//64 bit
    .Mem_Result_First(memout_first_wb_i),//32 bit
    .LS_First(ls_first_wb_i),//2 bit
    .Aluout_First(aluout_first_wb_i),//32 bit
    .Aluout_Second(aluout_second_wb_i),//32 bit
    .Cp0_write_data_First(aluout_first_wb_i),//32 bit
    .Cp0_write_address_First(cp0_write_addr_first_wb_i),// 8 bit
    .Write_Cp0_Enable_First(write_cp0_enable_first_wb_i),
    .Write_Reg_Enable_First_o(write_reg_enable_first_wb),//same
    .Write_Reg_Enable_Second_o(write_reg_enable_second_wb),//same
    .Write_Reg_Address_First_o(write_reg_addr_first_wb),//same
    .Write_Reg_Address_Second_o(write_reg_addr_second_wb),//same
    .Write_Reg_Data_First_o(write_reg_data_first),
    .Write_Reg_Data_Second_o(write_reg_data_second),
    .Write_Cp0_Enable_First_o(write_cp0_enable_first_wb),//same
    .Cp0_write_address_First_o(cp0_write_addr_first_wb),//same
    .Cp0_write_data_o(aluout_first_wb),//same
    .Write_HILO_Enable_First_o(write_hilo_enable_first_wb),//same
    .Write_HILO_Data_o(write_hilo_data_first_wb)//same
);

// reg [63:0]clk_count;
// always@(posedge clk)begin
//     if(!resetn)begin
//         clk_count <= 0;
//     end
//     else begin
//         clk_count<=clk_count+1;
//         $display("clk_count = %16d",clk_count);
//     end
// end
// reg [63:0] i_cache_stall_count;
// always @ (posedge clk) begin
//     if(!resetn) begin
//         i_cache_stall_count <= 64'b0;
//     end
//     else if(i_stall_cpu) begin
//         i_cache_stall_count <= i_cache_stall_count + 1;
//         $display("ICache_stall = %64d",i_cache_stall_count);
//     end
// end
// reg [63:0] d_cache_stall_count;
// always @ (posedge clk) begin
//     if(!resetn) begin
//         d_cache_stall_count <= 64'b0;
//     end
//     else if(d_stall_cpu) begin
//         d_cache_stall_count <= d_cache_stall_count +1;
//         $display("DCache_stall = %64d",d_cache_stall_count);
//     end
// end
// reg [63:0] ex_stall_count;
// always @(posedge clk) begin
//     if(!resetn) begin
//         ex_stall_count <= 64'b0;
//     end
//     else if(ex_stall) begin
//         ex_stall_count <= ex_stall_count +1;
//         $display("ex_stall = %64d",ex_stall_count);
//     end
// end


    assign  debug_pc_master =pc_first_wb_i;
    assign debug_pc_slave= pc_first_wb_i+32'd4;
    assign debug_wb_rf_wen_master = {4{write_reg_enable_first_wb}};
    assign debug_wb_rf_wen_slave = {4{write_reg_enable_second_wb}};
    assign debug_wb_rf_wnum_master = write_reg_addr_first_wb;
    assign debug_wb_rf_wnum_slave = write_reg_addr_second_wb;
    assign debug_wb_rf_wdata_master = write_reg_data_first;
    assign debug_wb_rf_wdata_slave = write_reg_data_second;

    assign stall_icache = ex_stall || d_stall_cpu;

endmodule