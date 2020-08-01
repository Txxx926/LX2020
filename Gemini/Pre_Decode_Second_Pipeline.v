module Pre_Decode_Second_Pipeline(
    input wire [31:0] Instr_Second,
    output reg is_Branch_Instr,//to Issue Judge
    output reg is_Trap_Priv_Instr,//to Issue Judge
    output reg is_HiLoRelated_Instr,//to Issue Judge
    output wire [5:0] opcode,
    output wire [5:0] func,
    output wire [4:0] rs,
    output wire [4:0] rt,
    output wire [4:0] rd,
    output wire [2:0] sel,
    output wire [15:0] offset_imm,
    output wire is_nop
);
//Split The Instruction
assign opcode=Instr_Second[31:26];
assign func=Instr_Second[5:0];
assign rs=Instr_Second[25:21];
assign rt=Instr_Second[20:16];
assign rd=Instr_Second[15:11];
assign offset_imm=Instr_Second[15:0];
assign sel=Instr_Second[2:0];
assign is_nop=(Instr_Second==32'h0);
always@(*)begin
    //is_Branch_Instr=1'b0;
    case (opcode)
    6'b000100,6'b000101,6'b000001,6'b000111,6'b000110,6'b000010,6'b000011:begin
        is_Branch_Instr=1'b1;
        end
    6'b000000:begin
            case(func)
            6'b001000:begin
            is_Branch_Instr=1'b1;//JR
            end
            6'b001001:begin
            is_Branch_Instr=1'b1;//JALR
            end
            default:begin
            is_Branch_Instr=1'b0;
            end
            endcase
        end
    default:begin
        is_Branch_Instr=1'b0;
        end
    endcase
end
always@(*)begin
    if(opcode==6'b000000&&(func==6'b001100||func==6'b001101))begin//syscall,break
        is_Trap_Priv_Instr=1'b1;
    end
    else if(opcode==6'b010000&&func==6'b011000)begin//eret
        is_Trap_Priv_Instr=1'b1;
    end
    else if(opcode==6'b010000&&(rs==5'b00000||rs==5'b00100))begin//mtc0,mfc0
        is_Trap_Priv_Instr=1'b1;
    end
    else begin
        is_Trap_Priv_Instr=1'b0;
    end
end
always@(*)begin
    if(opcode==6'b000000&&(func==6'b011000||func==6'b011001||func==6'b011010||func==6'b011011||func==6'b010000||func==6'b010010||func==6'b010001||func==6'b010011))begin//MULT,MULTU,DIV,DIVU,mfhi,mflo,mthi,mtlo
        is_HiLoRelated_Instr=1'b1;
    end
    else begin
        is_HiLoRelated_Instr=1'b0;
    end
end
endmodule