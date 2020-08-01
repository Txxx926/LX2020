module Regfile(
    input wire clk,
    input wire resetn,
    input wire [31:0]count,
    input wire Wen_First,
    input wire Wen_Second,
    input wire [31:0] WData_First,
    input wire [31:0] WData_Second,
    input wire [4:0] WAddr_First,
    input wire [4:0] WAddr_Second,
    input wire [4:0] Read_Addr_First_Rs,
    input wire [4:0] Read_Addr_First_Rt,
    input wire [4:0] Read_Addr_Second_Rs,
    input wire [4:0] Read_Addr_Second_Rt,
    output reg [31:0] RData_First_Rs,
    output reg [31:0] RData_First_Rt,
    output reg [31:0] RData_Second_Rs,
    output reg [31:0] RData_Second_Rt
);

reg [31:0] REG[31:0];
always@(posedge clk)begin
    if(resetn)begin
        //$display("Wen_first=%1b,Wdata_first=0x%8h,Waddr_first=%5b,count=0x%8h",Wen_First,WData_First,WAddr_First,count);
    end
end
always@(posedge clk)begin
    if(resetn==1'b0)begin
       REG[0]<=32'h0; REG[1]<=32'h0; REG[2]<=32'h0; REG[3]<=32'h0; REG[4]<=32'h0; REG[5]<=32'h0;
       REG[6]<=32'h0; REG[7]<=32'h0; REG[8]<=32'h0; REG[9]<=32'h0; REG[10]<=32'h0;REG[11]<=32'h0;
       REG[12]<=32'h0;REG[13]<=32'h0;REG[14]<=32'h0;REG[15]<=32'h0;REG[16]<=32'h0;REG[17]<=32'h0;
       REG[18]<=32'h0;REG[19]<=32'h0;REG[20]<=32'h0;REG[21]<=32'h0;REG[22]<=32'h0;REG[23]<=32'h0;
       REG[24]<=32'h0;REG[25]<=32'h0;REG[26]<=32'h0;REG[27]<=32'h0;REG[28]<=32'h0;REG[29]<=32'h0;
       REG[30]<=32'h0;REG[31]<=32'h0;
    end
    else begin
        if(Wen_First==1'b1&&Wen_Second==1'b1&&WAddr_First==WAddr_Second&&WAddr_First!=5'h0)begin
            REG[WAddr_First]<=WData_First;
        end
        else begin
            if(Wen_Second==1'b1&&WAddr_Second!=5'h0)begin
                REG[WAddr_Second]<=WData_Second;
            end
            if(Wen_First==1'b1&&WAddr_First!=5'h0)begin
                REG[WAddr_First]<=WData_First;
            end
        end
    end
end
always@(*)begin
    //First_RS
    if(Read_Addr_First_Rs==5'h0)begin
        RData_First_Rs=32'h0;
    end
    else if(Read_Addr_First_Rs==WAddr_Second&&Wen_Second==1'b1) begin
        RData_First_Rs=WData_Second;
    end
    else if(Read_Addr_First_Rs==WAddr_First&&Wen_First==1'b1)begin
        RData_First_Rs=WData_First;
    end
    else begin
        RData_First_Rs=REG[Read_Addr_First_Rs];
    end
    //First_RT
    if(Read_Addr_First_Rt==5'h0)begin
        RData_First_Rt=32'h0;
    end
    else if(Read_Addr_First_Rt==WAddr_Second&&Wen_Second==1'b1) begin
        RData_First_Rt=WData_Second;
    end
    else if(Read_Addr_First_Rt==WAddr_First&&Wen_First==1'b1)begin
        RData_First_Rt=WData_First;
    end
    else begin
        RData_First_Rt=REG[Read_Addr_First_Rt];
    end 
    //Second_RS
    if(Read_Addr_Second_Rs==5'h0)begin
        RData_Second_Rs=32'h0;
    end
    else if(Read_Addr_Second_Rs==WAddr_Second&&Wen_Second==1'b1) begin
        RData_Second_Rs=WData_Second;
    end
    else if(Read_Addr_Second_Rs==WAddr_First&&Wen_First==1'b1)begin
        RData_Second_Rs=WData_First;
    end
    else begin
        RData_Second_Rs=REG[Read_Addr_Second_Rs];
    end
    //Second_RT
    if(Read_Addr_Second_Rt==5'h0)begin
        RData_Second_Rt=32'h0;
    end
    else if(Read_Addr_Second_Rt==WAddr_Second&&Wen_Second==1'b1) begin
        RData_Second_Rt=WData_Second;
    end
    else if(Read_Addr_Second_Rt==WAddr_First&&Wen_First==1'b1)begin
        RData_Second_Rt=WData_First;
    end
    else begin
        RData_Second_Rt=REG[Read_Addr_Second_Rt];
    end
end
endmodule