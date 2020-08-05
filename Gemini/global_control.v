`include "define.v"
module global_control(
        input               clk,
        input               resetn,
        input               icache_stall,
        input               ex_stall,
        input               mem_stall,
        
        input [6:0]         id_ex_alu_op,
        input [1:0]         id_ex_mem_type,
        input [4:0]         id_ex_mem_wb_reg_dest,
        input               ex_mem_cp0_wen,
        input [1:0]         ex_mem_mem_type,
        input [4:0]         ex_mem_mem_wb_reg_dest,
        input [4:0]         id_rs,
        input [4:0]         id_rt,
        input               ex_branch_taken,
        input               fifo_full,
        input               fifo_1_left,
        input               exp_detect,
        input               Branch_first,
        input               fifo_2_left,
        //input [31:0]        Instr_First_id_in,

        output wire        en_if,
        output wire        en_if_id,
        output wire        en_id_ex,
        output wire        en_ex_mem,
        output wire        en_mem_wb
);

    reg [4:0] en;
    assign { en_if, en_if_id, en_id_ex, en_ex_mem, en_mem_wb } = en;
    
    always@(*) begin 
        if(~resetn)
            en = 5'b11111;
        else if(icache_stall) begin
            if(exp_detect || mem_stall)
                en = 5'b00000;
            else if(ex_branch_taken || ex_stall)
                en = 5'b00001;
            else if(id_ex_alu_op == `MFC0_OP && ex_mem_cp0_wen)
                en = 5'b00001;
            else if(id_ex_mem_type ==2'b01 &&
                ((id_ex_mem_wb_reg_dest == id_rs) ||
                (id_ex_mem_wb_reg_dest == id_rt)))
                en = 5'b00001;
            else if(ex_mem_mem_type==2'b01&&((ex_mem_mem_wb_reg_dest==id_rs)||(ex_mem_mem_wb_reg_dest==id_rt)))
                en=5'b00001;

            else if( fifo_1_left && Branch_first)
                en = 5'b00001;
            else
                en = 5'b01111;
        end
        else if(mem_stall) begin
            if(ex_branch_taken)
                en = 5'b00000;
            else
                en = 5'b10000;//确定要取指？
        end
        else if(ex_stall)
            en = 5'b10001;
        else if(id_ex_alu_op == `MFC0_OP && ex_mem_cp0_wen)
            en = 5'b10011;
        else if(id_ex_mem_type ==2'b01 &&
                ((id_ex_mem_wb_reg_dest == id_rs) ||
                (id_ex_mem_wb_reg_dest == id_rt))) begin
            en = 5'b10011;
        end
        else if(ex_mem_mem_type==2'b01&&((ex_mem_mem_wb_reg_dest==id_rs)||(ex_mem_mem_wb_reg_dest==id_rt)))begin
             en=5'b10001;
        end
        else
            en = 5'b11111;
    end

  
    
endmodule
