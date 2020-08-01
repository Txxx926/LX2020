module Wb_Stage(
    input wire Write_Reg_Enable_First,
    input wire Write_Reg_Enable_Second,
    input wire [4:0] Wrtie_Reg_Address_First,
    input wire [4:0] Write_Reg_Address_Second,
    input wire [1:0] Write_HILO_Enable_First,
    input wire [63:0] Write_HILO_Data,
    input wire [31:0] Mem_Result_First,
    input wire [1:0] LS_First,
    input wire [31:0] Aluout_First,
    input wire [31:0] Aluout_Second,
    input wire [31:0] Cp0_write_data_First,
    input wire [7:0] Cp0_write_address_First,
    input wire Write_Cp0_Enable_First,
    output wire Write_Reg_Enable_First_o,//same
    output wire Write_Reg_Enable_Second_o,//same
    output wire [4:0] Write_Reg_Address_First_o,//same
    output wire [4:0] Write_Reg_Address_Second_o,//same
    output reg [31:0]Write_Reg_Data_First_o,
    output wire [31:0] Write_Reg_Data_Second_o,//same
    output wire Write_Cp0_Enable_First_o,//same
    output wire [7:0] Cp0_write_address_First_o,//same
    output wire [31:0] Cp0_write_data_o,//same
    output wire [1:0] Write_HILO_Enable_First_o,//same
    output wire [63:0] Write_HILO_Data_o//same

);
assign Write_Reg_Data_Second_o=Aluout_Second;
assign Write_Reg_Enable_First_o=Write_Reg_Enable_First;
assign Write_Reg_Enable_Second_o=Write_Reg_Enable_Second;
assign Write_Reg_Address_First_o=Wrtie_Reg_Address_First;
assign Write_Reg_Address_Second_o=Write_Reg_Address_Second;
assign Write_Cp0_Enable_First_o=Write_Cp0_Enable_First;
assign Cp0_write_address_First_o=Cp0_write_address_First;
assign Cp0_write_data_o=Cp0_write_data_First;
assign Write_HILO_Enable_First_o=Write_HILO_Enable_First;
assign Write_HILO_Data_o=Write_HILO_Data;
always@(*)begin
    if(LS_First==2'b01)begin
        Write_Reg_Data_First_o=Mem_Result_First;
    end
    else begin
        Write_Reg_Data_First_o=Aluout_First;
    end
end




endmodule