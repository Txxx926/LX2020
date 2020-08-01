module Operand_Select(
    input wire [31:0] reg_rs,//bypass
    input wire [31:0] reg_rt,//bypass in other module,pass to the next pipeline
    input wire [15:0] imm,
    input wire imm_extend_signed,
    input wire [1:0]  alu_src,
    output reg [31:0] busa,
    output reg [31:0] busb
);
wire [31:0] extended_imm;
assign extended_imm=(imm_extend_signed==1'b0)?{16'd0,imm}:{{16{imm[15]}},imm};

always@(*)begin
    if(alu_src==2'b00)begin
        busa=reg_rs;
        busb=reg_rt;
    end
    else if(alu_src==2'b01)begin
        busa=reg_rs;
        busb=extended_imm;
    end
    else if(alu_src==2'b10)begin
        busa=extended_imm;
        busb=reg_rt;
    end
    else begin
        busa=reg_rs;
        busb=reg_rt;
    end
end
endmodule