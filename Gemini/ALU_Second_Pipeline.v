`include "define.v"
module ALU_Second_Pipeline(
    input  wire  [31:0]  busa,
    input  wire  [31:0]  busb,
    input  wire  [63:0]  HiLo,//unused in second pipeline 
    input  wire  [6:0]  aluop,
    input  wire  [13:0] Exp_Second_old,//exp[1]==1'b1,if overflow;
    input  wire  [31:0] CP0_Data,//unused in second pipeline
    output reg  [13:0] Exp_Second_new,
    output reg  [31:0] Out,
    output reg  [63:0] WHILO_Data//unused in second pipeline
);
//Out source HILO,ALU_Result,CP0,rs,rt,
//wire [31:0] Hi,Lo;
wire [31:0] temp_result;
wire [4:0] sa=busa[10:6];
//assign Hi=HiLo[63:32];
//assign Lo=HiLo[31:0];
always@(*)begin
    case(aluop)
        `ADD_OP,`ADDI_OP,`ADDU_OP,`ADDIU_OP:begin
        Out=busa+busb;
        end
        `SUB_OP,`SUBU_OP:begin
        Out=busa-busb;
        end
        `SLT_OP,`SLTI_OP:begin
        Out=($signed(busa)<$signed(busb))?32'h1:32'h0;
        end
        `SLTU_OP,`SLTIU_OP:begin
        Out=(busa<busb)?32'h1:32'h0;//!!!!!!!
        end
        `AND_OP,`ANDI_OP:begin
        Out=busa&busb;
        end
        `LUI_OP:begin
        Out={busa[15:0],16'h0};
        end
        `NOR_OP:begin
        Out=~(busa|busb);
        end
        `OR_OP,`ORI_OP:begin
        Out=busa|busb;
        end
        `XOR_OP,`XORI_OP:begin
        Out=busa^busb;
        end
        `SLLV_OP:begin
        Out=busb<<busa[4:0];
        end
        `SLL_OP:begin
        Out=busb<<sa;
        end
        `SRLV_OP:begin
        Out=busb>>busa[4:0];
        end
        `SRL_OP:begin
        Out=busb>>sa;
        end
        `SRAV_OP:begin
        Out=$signed(busb)>>>(busa[4:0]);
        end
        `SRA_OP:begin
        Out=$signed(busb)>>>sa;
        end
        default:begin
        Out=32'h0;
        end
    endcase
end
always@(*)begin//overflow
    case(aluop)
        `ADD_OP,`ADDI_OP:begin
            if(((busa[31] ~^ busb[31]) & (busa[31] ^ Out[31])))begin
                Exp_Second_new={Exp_Second_old[13:2],1'b1,Exp_Second_old[0]};
            end
            else begin
                Exp_Second_new=Exp_Second_old;
            end

        end
        `SUB_OP:begin
            if((busa[31]  ^ busb[31]) & (busa[31] ^ Out[31]))begin
                Exp_Second_new={Exp_Second_old[13:2],1'b1,Exp_Second_old[0]};
            end
            else begin
                Exp_Second_new=Exp_Second_old;
            end
        end
        default:begin
        Exp_Second_new=Exp_Second_old;
        end
    endcase
end

endmodule