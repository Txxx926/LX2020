module HILO_Reg(
    input wire clk,
    input wire resetn,
    input wire [1:0] Wb_HILO,
    input wire [63:0] Wb_HILO_Data,
    input wire [1:0] Mem_HILO,
    input wire [63:0] Mem_HILO_Data,
    output reg [63:0] HILO_Data_To_Ex
);
reg [63:0] HILO;
always@(posedge clk)begin
    if(!resetn)begin
        HILO<=64'h0;
    end
    else begin
        if(Wb_HILO!=2'b00) begin
            HILO<=Wb_HILO_Data;
        end
        else begin
            HILO<=HILO;
        end
    end
end
always@(*)begin
    if(Mem_HILO!=2'b00)begin
        HILO_Data_To_Ex=Mem_HILO_Data;
    end
    else if(Wb_HILO!=2'b00)begin
        HILO_Data_To_Ex=Wb_HILO_Data;
    end
    else begin
        HILO_Data_To_Ex=HILO;
    end
end
endmodule