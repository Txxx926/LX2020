`define  ADD_OP     7'd1
`define  ADDI_OP    7'd2
`define  ADDU_OP    7'd3
`define  ADDIU_OP   7'd4
`define  SUB_OP     7'd5
`define  SUBU_OP    7'd6
`define  SLT_OP     7'd7
`define  SLTI_OP    7'd8
`define  SLTU_OP    7'd9
`define  SLTIU_OP   7'd10
`define  DIV_OP     7'd11
`define  DIVU_OP    7'd12
`define  MULT_OP    7'd13
`define  MULTU_OP   7'd14
`define  AND_OP     7'd15
`define  ANDI_OP    7'd16
`define  LUI_OP     7'd17
`define  NOR_OP     7'd18
`define  OR_OP      7'd19
`define  ORI_OP     7'd20
`define  XOR_OP     7'd21
`define  XORI_OP    7'd22
`define  SLL_OP     7'd23
`define  SLLV_OP    7'd24
`define  SRA_OP     7'd25
`define  SRAV_OP    7'd26
`define  SRL_OP     7'd27
`define  SRLV_OP    7'd28
`define  BEQ_OP     7'd29
`define  BNE_OP     7'd30
`define  BGEZ_OP    7'd31 
`define  BGTZ_OP    7'd32 
`define  BLEZ_OP    7'd33 
`define  BLTZ_OP    7'd34
`define  BLTZAL_OP  7'd35 
`define  BGEZAL_OP  7'd36
`define  J_OP          7'd37 
`define  JAL_OP        7'd38 
`define  JR_OP         7'd39 
`define  JALR_OP       7'd40 
`define  MFHI_OP       7'd41 
`define  MFLO_OP       7'd42 
`define  MTHI_OP       7'd43 
`define  MTLO_OP       7'd44 
`define  BREAK_OP       7'd45
`define  SYSCALL_OP     7'd46
`define  LB_OP          7'd47
`define  LBU_OP            7'd48 
`define  LH_OP             7'd49 
`define  LHU_OP            7'd50 
`define  LW_OP             7'd51 
`define  SB_OP             7'd52 
`define  SH_OP             7'd53 
`define  SW_OP             7'd54 
`define  ERET_OP           7'd55 
`define  MFC0_OP           7'd56 
`define  MTC0_OP            7'd57
`define  NOP_OP             7'd58

//Branch Type
`define  BEQ    4'd1
`define  BNE    4'd2
`define  BGEZ   4'd3
`define  BGTZ   4'd4
`define  BLEZ   4'd5
`define  BLTZ   4'd6
`define  BGEZAL 4'd7
`define  BLTZAL 4'd8
`define  J      4'd9
`define  JAL    4'd10 
`define  JR     4'd11 
`define  JALR   4'd12

`define Index_Addr              {5'd0,3'd0}
`define Random_Addr             {5'd1,3'd0}
`define EntryLo0_Addr           {5'd2,3'd0}
`define EntryLo1_Addr           {5'd3,3'd0}
`define Context_Addr            {5'd4,3'd0}
`define PageMask_Addr           {5'd5,3'd0}
`define Wired_Addr              {5'd6,3'd0}
`define BadVaddr_Addr           {5'd8,3'd0}
`define Count_Addr              {5'd9,3'd0}
`define EntryHi_Addr            {5'd10,3'd0}
`define Compare_Addr            {5'd11,3'd0}
`define Status_Addr             {5'd12,3'd0}
`define Cause_Addr              {5'd13,3'd0}
`define Epc_Addr                {5'd14,3'd0}
`define Ebase_Addr              {5'd15,3'd1}