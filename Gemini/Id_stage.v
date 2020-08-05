module Id_stage(
    input wire [31:0] Instr_First,
    input wire [31:0] Instr_Second,
    input wire [13:0] Exp_First_old,
    input wire [13:0] Exp_Second_old,
    input wire [31:0] PC_First_in,
    input wire [31:0] PC_Second_in,
    input wire [31:0]reg_rs_first,
    input wire [31:0]reg_rt_first,
    output  is_Branch_Instr_first,//to Issue Judge
    output  is_Trap_Priv_Instr_first,//to Issue Judge
    output  is_HiLoRelated_Instr_first,//to Issue Judge
    output  is_Branch_Instr_second,//to Issue Judge
    output  is_Trap_Priv_Instr_second,//to Issue Judge
    output  is_HiLoRelated_Instr_second,//to Issue Judge
    output reg [15:0] imm_first,
    output reg [15:0] imm_second,
    output  [13:0] Exp_First_new,
    output  [6:0] aluop_first,
    output  [1:0] alu_src_first,
    output  if_signed_extend_first,
    output  Write_Reg_Enable_first,
    output  [4:0] Write_Reg_Addr_first,
    output  Write_CP0_Enable_first,
    output  [7:0] CP0_Addr_first,
    output  [1:0] LS_first,
    output  [3:0] LS_SIZE_first,
    output  LS_Signed_first,
    output  [1:0] LS_second,
    output  [1:0] Write_HiLo_first,
    output  [3:0] Branch_type_first,
    output  [13:0] Exp_Second_new,
    output  [6:0] aluop_second,
    output  [1:0] alu_src_second,
    output           if_signed_extend_second,
    output           Write_Reg_Enable_second,
    output  [4:0]    Write_Reg_Addr_second,
    output  [4:0] rs_first,
    output  [4:0] rt_first,
    output  [4:0] rs_second,
    output  [4:0] rt_second,
    output  id_branch_taken
);
wire [5:0] opcode_first,opcode_second;
wire [5:0] func_first,func_second;
wire [4:0] rd_first,rd_second;
wire [2:0] sel_first,sel_second;
wire [15:0] offset_imm_first,offset_imm_second;
wire is_nop_first,is_nop_second; 
always@(offset_imm_first,offset_imm_second)begin
    imm_first=offset_imm_first;
    imm_second=offset_imm_second;
end

Pre_Decode_Fisrt_Pipeline Pre_Decode_Fisrt_Pipeline0(
    .Instr_First(Instr_First),
    .is_Branch_Instr(is_Branch_Instr_first),//to Issue Judge
    .is_Trap_Priv_Instr(is_Trap_Priv_Instr_first),//to Issue Judge
    .is_HiLoRelated_Instr(is_HiLoRelated_Instr_first),//to Issue Judge
    .opcode(opcode_first),
    .func(func_first),
    .rs(rs_first),
    .rt(rt_first),
    .rd(rd_first),
    .sel(sel_first),
    .offset_imm(offset_imm_first),
    .is_nop(is_nop_first)
);

Real_Decode_First_Pipeline Real_Decode_First_Pipeline0(
    .opcode(opcode_first),
    .func(func_first),
    .rs(rs_first),
    .rt(rt_first),
    .rd(rd_first),
    .sel(sel_first),
    .off_imm(offset_imm_first),
    .Exp_First_old(Exp_First_old),
    .is_nop(is_nop_first),
    .aluop(aluop_first),
    .pc(PC_First_in),
    .alu_src(alu_src_first),//00->rs,rt;01->rs,imm;10->imm,rt
    .if_signed_extend(if_signed_extend_first),
    .Write_Reg_Enable(Write_Reg_Enable_first),
    .Write_Reg_Addr(Write_Reg_Addr_first),
    .Write_CP0_Enable(Write_CP0_Enable_first),
    .CP0_Addr(CP0_Addr_first),//{rd,sel}
    .LS(LS_first),//zero is none load or store operation! 01 is load,10 is store
    .LS_SIZE(LS_SIZE_first),//1111,0011,1100,.....
    .LS_Signed(LS_Signed_first),//0 is unsigned ,1 is signed
    .Write_HiLo(Write_HiLo_first),//01 is Lo,10 is Hi,11 is HiLo
    .Branch_type(Branch_type_first),//4'b0000 is none branch
    .Exp_First_new(Exp_First_new)
);
Pre_Decode_Second_Pipeline Pre_Decode_Second_Pipeline0(
    .Instr_Second(Instr_Second),
    .is_Branch_Instr(is_Branch_Instr_second),//to Issue Judge
    .is_Trap_Priv_Instr(is_Trap_Priv_Instr_second),//to Issue Judge
    .is_HiLoRelated_Instr(is_HiLoRelated_Instr_second),//to Issue Judge
    .opcode(opcode_second),
    .func(func_second),
    .rs(rs_second),
    .rt(rt_second),
    .rd(rd_second),
    .sel(sel_second),
    .offset_imm(offset_imm_second),
    .is_nop(is_nop_second)
);
Real_Decode_Second_Pipeline Real_Decode_Second_Pipeline0(
    .opcode(opcode_second),
    .func(func_second),
    .rs(rs_second),
    .rt(rt_second),
    .rd(rd_second),
    .sel(sel_second),
    .off_imm(offset_imm_second),
    .Exp_Second_old(Exp_Second_old),
    .is_nop(is_nop_second),
    .pc(PC_Second_in),
    .aluop(aluop_second),
    .alu_src(alu_src_second),//00->rs,rt;01->rs,imm;10->imm,rt
    .if_signed_extend(if_signed_extend_second),
    .Write_Reg_Enable(Write_Reg_Enable_second),
    .Write_Reg_Addr(Write_Reg_Addr_second),
    .Write_CP0_Enable(),//unused in second pipeline
    .CP0_Addr(),//{rd,sel} unused in second pipeline
    .LS(LS_second),
    .LS_SIZE(),//unused in second pipeline
    .LS_Signed(),//unused in second pipeline
    .Write_HiLo(),//unused in second pipeline
    .Branch_type(),//unused in second pipeline
    .Exp_Second_new(Exp_Second_new)
);
Id_branch Id_branch0(
    .reg_rs(reg_rs_first),
    .reg_rt(reg_rt_first),
    .Branch_Type(Branch_type_first),
    .Branch_Taken(id_branch_taken)
);
endmodule