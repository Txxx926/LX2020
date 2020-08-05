`include "define.v"
module Id_branch(
    input wire [31:0] reg_rs,
    input wire [31:0] reg_rt,
    input wire [3:0] Branch_Type,
    output reg Branch_Taken
);
always@(*)begin
    case(Branch_Type)
    `BEQ:begin
        //$display("is Branch instr!!!,type is BEQ");
        if(reg_rs==reg_rt)begin
        Branch_Taken=1'b1;
        //$display("BEQ Branch Taken");
        end
        else begin
        Branch_Taken=1'b0;
        //$display("BEQ Branch not Taken");
        end
    end
    `BNE:begin
        if(reg_rs!=reg_rt)begin
        Branch_Taken=1'b1;
        end
        else begin
        Branch_Taken=1'b0;
        end
    end
    `BGEZ:begin
        if(reg_rs[31]!=1'b1)begin
        Branch_Taken=1'b1;
        end
        else begin
        Branch_Taken=1'b0;
        end
    end
    `BGTZ:begin
        if(reg_rs[31]!=1'b1&&reg_rs!=32'h0)begin
        Branch_Taken=1'b1;
        end
        else begin
        Branch_Taken=1'b0;
        end
    end
    `BLEZ:begin
        if(reg_rs[31]==1'b1||reg_rs==32'h0)begin
        Branch_Taken=1'b1;
        end
        else begin
        Branch_Taken=1'b0;
        end
    end
    `BLTZ:begin
        if(reg_rs[31]==1'b1)begin
        Branch_Taken=1'b1;
        end
        else begin
        Branch_Taken=1'b0;
        end
    end
    `BGEZAL:begin
       if(reg_rs[31]!=1'b1)begin
        Branch_Taken=1'b1;
        end
        else begin
        Branch_Taken=1'b0;
        end 
    end
    `BLTZAL:begin
        if(reg_rs[31]==1'b1)begin
        Branch_Taken=1'b1;
        end
        else begin
        Branch_Taken=1'b0;
        end 
    end
    `J:begin
        Branch_Taken=1'b1;
    end
    `JAL:begin
        Branch_Taken=1'b1;
    end
    `JR:begin
        Branch_Taken=1'b1;
    end
    `JALR:begin
        Branch_Taken=1'b1;
    end
    default:begin
        Branch_Taken=1'b0;
    end
    endcase
end

endmodule