module ex_mem(
    input wire clk,
    input wire resetn,
    input wire en_ex_mem,
    input wire en_mem_wb,
    input wire flush,
    input wire [31:0] reg_rt_first_ex,
    input wire [1:0]write_hilo_first_ex,
    input wire write_reg_enable_first_ex,
    input wire write_reg_enable_second_ex,
    input wire [4:0] write_reg_addr_first_ex,
    input wire [4:0] write_reg_addr_second_ex,
    input wire [63:0] WHILO_Data_ex,
    input wire [31:0] aluout_first_ex,
    input wire [31:0] aluout_second_ex,
    input wire [13:0] exp_first_ex,
    input wire [13:0] exp_second_ex,
    input wire [1:0] ls_first_ex,
    input wire [3:0] ls_size_first_ex,
    input wire ls_signed_first_ex,
    input wire [31:0] pc_first_ex,
    input wire Write_CP0_Enable_first_ex,
    input wire [7:0] Write_CP0_addr_first_ex,
    input wire [3:0] Branch_type_first_ex,
    input wire first_is_in_delayslot_ex,
    input wire en_second_ex,
    input wire [31:0] pc_second_ex,
    output reg [31:0] pc_second_mem_i,
    output reg en_second_mem_i,
    output reg first_is_in_delayslot_mem_i,
    output reg [3:0] Branch_type_first_mem_i,
    output reg [7:0] Write_CP0_addr_first_mem_i,
    output reg Write_CP0_Enable_first_mem_i,
    output reg [31:0] reg_rt_first_mem_i,
    output reg [31:0] pc_first_mem_i,
    output reg [1:0] ls_first_mem_i,
    output reg [3:0] ls_size_first_mem_i,
    output reg ls_signed_first_mem_i,
    output reg [13:0] exp_first_mem_i,
    output reg [13:0] exp_second_mem_i,
    output reg [31:0] aluout_first_mem_i,
    output reg [31:0] aluout_second_mem_i,
    output reg [63:0] WHILO_Data_mem_i,
    output reg [4:0] write_reg_addr_first_mem_i,
    output reg [4:0] write_reg_addr_second_mem_i,
    output reg  write_reg_enable_first_mem_i,
    output reg write_reg_enable_second_mem_i,
    output reg [1:0]write_hilo_first_mem_i

);
//first
always@(posedge clk)begin
     if(!resetn || (!en_ex_mem && en_mem_wb) || flush) begin
        pc_first_mem_i                 <=                    0;  
        ls_first_mem_i                 <=                    0;                
        ls_size_first_mem_i            <=                    0;                  
        ls_signed_first_mem_i          <=                    0;                    
        exp_first_mem_i                <=                    0;                                
        aluout_first_mem_i             <=                    0;                              
        WHILO_Data_mem_i               <=                    64'd0;                                  
        write_reg_addr_first_mem_i     <=                    0;                                          
        write_reg_enable_first_mem_i   <=                    0;                
        write_hilo_first_mem_i         <=                    0;
        reg_rt_first_mem_i             <=                    0;
        Write_CP0_Enable_first_mem_i   <=                   0;
        Write_CP0_addr_first_mem_i     <=                   0;
        Branch_type_first_mem_i        <=                   0;
        first_is_in_delayslot_mem_i     <=                  0;
     end
     else if (en_ex_mem)begin
        pc_first_mem_i                 <=                    pc_first_ex                ;  
        ls_first_mem_i                 <=                    ls_first_ex                ;                
        ls_size_first_mem_i            <=                    ls_size_first_ex           ;                  
        ls_signed_first_mem_i          <=                    ls_signed_first_ex         ;                    
        exp_first_mem_i                <=                    exp_first_ex               ;                                
        aluout_first_mem_i             <=                    aluout_first_ex            ;                              
        WHILO_Data_mem_i               <=                    WHILO_Data_ex              ;                                  
        write_reg_addr_first_mem_i     <=                    write_reg_addr_first_ex    ;                                          
        write_reg_enable_first_mem_i   <=                    write_reg_enable_first_ex  ;   
        write_hilo_first_mem_i         <=                     write_hilo_first_ex;  
        reg_rt_first_mem_i             <=                     reg_rt_first_ex;
        Write_CP0_Enable_first_mem_i   <=                   Write_CP0_Enable_first_ex;
        Write_CP0_addr_first_mem_i     <=                   Write_CP0_addr_first_ex;
        Branch_type_first_mem_i        <=                   Branch_type_first_ex;
        first_is_in_delayslot_mem_i     <=                  first_is_in_delayslot_ex;
        //$display("ex_mem first pipeline is working!");
     end
end

//second
always@(posedge clk)begin
    if(!resetn || (!en_ex_mem && en_mem_wb) || flush)begin
        exp_second_mem_i                <=                   0; 
        aluout_second_mem_i             <=                   0;     
        write_reg_addr_second_mem_i     <=                   0;    
        write_reg_enable_second_mem_i   <=                   0; 
        pc_second_mem_i                 <=                  0;
        en_second_mem_i                  <=          0;
    end
    else if (en_ex_mem)begin
        exp_second_mem_i                <=                   exp_second_ex               ; 
        aluout_second_mem_i             <=                   aluout_second_ex            ;  
        write_reg_addr_second_mem_i     <=                   write_reg_addr_second_ex    ;    
        write_reg_enable_second_mem_i   <=                   write_reg_enable_second_ex  ;     
        pc_second_mem_i                 <=                  pc_second_ex;  
        en_second_mem_i                 <=                     en_second_ex             ;      
    end
end
endmodule
