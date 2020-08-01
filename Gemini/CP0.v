`include "define.v"
module CP0(
    input wire clk,
    input wire resetn,
    input wire [31:0] PC_first,
    input wire [5:0] int_,
    input wire has_exp,//from exception
    input exp_first,
    input exp_second,
    input wire [7:0] cp0_addr,
    input wire [7:0] cp0_write_addr,
    input wire write_cp0_enable,
    input wire [31:0] write_cp0_data,
    input wire exp_is_in_delayslot,
    input wire wen_badaddress,
    input wire [31:0] exp_badaddress,
    input wire [31:0] exp_epc,
    input wire [4:0] exp_cause_code,
    input wire exp_clean,
    output wire [31:0] epc_to_Exception,
    output reg [31:0] cp0_data,
    output wire is_in_exp
);

reg [31:0]Index;
reg [31:0]Random;
reg [31:0]EntryLo0;
reg [31:0]EntryLo1;
reg [31:0]Context;
//reg [31:0]PageMask;
reg [31:0]Cause;
reg [31:0]BadVaddr;
reg [32:0]Count;
reg [31:0]Status;
reg [31:0]EntryHi;
reg [31:0]Compare;
reg [31:0]Epc;
reg [31:0]Ebase;
//now stage is handling a previous exception
//if is_in_exp==1 and another exception is happenging,never write the epc,but cause and badvadder
assign is_in_exp=(Status[1]==1'b1);
assign epc_to_Exception=Epc;
always@(posedge clk)begin
    if(!resetn)begin
        Count<= 33'd0;
        Status<= 32'h1040_0004;
        Cause<= 32'd0;
        BadVaddr<=32'h0;
        EntryHi<= 32'd0;
        EntryLo0[31:30] <= 2'd0;
        EntryLo1[31:30] <= 2'd0;
        Ebase<= 32'h8000_0000;
        Index<= 32'd0;
        Context<= 32'd0;
        Compare<= 32'd0;
        Context<= 32'd0;
        Random<= 32'd0;
    end
    else begin
        //Write CP0
        Count <= Count + 33'd1;
        Cause[15:10]<=int_;//qfs
        if(write_cp0_enable)begin
            //$display(" wb stage is writing cp0,addr=%8b,Write_data is 0x%8h,Status is 0x%8h",cp0_write_addr,write_cp0_data,Status);
            case(cp0_write_addr)
            `Count_Addr:begin
                Count<={write_cp0_data, 1'b0};
            end
            `Cause_Addr:begin
                Cause[9:8]<= write_cp0_data[9:8];
                Cause[23]<= write_cp0_data[23];
            end
            `Status_Addr:begin
                Status[28]<= write_cp0_data[28];
                Status[22]<= write_cp0_data[22];
                Status[15:8]<= write_cp0_data[15:8];
                Status[4]<= write_cp0_data[4];
                Status[2:0]<= write_cp0_data[2:0];

            end
            `Epc_Addr:begin
                Epc<=write_cp0_data;
            end
            `Context_Addr:begin
                Context[31:13]<= write_cp0_data[31:13];
            end
            default:begin
              
            end
            endcase
        end
        //Exp Relative Write 
        if(has_exp&&exp_clean==1'b0) begin
            if(wen_badaddress==1'b1)begin
                BadVaddr<=exp_badaddress;
            end
            Epc<=exp_epc;
            Cause[6:2]<=exp_cause_code;
            Cause[31]<=exp_is_in_delayslot;
            Status[1]<=~exp_clean; 
        if(exp_clean==1'b1)begin
            Status[1]<=1'b0;
        end
        end
    end
end
always@(posedge clk)begin
    //$display("ex is reading cp0 addr=%7b,cp0_data=0x%8h",cp0_addr,cp0_data);
end
always@(*)begin
    case(cp0_addr)
        `Count_Addr:begin
            cp0_data=Count[32:1];
        end
        `Index_Addr:begin
            cp0_data=Index;
        end
        `BadVaddr_Addr:begin
            if(write_cp0_enable==1'b1&&cp0_write_addr==`BadVaddr_Addr)begin
                cp0_data=write_cp0_data;
            end
            else begin
                cp0_data=BadVaddr;
            end
        end
        `Cause_Addr:begin
           if(write_cp0_enable==1'b1&&cp0_write_addr==`Cause_Addr)begin
                cp0_data={Cause[31:24],write_cp0_data[23],Cause[22:10],write_cp0_data[9:8],Cause[7:0]};
            end
            else begin
                cp0_data=Cause;
            end 
        end
        `Epc_Addr:begin
            if(write_cp0_enable==1'b1&&cp0_write_addr==`Epc_Addr)begin
                cp0_data=write_cp0_data;
            end
            else begin
                cp0_data=Epc;
            end
        end
        `Status_Addr:begin
            if(write_cp0_enable==1'b1&&cp0_write_addr==`Status_Addr)begin
                cp0_data={Status[31:29],write_cp0_data[28],Status[27:23],write_cp0_data[22],Status[21:16],
                write_cp0_data[15:8],Status[7:5],write_cp0_data[4],Status[3],write_cp0_data[2:0]};
            end
            else begin
                cp0_data=Status;
            end 
        end
        default:begin
            cp0_data=32'h0;
        end
    endcase
end

endmodule


