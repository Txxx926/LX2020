module mem_wb(
    input wire clk,
    input wire resetn,
    input wire has_exp,
    input wire is_exp_first,
    input wire is_exp_second,
    input wire en_mem_wb,
    input wire write_reg_enable_first_mem,
    input wire write_reg_enable_second_mem,
    input wire [1:0] write_hilo_enable_first_mem,
    input wire [4:0] write_reg_addr_first_mem,
    input wire [4:0] write_reg_addr_second_mem,
    input wire [31:0] memout_first_mem,
    input wire [31:0] aluout_first_mem,
    input wire [31:0] aluout_second_mem,
    input wire [7:0] cp0_write_addr_first_mem,
    input wire write_cp0_enable_first_mem,
    input wire [63:0] write_hilo_data_first_mem,
    input wire [1:0] ls_first_mem,
    input wire [31:0] pc_first_mem_i,
    output reg [31:0] pc_first_wb,
    output reg [1:0] ls_first_wb,
    output reg write_reg_enable_first_wb,
    output reg write_reg_enable_second_wb,
    output reg [1:0] write_hilo_enable_first_wb,
    output reg [4:0] write_reg_addr_first_wb,
    output reg [4:0] write_reg_addr_second_wb,
    output reg [31:0] memout_first_wb,
    output reg [31:0] aluout_first_wb,
    output reg [31:0] aluout_second_wb,
    output reg [7:0] cp0_write_addr_first_wb,
    output reg write_cp0_enable_first_wb,
    output reg [63:0] write_hilo_data_first_wb
);

always@(posedge clk)begin
    if(!resetn || !en_mem_wb || (has_exp && ~is_exp_second)) begin
        write_reg_enable_first_wb               <=                   0;
        write_hilo_enable_first_wb              <=                   0;    
        write_reg_addr_first_wb                 <=                   0;      
        memout_first_wb                         <=                   0;                    
        aluout_first_wb                         <=                   0;                    
        cp0_write_addr_first_wb                 <=                   0;                 
        write_cp0_enable_first_wb               <=                   0;               
        write_hilo_data_first_wb                <=                   64'd0;  
        ls_first_wb                             <=                   0;
        pc_first_wb                             <=                   0;             
    end
    else begin
        write_reg_enable_first_wb               <=                   write_reg_enable_first_mem ;
        write_hilo_enable_first_wb              <=                   write_hilo_enable_first_mem;        
        write_reg_addr_first_wb                 <=                   write_reg_addr_first_mem   ;            
        memout_first_wb                         <=                   memout_first_mem           ;                                        
        aluout_first_wb                         <=                   aluout_first_mem           ;                                        
        cp0_write_addr_first_wb                 <=                   cp0_write_addr_first_mem   ;                                  
        write_cp0_enable_first_wb               <=                   write_cp0_enable_first_mem ;                              
        write_hilo_data_first_wb                <=                   write_hilo_data_first_mem  ;
        ls_first_wb                             <=                  ls_first_mem;     
        pc_first_wb                             <=                  pc_first_mem_i;      
       // $display("mem_wb first pipeline is working!");
    end
end

always@(posedge clk)begin
    if(!resetn || !en_mem_wb|| has_exp) begin
        write_reg_enable_second_wb              <=                    0;      
        write_reg_addr_second_wb                <=                    0;        
        aluout_second_wb                        <=                    0;       
    end
    else begin
        write_reg_enable_second_wb              <=                    write_reg_enable_second_mem ;      
        write_reg_addr_second_wb                <=                    write_reg_addr_second_mem   ;        
        aluout_second_wb                        <=                    aluout_second_mem           ;
    end
end
endmodule
