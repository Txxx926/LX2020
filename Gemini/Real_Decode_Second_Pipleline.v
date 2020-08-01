`include "define.v"
module Real_Decode_Second_Pipeline(
    input wire [5:0]    opcode,
    input wire [5:0]    func,
    input wire [4:0]    rs,
    input wire [4:0]    rt,
    input wire [4:0]    rd,
    input wire [2:0]    sel,
    input wire [15:0]   off_imm,
    input wire [13:0]   Exp_Second_old,
    input wire is_nop,
    input wire [31:0] pc,
    output reg [6:0]    aluop,
    output reg [1:0]    alu_src,//00->rs,rt;01->rs,imm;10->imm,rt
    output reg          if_signed_extend,
    output reg          Write_Reg_Enable,
    output reg [4:0]    Write_Reg_Addr,
    output reg          Write_CP0_Enable,//unused in second pipeline
    output wire [7:0]   CP0_Addr,//{rd,sel} unused in second pipeline
    output reg [1:0]    LS,//unused in second pipeline
    output reg [3:0]    LS_SIZE,//unused in second pipeline
    output reg          LS_Signed,//unused in second pipeline
    output reg [1:0]    Write_HiLo,//unused in second pipeline
    output reg [3:0]    Branch_type,//unused in second pipeline
    output reg [13:0]   Exp_Second_new
);
assign CP0_Addr={rd,sel};
reg RI;
wire pc_error;
assign pc_error=pc[1:0]!=2'b00;
reg [13:0]Temp_EXP;
//---Exp_Second_new 的各个位为1的情况
//  overflow->1
//  RI->2
//  Syscall->3
//  Break->4
//  Eret->5
//  iaddr_error->6
//  overflow->7
//  daddr_error_read/write->8
always@(*)
begin
    if(is_nop==1'b1)begin
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        =30'd0; 
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
    end
    else begin
    case(opcode) 
        // 6'b000100:begin//BEQ
        // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        // ={`BEQ_OP,2'b00,1'b1,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,`BEQ}; 
        // Temp_EXP=Exp_Second_old;
        // RI=1'b0;
        // end
        // 6'b000101:begin//BNE
        // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        // ={`BNE_OP,2'b00,1'b1,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,`BNE};
        // Temp_EXP=Exp_Second_old;
        // RI=1'b0; 
        // end
        // 6'b000001:begin//BGEZ
        // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        // ={`BGEZ_OP,2'b00,1'b1,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,`BGEZ};
        // Temp_EXP=Exp_Second_old;
        // RI=1'b0;  
        // end
        // 6'b000111:begin//BGTZ
        // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        // ={`BGTZ_OP,2'b00,1'b1,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,`BGTZ};
        // Temp_EXP=Exp_Second_old;
        // RI=1'b0; 
        // end
        // 6'b000110:begin//BLEZ
        // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        // ={`BLEZ_OP,2'b00,1'b1,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,`BLEZ};
        // Temp_EXP=Exp_Second_old;
        // RI=1'b0; 
        // end
        // 6'b000001:begin//BLTZ
        // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        // ={`BLTZ_OP,2'b00,1'b1,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,`BLTZ}; 
        // Temp_EXP=Exp_Second_old;
        // RI=1'b0;
        // end
        // 6'b000001:begin
        //     case(rt)begin
        //     5'b10001:begin//BGEZAL
        //     {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        //     ={`BGEZAL_OP,2'b00,1'b1,1'b1,5'b11111,1'b0,2'b00,4'b0000,1'b0,2'b00,`BLTZ};
        //     Temp_EXP=Exp_Second_old;
        //     RI=1'b0;
        //     end
        //     5'b10000:begin//BLTZAL
        //     {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        //     ={`BLTZAL_OP,2'b00,1'b1,1'b1,5'b11111,1'b0,2'b00,4'b0000,1'b0,2'b00,`BLTZ};
        //     Temp_EXP=Exp_Second_old;
        //     RI=1'b0;
        //     end
        //     default:begin
        //     RI=1'b1;
        //     Temp_EXP=Exp_Second_old;
        //     {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}=30'd0; 
        //     end
        //     endcase//case(rt)
        // end
        // 6'b000010:begin//j
        // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        // ={`J_OP,2'b00,1'b1,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,`J};
        // Temp_EXP=Exp_Second_old;
        // RI=1'b0; 
        // end
        // 6'b000011:begin//JAL
        // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        // ={`JAL_OP,2'b00,1'b1,1'b1,5'b11111,1'b0,2'b00,4'b0000,1'b0,2'b00,`JAL};
        // Temp_EXP=Exp_Second_old;
        // RI=1'b0;
        // end
        6'b001010:begin//slti
         {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`SLTI_OP,2'b01,1'b1,1'b1,rt,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000}; 
        Temp_EXP=Exp_Second_old;
        RI=1'b0; 
        end
         6'b001011:begin//sltiu
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`SLTIU_OP,2'b01,1'b1,1'b1,rt,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000}; 
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b100011:begin//lw
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`LW_OP,2'b01,1'b1,1'b1,rt,1'b0,2'b01,4'b1111,1'b0,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b100000:begin//lb
         {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`LB_OP,2'b01,1'b1,1'b1,rt,1'b0,2'b01,4'b0001,1'b1,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b100100:begin//lbu
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`LBU_OP,2'b01,1'b1,1'b1,rt,1'b0,2'b01,4'b0001,1'b0,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b100001:begin//lh
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`LH_OP,2'b01,1'b1,1'b1,rt,1'b0,2'b01,4'b0011,1'b1,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b100101:begin//lhu
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`LHU_OP,2'b01,1'b1,1'b1,rt,1'b0,2'b01,4'b0011,1'b0,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b101011:begin//sw
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`SW_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b10,4'b1111,1'b1,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b101000:begin//sb
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`SB_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b10,4'b1111,1'b1,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
		6'b101001:begin//sh
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`SH_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b10,4'b0011,1'b1,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b001111:begin//LUI
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`LUI_OP,2'b10,1'b0,1'b1,rt,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0; 
        end
        6'b001000:begin//ADDI
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`ADDI_OP,2'b01,1'b1,1'b1,rt,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b001001:begin//ADDIU
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`ADDIU_OP,2'b01,1'b1,1'b1,rt,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b001100:begin//ANDI
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`ANDI_OP,2'b01,1'b0,1'b1,rt,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b001101:begin//ORI
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`ORI_OP,2'b01,1'b0,1'b1,rt,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        6'b001110:begin//XORI
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={`XORI_OP,2'b01,1'b0,1'b1,rt,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
        Temp_EXP=Exp_Second_old;
        RI=1'b0;
        end
        // 6'b010000:begin
        //     if(func==6'b011000)begin//eret
        //     {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        //     ={`ERET_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000}; 
        //     Temp_EXP={Exp_Second_old[31:6],1'b1,Exp_Second_old[4:0]};
        //     RI=1'b0;
        //     end
        //     else if(rs==5'b00000)begin//MFC0
        //     {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        //     ={`MFC0_OP,2'b00,1'b0,1'b1,rt,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000}; 
        //     Temp_EXP=Exp_Second_old;
        //     RI=1'b0;
        //     //Read_CP0=1'b1;
        //     end
        //     else if(rs=5'b00100)begin//MTC0
        //     {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        //     ={`MTC0_OP,2'b00,1'b0,1'b0,5'b00000,1'b1,2'b00,4'b0000,1'b0,2'b00,4'b0000};
        //     Temp_EXP=Exp_Second_old;
        //     RI=1'b0;
        //     end
        //     else begin
        //     {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        //     =30'd0;
        //     RI=1'b1;
        //     Temp_EXP=Exp_Second_old;
        //     end
        // end
        6'b000000:begin//R type
            case(func)
            // 6'b001000:begin//JR
            // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            // ={`JR_OP,2'b00,1'b1,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,`JR};
            // Temp_EXP=Exp_Second_old;
            // RI=1'b0;
            // end
            // 6'b001001:begin//JALR
            // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            // ={`JALR_OP,2'b00,1'b1,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,`JALR};
            // Temp_EXP=Exp_Second_old;
            // RI=1'b0;
            // end
            6'b100000:begin//ADD
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`ADD_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b100001:begin//ADDU
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`ADDU_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0;  
            end
            6'b100010:begin//SUB
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SUB_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b100011:begin//SUBU
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SUBU_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b101010:begin//SLT
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SLT_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b101011:begin//SLTU
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SLTU_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b011010:begin//DIV
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`DIV_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b11,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b011011:begin//DIVU
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`DIVU_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b11,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0;  
            end
            6'b011000:begin//MULT
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`MULT_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b11,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b011001:begin//MULTU
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`MULTU_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b11,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            // 6'b000000:begin//nop
            // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            // ={`NOP_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};  
            // end
            6'b100100:begin//AND
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`AND_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b100111:begin//NOR
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`NOR_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b100101:begin//OR
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`OR_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b100110:begin//XOR
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`XOR_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b000100:begin//SLLV
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SLLV_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0;
            end
            6'b000000:begin//SLL
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SLL_OP,2'b10,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b000111:begin//SRAV
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SRAV_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b000011:begin//SRA
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SRA_OP,2'b10,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b000110:begin//SRLV
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SRLV_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            6'b000010:begin//SRL
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={`SRL_OP,2'b10,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            Temp_EXP=Exp_Second_old;
            RI=1'b0; 
            end
            // 6'b010000:begin//MFHI
            // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            // ={`MFHI_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            // Temp_EXP=Exp_Second_old;
            // RI=1'b0; 
            // end
            // 6'b010010:begin//MFLO
            // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            // ={`MFLO_OP,2'b00,1'b0,1'b1,rd,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            // Temp_EXP=Exp_Second_old;
            // RI=1'b0;  
            // end
            // 6'b010011:begin//MTHI
            // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            // ={`MTHI_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b10,4'b0000};
            // Temp_EXP=Exp_Second_old;
            // RI=1'b0; 
            // end
            // 6'b010011:begin//MTLO
            // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            // ={`MTLO_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b01,4'b0000};
            // Temp_EXP=Exp_Second_old;
            // RI=1'b0; 
            // end
            // 6'b001101:begin//BREAK
            // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            // ={`BREAK_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            // //Temp_EXP=Exp_Second_old;
            // RI=1'b0; 
            // Temp_EXP={Exp_Second_old[31:5],1'b1,Exp_Second_old[3:0]};
            // end
            // 6'b001100:begin//SYSCALL
            // {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            // ={`SYSCALL_OP,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};
            // Temp_EXP={Exp_Second_old[31:4],1'b1,Exp_Second_old[2:0]};
            // RI=1'b0;
            // end
            default:begin
            RI=1'b1;
            {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
            ={7'd0,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000};  
            Temp_EXP=Exp_Second_old;
            end//case R type
            endcase
        end
        default:begin
        {aluop,alu_src,if_signed_extend,Write_Reg_Enable,Write_Reg_Addr,Write_CP0_Enable,LS,LS_SIZE,LS_Signed,Write_HiLo,Branch_type}
        ={7'd0,2'b00,1'b0,1'b0,5'b00000,1'b0,2'b00,4'b0000,1'b0,2'b00,4'b0000}; 
        RI=1'b1;
        Temp_EXP=Exp_Second_old;
        end
    endcase//case(opcode)
    end
    if(pc_error==1'b1)begin
        Exp_Second_new={Temp_EXP[13:7],1'b1,Temp_EXP[5:0]};
    end
    else if(RI==1'b1)begin
        Exp_Second_new={Temp_EXP[13:3],1'b1,Temp_EXP[1:0]};
    end
    else begin
        Exp_Second_new=Temp_EXP;
    end

end
endmodule