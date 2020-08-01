module Mem_Stage(
    input wire clk,
    input wire resetn,
    input wire [5:0] int_,
    input wire [31:0] aluout_first,
    input wire [31:0] reg_rt,
    input wire signed_load,
    input wire first_is_in_delayslot,
    input wire [13:0] Exp_First,
    input wire [13:0] Exp_Second,
    input wire [1:0] mem_type_First,
    input wire [31:0] PC_First,
    input wire [3:0] Branch_type_First,
    input wire [31:0] PC_Second,
    input wire [3:0] mem_byte_select,
    input wire [7:0] cp0_addr,
    input wire [7:0] cp0_write_addr,
    input wire write_cp0_enable,
    input wire [31:0] write_cp0_data,
    output is_exp_first,
    output is_exp_second,
    output [31:0] cp0_data,
    output [31:0] d_addr,
    output [31:0] d_wdata,
    output [2:0]  d_size,
    output [1:0]  d_en,
    output [3:0]  w_byte_select,
    input  [31:0] d_rdata,
    output [31:0] data_mem,//to wb
    output has_exp,//flush the previous stages
    output [31:0] Exception_JUMP_PC
);

wire exp_is_in_delayslot,wen_badaddress,is_in_exp,exp_clean;
wire [31:0] exp_badaddress,exp_epc,epc_to_Exception;
wire [4:0] exp_cause_code;
wire is_exp_first_mem,is_exp_second_mem;
assign is_exp_first=is_exp_first_mem;
assign is_exp_second=is_exp_second_mem;
reg [13:0] Exp_First_end;
always@(*)begin
    if(mem_type_First==2'b00)begin
        Exp_First_end=Exp_First;
    end
    else begin
        if(mem_byte_select==4'b1111)begin
            if(aluout_first[1:0]!=2'b00)begin
                Exp_First_end={Exp_First[13:8],1'b1,Exp_First[6:0]};
            end
            else begin
                Exp_First_end=Exp_First;
            end
        end
        else if(mem_byte_select==4'b0011)begin
            if(aluout_first[0]!=1'b0)begin
                Exp_First_end={Exp_First[13:8],1'b1,Exp_First[6:0]};
            end
            else begin
                Exp_First_end=Exp_First;
            end
        end
        else begin//0001
            Exp_First_end=Exp_First;
        end
    end
end
 mem mem0(
    //to ex
    .addr_ex(aluout_first),//32 bit,aluout ex
    .is_stall(is_exp_first),// from Exception,is exception
    .ls(mem_type_First),//memtype 2 bit
    .byte_select_ex(mem_byte_select),//w_b_s 4 bit
    .data_ex(reg_rt),// reg rt 32 bit
    .sign(signed_load),
    //to mmu(DCache)
    .d_addr(d_addr),
    .d_wdata(d_wdata),
    .d_size(d_size),//3 bit
    .d_en(d_en), //2 bit
    .w_byte_select(w_byte_select),//4 bit
    .d_rdata(d_rdata),// 32 bit
    // to wb
    .data_mem(data_mem)//32 bit
);
assign first_is_branch=(Branch_type_First!=4'b0000);
 Exception Exception0(
    .Exp_First(Exp_First_end),//input wire [13:0] Exp_First,
    .Exp_Second(Exp_Second),//input wire [13:0] Exp_Second,
    .mem_type_First(mem_type_First),//input wire [1:0] mem_type_First,//if write or read mem
    .PC_First(PC_First),//input wire [31:0] PC_First,
    .Branch_type_First(Branch_type_First),//input wire [3:0]  Branch_type_First,//judge the first if branch,then the second is in the delayslot
    .PC_Second(PC_Second),//input wire [31:0] PC_Second,
    .mem_address_First(aluout_first),//input wire [31:0] mem_address_First,//ex_aluout
    .first_is_branch(first_is_branch),//input wire first_is_branch,
    .first_is_in_delayslot(first_is_in_delayslot),//input wire first_is_in_delayslot,
    .is_in_exp(is_in_exp),//input wire is_in_exp,//status[1]
    .cp0_epc_address_to_branch(epc_to_Exception),//input wire [31:0] cp0_epc_address_to_branch,
    .Exception_JUMP_PC(Exception_JUMP_PC),//output reg [31:0] Exception_JUMP_PC,
    .has_exp(has_exp),//output wire has_exp,//is_exp_first||is_exp_second
    .is_exp_first(is_exp_first_mem),//output reg is_exp_first,
    .is_exp_second(is_exp_second_mem),//output reg is_exp_second,
    .exp_is_in_delayslot(exp_is_in_delayslot),//output reg exp_is_in_delayslot,
    .cp0_epc(exp_epc),//output reg [31:0] cp0_epc,
    .wen_badaddress(wen_badaddress),//output reg wen_badaddress,
    .cp0_badaddress(exp_badaddress),//output reg [31:0] cp0_badaddress,
    .cp0_cause_code(exp_cause_code),//output reg [4:0] cp0_cause_code,
    .exp_clean(exp_clean)//output reg exp_clean,
);
 CP0 CP00(
    .clk(clk),
    .resetn(resetn),
    .int_(int_),
    .has_exp(has_exp),//from exception
    .exp_first(is_exp_first_mem),
    .exp_second(is_exp_second_mem),
    .cp0_addr(cp0_addr),
    .cp0_write_addr(cp0_write_addr),
    .write_cp0_enable(write_cp0_enable),
    .write_cp0_data(write_cp0_data),
    .exp_is_in_delayslot(exp_is_in_delayslot),
    .wen_badaddress(wen_badaddress),
    .exp_badaddress(exp_badaddress),
    .exp_epc(exp_epc),
    .exp_cause_code(exp_cause_code),
    .exp_clean(exp_clean),
    .epc_to_Exception(epc_to_Exception),
    .cp0_data(cp0_data),
    .is_in_exp(is_in_exp)
);








endmodule