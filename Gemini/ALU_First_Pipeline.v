`include "define.v"
module ALU_First_Pipeline(
    input wire clk,
    input wire resetn,
    input wire flush,
    input  wire  [31:0]  busa,
    input  wire  [31:0]  busb,
    input  wire  [63:0]  HiLo,
    input  wire  [6:0]  aluop,
    input  wire  [31:0] pc,
    input  wire  [13:0] Exp_First_old,//exp[1]==1'b1,if overflow;
    input  wire  [31:0] CP0_Data,
    output reg  [13:0] Exp_First_new,
    output reg  [31:0] Out,
    output reg  [63:0] WHILO_Data,
    output  stall// multicycle
);
//Out source HILO,ALU_Result,CP0,rs,rt,
wire [31:0] Hi;
wire [31:0] Lo;
wire [31:0] temp_result;
wire [4:0] sa;
assign sa=busa[10:6];
assign Hi=HiLo[63:32];
assign Lo=HiLo[31:0];
//stall
always@(*)begin
    case(aluop)
        `LB_OP,`LBU_OP,`LH_OP,`LHU_OP,`LW_OP,`SB_OP,`SH_OP,`SW_OP,`ADD_OP,`ADDI_OP,`ADDU_OP,`ADDIU_OP:begin
        Out=busa+busb;
        end
        `SUB_OP,`SUBU_OP:begin
        Out=busa-busb;
        end
        `SLT_OP,`SLTI_OP:begin
        Out=($signed(busa)<$signed(busb))?32'd1:32'd0;
        end
        `SLTU_OP,`SLTIU_OP:begin
        Out=(busa<busb)?32'd1:32'd0;
        end
        `AND_OP,`ANDI_OP:begin
        Out=busa&busb;
        end
        `LUI_OP:begin
        Out={busa[15:0],16'd0};
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
        `MFC0_OP:begin
        Out=CP0_Data;
        end
        `MTC0_OP:begin
        Out=busb;
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
        Out=($signed(busb))>>>(busa[4:0]);
        end
        `SRA_OP:begin
        Out=($signed(busb))>>>sa;
        end
        `MFHI_OP:begin
        Out=Hi;
        end
        `MFLO_OP:begin
        Out=Lo;
        end
        `MTHI_OP,`MTLO_OP:begin
        Out=busa;
        end
        `BGEZAL_OP,`BLTZAL_OP,`JALR_OP,`JAL_OP:begin
        Out=pc+32'd8;
        end
        default:begin
        Out=32'h0;
        end
    endcase
end
always@(*)begin//overflow
    case(aluop)
        `ADD_OP,`ADDI_OP:begin
            if((~(busa[31] ^ busb[31])) & (Out[31] ^ busa[31]))begin
                Exp_First_new={Exp_First_old[13:2],1'b1,Exp_First_old[0]};
            end
            else begin
                Exp_First_new=Exp_First_old;
            end

        end
        `SUB_OP:begin
            if((busa[31]^busb[31]) & (busa[31]^Out[31]))begin
                Exp_First_new={Exp_First_old[13:2],1'b1,Exp_First_old[0]};
            end
            else begin
                Exp_First_new=Exp_First_old;
            end
        end
        default:begin
        Exp_First_new=Exp_First_old;
        end
    endcase
end
//div and mul
    //div and mul
    reg             mult_done_prev, div_done_prev;
    wire             mult_done, div_done;
    wire [63:0]      _hilo_mult, _hilo_div;
    reg [1:0]       mult_op, div_op;
    wire            mult_commit, div_commit;
    // Pipeline control.
    reg             mdu_prepare;
    wire            mdu_running = ~(mult_done & div_done) || mdu_prepare;
    

    assign stall      = flush? 0 : (mdu_running);                      //stall待处理,flush_i为输入信号
    assign mult_commit  = mult_done && (mult_done_prev != mult_done);      //是否可以提交乘法的结果
    assign div_commit   = div_done && (div_done_prev != div_done);         //是否可以提交除法的结果

    always @ (posedge clk) begin
        if(!resetn) begin
            mult_done_prev <= 1'b0;
            div_done_prev <= 1'b0;
        end
        else begin
            mult_done_prev <= mult_done;
            div_done_prev <= div_done;
        end
    end

    // The mult/div unit.
    //div_op和mult_op是乘除法开始的标志
    always @ ( * ) begin
        div_op = 2'b00;
        mult_op = 2'b00;
        mdu_prepare = 1'b0;
        if(!flush && (mult_done & div_done) && (mult_done_prev == mult_done) && (div_done_prev == div_done)) begin //flush_i信号
            mdu_prepare = 1'b1;
            case(aluop)
                ///////////////////////
                //更改此处case里的op
                ///////////////////////
                `DIV_OP: begin
                    div_op = 2'b10;
                    //div_start = 1'b1;
                end
                `DIVU_OP: begin
                    div_op = 2'b01;
                    //div_start = 1'b1;
                end
                `MULT_OP: begin
                    mult_op = 2'b10;
                    //mul_start = 1'b1;
                end
                `MULTU_OP: begin
                    mult_op = 2'b01;
                    //mul_start = 1'b1;
                end
                default: begin
                    mdu_prepare = 1'b0;
                end
            endcase
        end
        else begin
            mdu_prepare = 1'b0;
        end
    end

    divider div(
        .clk        (clk),
        .resetn     (resetn),
        .div_op     (div_op),
        .divisor    (busb),
        .dividend   (busa),
        .result     (_hilo_div),
        .done       (div_done)
    );

    multplier mult(
        .clk        (clk),
        .resetn     (resetn),
        .op         (mult_op),
        .a          (busa),
        .b          (busb),
        .c          (_hilo_mult),
        .done       (mult_done)
    );

    //commit div and mult result
    ///////////////////////////////
    //reg HILO_write_en_temp;
    //assign HILO_write_en = HILO_write_en_temp;
    always @ ( * ) begin
        //HILO_write_en = 1'd1;
        WHILO_Data = 64'd0;
        if(div_commit)
            WHILO_Data = _hilo_div;
        else if(mult_commit) begin
                WHILO_Data = _hilo_mult;
            end
        else begin
            case(aluop)
            `MTHI_OP:begin
            WHILO_Data={busa,Lo};
            end
            `MTLO_OP:begin
            WHILO_Data={Hi,busa};
            end
            endcase
        end
    end



endmodule