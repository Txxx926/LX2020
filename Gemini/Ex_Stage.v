module Ex_Stage(
    input wire clk,
    input wire resetn,
    input wire flush,
    input wire [31:0] reg_rs_first,//the result of forwarding
    input wire [31:0] reg_rt_first,
    input wire [15:0] imm_first,
    input wire imm_extend_signed_first,
    input wire [1:0] alu_src_first,
    input wire [31:0] reg_rs_second,
    input wire [31:0] reg_rt_second,
    input wire [15:0] imm_second,
    input wire imm_extend_signed_second,
    input wire [1:0] alu_src_second, 
    input wire [13:0] Exp_First_old,
    input wire [13:0] Exp_Second_old,
    input wire [6:0] aluop_first,
    input wire [6:0] aluop_second,
    input wire [31:0] pc_first,
    input wire [31:0] Instr_first,
    input wire [3:0] Branch_Type_first,
    input wire [63:0] HiLo,//from HiLo reg
    input wire [31:0] CP0_Data,
    output [13:0] Exp_First_new_end,
    output [13:0] Exp_Second_new,
    output [31:0] Out_First,
    output [31:0] Out_Second,
    output [63:0] WHILO_Data,
    output Branch_Taken,
    output [31:0] Branch_Address,
    output [31:0] reg_rt_first_o,
    output wire ex_stall,
    input mul_div_new
);
assign reg_rt_first_o=reg_rt_first;
wire [31:0] busa_first,busb_first,busa_second,busb_second;
wire [13:0] Exp_First_new;
assign Exp_First_new_end=(Branch_Taken&&Branch_Address==pc_first)?{Exp_First_new[13:9],1'b1,Exp_First_new[7:0]}:Exp_First_new;
Operand_Select Operand_First(
    .reg_rs(reg_rs_first),//input wire [31:0] reg_rs,//bypass
    .reg_rt(reg_rt_first),//input wire [31:0] reg_rt,//bypass in other module,pass to the next pipeline
    .imm(imm_first),//input wire [15:0] imm,
    .imm_extend_signed(imm_extend_signed_first),//input wire imm_extend_signed,
    .alu_src(alu_src_first),//input wire [1:0]  alu_src,
    .busa(busa_first),//output reg [31:0] busa, 
    .busb(busb_first)//output reg [31:0] busb
);
Operand_Select Operand_Second(
    .reg_rs(reg_rs_second),//input wire [31:0] reg_rs,//bypass
    .reg_rt(reg_rt_second),//input wire [31:0] reg_rt,//bypass in other module,pass to the next pipeline
    .imm(imm_second),//input wire [15:0] imm,
    .imm_extend_signed(imm_extend_signed_second),//input wire imm_extend_signed,
    .alu_src(alu_src_second),//input wire [1:0]  alu_src,
    .busa(busa_second),//output reg [31:0] busa,
    .busb(busb_second)//output reg [31:0] busb
);
// always@(posedge clk)begin
//     if(aluop_first!=7'd0)begin
//         $display("busa_first=0x%8h,busb_first=0x%8h,aluop_first=%7b",busa_first,busb_first,aluop_first);
//     end
// end
 ALU_First_Pipeline ALU_First_Pipeline0(
    .mul_div_new(mul_div_new),
    .clk(clk),
    .resetn(resetn),
    .flush(flush),
    .busa(busa_first),//input  wire  [31:0]  busa,
    .busb(busb_first),//input  wire  [31:0]  busb,
    .HiLo(HiLo),//input  wire  [63:0]  HiLo,
    .aluop(aluop_first),//input  wire  [6:0]  aluop,
    .pc(pc_first),//input  wire  [31:0] pc,
    .Exp_First_old(Exp_First_old),//input  wire  [13:0] Exp_First_old,//exp[1]==1'b1,if overflow;
    .CP0_Data(CP0_Data),//input  wire  [31:0] CP0_Data,
    .Exp_First_new(Exp_First_new),//output reg  [13:0] Exp_First_new,
    .Out(Out_First),//output reg  [31:0] Out,
    .WHILO_Data(WHILO_Data),//output reg  [63:0] WHILO_Data,
    .stall(ex_stall)//output reg stall// multicycle
);

ALU_Second_Pipeline ALU_Second_Pipeline0(
    .busa(busa_second),//input  wire  [31:0]  busa,
    .busb(busb_second),//input  wire  [31:0]  busb,
    .HiLo(),//unused in second pipeline 
    .aluop(aluop_second),//input  wire  [6:0]  aluop,
    .Exp_Second_old(Exp_Second_old),//input  wire  [13:0] Exp_Second_old,//exp[1]==1'b1,if overflow;
    .CP0_Data(),//unused in second pipeline
    .Exp_Second_new(Exp_Second_new),//output reg  [13:0] Exp_Second_new,
    .Out(Out_Second),//output reg  [31:0] Out,
    .WHILO_Data()//unused in second pipeline
);
Branch Branch0(//first pipeline
    .reg_rs(reg_rs_first),
    .reg_rt(reg_rt_first),
    .imm(imm_first),
    .pc(pc_first),
    .instr_index(Instr_first[25:0]),
    .Branch_Type(Branch_Type_first),
    .Branch_Taken(Branch_Taken),
    .Branch_Address(Branch_Address)
);
endmodule