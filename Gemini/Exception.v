module Exception(
    input wire [13:0] Exp_First,
    input wire [13:0] Exp_Second,
    input wire [1:0] mem_type_First,//if write or read mem
    input wire [31:0] PC_First,
    input wire [3:0]  Branch_type_First,//judge the first if branch,then the second is in the delayslot
    input wire [31:0] PC_Second,
    input wire [31:0] mem_address_First,
    input wire first_is_branch,
    input wire first_is_in_delayslot,
    input wire is_in_exp,//status[1]
    input wire [31:0] cp0_epc_address_to_branch,
    output reg [31:0] Exception_JUMP_PC,
    output wire has_exp,//is_exp_first||is_exp_second
    output reg is_exp_first,
    output reg is_exp_second,
    output reg exp_is_in_delayslot,
    output reg [31:0] cp0_epc,
    output reg wen_badaddress,
    output reg [31:0] cp0_badaddress,
    output reg [4:0] cp0_cause_code,
    output reg exp_clean

);
//---Exp_First_new 的各个位为1的情况
//  overflow->1
//  RI->2
//  Syscall->3
//  Break->4
//  Eret->5
//  iaddr_error->6
//  daddr_error_read/write->7
//  soft_int->8
wire overflow_first,Ri_first,syscall_first,break_first,eret_first,iaddr_error_first,daddr_error_first,soft_int_first;
wire overflow_second,Ri_second,iaddr_error_second;
wire wmem;//write mem
assign overflow_first=Exp_First[1];
assign Ri_first=Exp_First[2];
assign syscall_first=Exp_First[3];
assign break_first=Exp_First[4];
assign eret_first=Exp_First[5];
assign iaddr_error_first=Exp_First[6];
assign daddr_error_first=Exp_First[7];
assign soft_int_first=Exp_First[8];
assign overflow_second=Exp_Second[1];
assign Ri_second=Exp_Second[2];
assign iaddr_error_second=Exp_Second[6];
assign wmem=(mem_type_First==2'b10);//judge if inst is store
assign has_exp=(is_exp_first||is_exp_second);
always@(*)begin
    Exception_JUMP_PC=32'hBFC00380;
    is_exp_first=1'b0;
    exp_is_in_delayslot=first_is_in_delayslot;
    cp0_epc=first_is_in_delayslot?PC_First-32'd4:PC_First;
    cp0_badaddress=(mem_type_First==2'b00)?PC_First:mem_address_First;
    cp0_cause_code=5'h0;
    exp_clean=1'b0;
    wen_badaddress=1'b0;
    if(soft_int_first)begin
        wen_badaddress=1'b1;
        //exp_clean=1'b0;
        cp0_cause_code=5'h0;
        is_exp_first=1'b1;
        is_exp_second=1'b0;
    end
    else if(iaddr_error_first)begin//fetch address
        is_exp_first=1'b1;
        is_exp_second=1'b0;
        cp0_cause_code=5'h04;
        wen_badaddress=1'b1;
    end
    else if(Ri_first)begin
        is_exp_first=1'b1;
        is_exp_second=1'b0;
        cp0_cause_code=5'h0a;
        wen_badaddress=1'b1;
    end
    else if(overflow_first)begin
        is_exp_first=1'b1;
        is_exp_second=1'b0;
        cp0_cause_code=5'h0c;
    end
    else if(syscall_first)begin
        is_exp_first=1'b1;
        is_exp_second=1'b0;
        cp0_cause_code=5'h08;
    end
    else if(break_first)begin
        is_exp_first=1'b1;
        is_exp_second=1'b0;
        cp0_cause_code=5'h09;
    end
    else if(eret_first)begin
        is_exp_first=1'b1;
        is_exp_second=1'b0;
        exp_clean=1'b1;
        Exception_JUMP_PC=cp0_epc_address_to_branch;
    end
    else if(daddr_error_first)begin//if store
        is_exp_first=1'b1;
        is_exp_second=1'b0;
        wen_badaddress=1'b1;
        if(wmem==1'b1)begin
        cp0_cause_code=5'h05;
        end
        else begin
        cp0_cause_code=5'h04;
        end
    end
    else if(iaddr_error_second)begin
        is_exp_second=1'b1;
        cp0_cause_code=5'h04;
        wen_badaddress=1'b1;
        cp0_badaddress=PC_Second;
        exp_is_in_delayslot=first_is_branch;
        cp0_epc=(first_is_branch)?PC_First:PC_Second;
    end
    else if(Ri_second)begin
        is_exp_second=1'b1;
        cp0_cause_code=5'h0a;
        wen_badaddress=1'b0;
        cp0_badaddress=PC_Second;
        exp_is_in_delayslot=first_is_branch;
        cp0_epc=(first_is_branch)?PC_First:PC_Second;
    end
    else if(overflow_second)begin
        is_exp_second=1'b1;
        cp0_cause_code=5'h0c;
        exp_is_in_delayslot=first_is_branch;
        cp0_epc=(first_is_branch)?PC_First:PC_Second;
    end
    else begin
        Exception_JUMP_PC=32'hBFC00380;
        is_exp_first=1'b0;
        is_exp_second=1'b0;
        exp_is_in_delayslot=first_is_in_delayslot;
        cp0_epc=first_is_in_delayslot?PC_First-32'd4:PC_First;
        cp0_badaddress=(mem_type_First==2'b00)?PC_First:mem_address_First;
        cp0_cause_code=5'h0;
        exp_clean=1'b0;
        wen_badaddress=1'b0;
    end

end








endmodule