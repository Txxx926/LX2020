`include "define.v"
module Branch(
    input wire [31:0] reg_rs,
    input wire [31:0] reg_rt,
    input wire [15:0] imm,
    input wire [31:0] pc,
    input wire [25:0] instr_index,
    input wire [3:0] Branch_Type,
    output reg Branch_Taken,
    output reg [31:0] Branch_Address
);
wire [31:0]Target_PC1;
wire [31:0]Target_PC2;
wire [31:0]Target_PC3;
wire [31:0]pc_add4;
assign pc_add4=pc+32'd4;
assign Target_PC1=pc_add4+{{14{imm[15]}},imm,2'b00};
assign Target_PC2={pc_add4[31:28],instr_index,2'b00};
assign Target_PC3=reg_rs;

always@(*)begin
    case(Branch_Type)
    `BEQ:begin
        //$display("is Branch instr!!!,type is BEQ");
        if(reg_rs==reg_rt)begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC1;
        //$display("BEQ Branch Taken");
        end
        else begin
        Branch_Taken=1'b0;
        Branch_Address=32'hx;
        //$display("BEQ Branch not Taken");
        end
    end
    `BNE:begin
        if(reg_rs!=reg_rt)begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC1;
        end
        else begin
        Branch_Taken=1'b0;
        Branch_Address=32'hx;
        end
    end
    `BGEZ:begin
        if(reg_rs[31]!=1'b1)begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC1;
        end
        else begin
        Branch_Taken=1'b0;
        Branch_Address=32'hx;
        end
    end
    `BGTZ:begin
        if(reg_rs[31]!=1'b1&&reg_rs!=32'h0)begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC1;
        end
        else begin
        Branch_Taken=1'b0;
        Branch_Address=32'hx;
        end
    end
    `BLEZ:begin
        if(reg_rs[31]==1'b1||reg_rs==32'h0)begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC1;
        end
        else begin
        Branch_Taken=1'b0;
        Branch_Address=32'hx;
        end
    end
    `BLTZ:begin
        if(reg_rs[31]==1'b1)begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC1;
        end
        else begin
        Branch_Taken=1'b0;
        Branch_Address=32'hx;
        end
    end
    `BGEZAL:begin
       if(reg_rs[31]!=1'b1)begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC1;
        end
        else begin
        Branch_Taken=1'b0;
        Branch_Address=32'hx;
        end 
    end
    `BLTZAL:begin
        if(reg_rs[31]==1'b1)begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC1;
        end
        else begin
        Branch_Taken=1'b0;
        Branch_Address=32'hx;
        end 
    end
    `J:begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC2;
    end
    `JAL:begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC2;
    end
    `JR:begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC3;
    end
    `JALR:begin
        Branch_Taken=1'b1;
        Branch_Address=Target_PC3;
    end
    default:begin
        Branch_Taken=1'b0;
        Branch_Address=32'hx;
    end
    endcase
end

endmodule