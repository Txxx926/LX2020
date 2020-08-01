module id_ex(
    input wire clk,
    input wire resetn,
    input wire flush,
    input wire en_id_ex,
    input wire en_ex_mem,
    input wire ex_branch_taken,
    input wire id_second_en,
    input wire ex_second_en_i,
    input wire [4:0] rs_first_id,
    input wire [4:0] rt_first_id,
    input wire [4:0] rs_second_id,
    input wire [4:0] rt_second_id,
    input wire [15:0] imm_first_id,
    input wire [15:0] imm_second_id,
    input wire imm_extend_signed_first_id,
    input wire imm_extend_signed_second_id,
    input wire [6:0] aluop_first_id,
    input wire [6:0] aluop_second_id,
    input wire [1:0] alu_src_first_id,
    input wire [1:0] alu_src_second_id,
    input wire [13:0] exp_first_id,
    input wire [13:0] exp_second_id,
    input wire [31:0] pc_first_id,
    input wire [31:0] instr_first_id,
    input wire [3:0] branch_type_first_id,
    input wire [1:0] ls_first_id,
    input wire [3:0] ls_size_first_id,
    input wire ls_signed_first_id,
    input wire [1:0] write_hilo_first_id,
    input wire [4:0] write_reg_addr_first_id,
    input wire write_reg_enable_first_id,
    input wire [4:0] write_reg_addr_second_id,
    input wire write_reg_enable_second_id,
    input wire [7:0] CP0_addr_first_id,
    input wire Write_CP0_Enable_first_id,
    input wire first_is_in_delayslot_id,
    input wire [31:0] pc_second_id,
    output reg [31:0] pc_second_ex,
    output reg first_is_in_delayslot_ex,
    output reg Write_CP0_Enable_first_ex,
    output reg [7:0] CP0_addr_first_ex,
    output reg ex_second_en,
    output reg [6:0] aluop_first_ex,
    output reg [6:0] aluop_second_ex,
    output reg [4:0]              rs_first_ex,
    output reg [4:0]              rt_first_ex,
    output reg [4:0]             rs_second_ex,
    output reg [4:0]             rt_second_ex,
    output reg [15:0]            imm_first_ex,
    output reg [15:0]           imm_second_ex,
    output reg     imm_extend_signed_first_ex,
    output reg    imm_extend_signed_second_ex,
    output reg [1:0]         alu_src_first_ex,
    output reg [1:0]        alu_src_second_ex,
    output reg [13:0]            exp_first_ex,
    output reg [13:0]           exp_second_ex,
    output reg [31:0]             pc_first_ex,
    output reg [31:0]          instr_first_ex,
    output reg [3:0]     branch_type_first_ex,
    output reg [1:0]              ls_first_ex,
    output reg [3:0]         ls_size_first_ex,
    output reg             ls_signed_first_ex,
    output reg [1:0]      write_hilo_first_ex,
    output reg [4:0]  write_reg_addr_first_ex,
    output reg      write_reg_enable_first_ex,
    output reg [4:0] write_reg_addr_second_ex,
    output reg     write_reg_enable_second_ex
); 
//first
    always@(posedge clk) begin
        if(!resetn || (!en_id_ex && en_ex_mem) || flush || (en_id_ex && ex_branch_taken && ex_second_en_i)) begin
            rs_first_ex                 <=             0;        
            rt_first_ex                 <=             0;        
            imm_first_ex                <=             0;    
            imm_extend_signed_first_ex  <=             0;
            alu_src_first_ex            <=             0;  
            exp_first_ex                <=             0;  
            pc_first_ex                 <=             0;      
            instr_first_ex              <=             0;          
            branch_type_first_ex        <=             0;          
            ls_first_ex                 <=             0;                    
            ls_size_first_ex            <=             0;   
            CP0_addr_first_ex           <=             0;                 
            ls_signed_first_ex          <=             0;                  
            write_hilo_first_ex         <=             0;          
            aluop_first_ex              <=             0;
            write_reg_addr_first_ex     <=             0;        
            write_reg_enable_first_ex   <=             0;
            Write_CP0_Enable_first_ex  <=              0;
            first_is_in_delayslot_ex    <=             0;
        end
        else if (en_id_ex)begin
            rs_first_ex                 <=             rs_first_id                 ;        
            rt_first_ex                 <=             rt_first_id                 ;        
            imm_first_ex                <=             imm_first_id                ;    
            imm_extend_signed_first_ex  <=             imm_extend_signed_first_id  ;
            alu_src_first_ex            <=             alu_src_first_id            ;  
            exp_first_ex                <=             exp_first_id                ;  
            pc_first_ex                 <=             pc_first_id                 ;      
            instr_first_ex              <=             instr_first_id              ;    
            CP0_addr_first_ex           <=              CP0_addr_first_id           ;      
            branch_type_first_ex        <=             branch_type_first_id        ;         
            aluop_first_ex              <=              aluop_first_id; 
            ls_first_ex                 <=             ls_first_id                 ;                    
            ls_size_first_ex            <=             ls_size_first_id            ;                    
            ls_signed_first_ex          <=             ls_signed_first_id          ;                  
            write_hilo_first_ex         <=             write_hilo_first_id         ;          
            write_reg_addr_first_ex     <=             write_reg_addr_first_id     ;        
            write_reg_enable_first_ex   <=             write_reg_enable_first_id   ; 
            Write_CP0_Enable_first_ex   <=             Write_CP0_Enable_first_id   ;
            first_is_in_delayslot_ex    <=             first_is_in_delayslot_id ;
           // $display("id_ex first pipeline is working!");
        end
    end
//second
    always@(posedge clk)begin
        if(!resetn|| (!en_id_ex && en_ex_mem) || flush || (en_id_ex && !id_second_en) || (en_id_ex && ex_branch_taken))begin
                ex_second_en                <=             1'b0;
                rs_second_ex                <=             0;
                rt_second_ex                <=             0;
                imm_second_ex               <=             0;
                imm_extend_signed_second_ex <=             0;
                alu_src_second_ex           <=             0;
                aluop_second_ex             <=             0;
                exp_second_ex               <=             0;
                write_reg_addr_second_ex    <=             0;   
                write_reg_enable_second_ex  <=             0;
                pc_second_ex                <=              0;
        end
        else if (en_id_ex)begin
                ex_second_en                <=             id_second_en                ;
                rs_second_ex                <=             rs_second_id                ;
                rt_second_ex                <=             rt_second_id                ;
                imm_second_ex               <=             imm_second_id               ;
                imm_extend_signed_second_ex <=             imm_extend_signed_second_id ;
                alu_src_second_ex           <=             alu_src_second_id           ;
                aluop_second_ex             <=              aluop_second_id             ;
                exp_second_ex               <=             exp_second_id               ;
                write_reg_addr_second_ex    <=             write_reg_addr_second_id    ;      
                write_reg_enable_second_ex  <=             write_reg_enable_second_id  ;
                pc_second_ex                <=              pc_second_id;
        end
    end
endmodule
