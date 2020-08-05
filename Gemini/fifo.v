module instruction_fifo(
        input                       clk,
        input                       debug_rst,
        input                       resetn,
        input                       master_is_branch,
        input                       en_id_ex,
        input                       read_en1,
        input                       read_en2,
        input                       write_en_1,
        input                       write_en_2,
        input [31:0]                write_inst1,
        input [13:0]                write_inst_exp1,
        input [31:0]                write_pc1,
        input [31:0]                write_inst2,
        input [31:0]                write_pc2,

        output reg [31:0]         output_inst1,
        output reg [31:0]         output_inst2,
        output reg [31:0]         output_pc1,
        output reg [31:0]         output_pc2,
        output reg [13:0]         inst_exp1,
        output reg [13:0]         inst_exp2,
        output reg                delay_slot_out1,
        output                 fifo_empty,
        output                 fifo_1_left,
        output                 fifo_2_left,
        output                 fifo_full
        //output                 fifo_almost_full,
);

    //qfs
    wire write_en1 = write_en_1 && !fifo_full;
    wire write_en2 = write_en_2 && !fifo_full;
    //qfs
    reg    is_in_delayslot;
    reg [31:0]  inst[0:31];
    reg [31:0]  pc_value[0:31];
    reg [13:0]  inst_exp[0:31];


    reg [4:0] ptr_wr;
    reg [4:0] ptr_rd;
    reg [4:0] sum_inst;


    assign fifo_full     = (sum_inst == 5'd28 || sum_inst == 5'd29|| sum_inst == 5'd30 || sum_inst == 5'd31);
    assign fifo_empty    = (sum_inst == 5'd0);
    assign fifo_1_left = (sum_inst == 5'd1);
    assign fifo_2_left = (sum_inst == 5'd2);

    wire [31:0] now_output_inst1 = inst[ptr_rd];
    wire [31:0] now_output_inst2 = inst[ptr_rd + 5'd1];
    wire [31:0] now_output_pc1 = pc_value[ptr_rd];
    wire [31:0] now_output_pc2 = pc_value[ptr_rd + 5'd1];
    wire [13:0] now_inst_exp1 = inst_exp[ptr_rd];
    wire [13:0] now_inst_exp2 = inst_exp[ptr_rd + 5'd1];

    


//issue
    always@(*) begin : select_output
        if(fifo_empty) begin
            output_inst1       = 32'd0;
            output_inst2       = 32'd0;
            output_pc1    = 32'd0;
            output_pc2    = 32'd0;
            inst_exp1       = 14'd0;
            inst_exp2       = 14'd0;
            delay_slot_out1 = 1'd0;
        end
        else if(fifo_1_left) begin
            output_inst1       = now_output_inst1;
            output_inst2       = 32'd0;
            output_pc1    = now_output_pc1;
            output_pc2    = 32'd0;
            inst_exp1       = now_inst_exp1;
            inst_exp2       = 14'd0;
            delay_slot_out1 = is_in_delayslot;
        end 
        else begin
            output_inst1       = now_output_inst1;
            output_inst2       = now_output_inst2;
            output_pc1    = now_output_pc1;
            output_pc2    = now_output_pc2;
            inst_exp1       = now_inst_exp1;
            inst_exp2       = now_inst_exp2;
            delay_slot_out1 = is_in_delayslot;
        end
    end

    always @(posedge clk) begin 
        if(!resetn)
            is_in_delayslot <= 1'd0;
        else if(master_is_branch && read_en1&& !read_en2) begin
            is_in_delayslot <= 1'd1;
        end
        else if(read_en1)
            is_in_delayslot <= 1'd0;
    end



//update ptr
    always @(posedge clk) begin 
        if(!resetn)
            ptr_wr <= 5'd0;
        else if(write_en1 && write_en2)
            ptr_wr <= ptr_wr + 5'd2;
        else if(write_en1)
            ptr_wr <= ptr_wr + 5'd1;
    end

    always @(posedge clk) begin 
        if(!resetn)
            ptr_rd <= 5'd0;
        else if(fifo_empty)
            ptr_rd <= ptr_rd;
        else if(read_en1 && read_en2)begin
            ptr_rd <= ptr_rd + 5'd2;
            //$display("fifo isssu two! pc1=%8h,pc2=%8h",now_output_pc1,now_output_pc2);
        end
        else if(read_en1)begin
            ptr_rd <= ptr_rd + 5'd1;
            //$display("fifo isssu one ! pc1=%8h",now_output_pc1);
        end
    end

//update counter
    always @(posedge clk) begin
        if(!resetn)
            sum_inst <= 5'd0;
        else if(fifo_empty) begin
            case({write_en1, write_en2})
            2'b10: begin
                sum_inst  <= sum_inst + 5'd1;
            end
            2'b11: begin
                sum_inst  <= sum_inst + 5'd2;
            end
            default:
                sum_inst  <= sum_inst;
            endcase
        end
        else begin
            case({write_en1, write_en2, read_en1, read_en2})
            4'b1100: begin
                sum_inst  <= sum_inst + 5'd2;
            //$display("Fifo's left instrion is 0x%5b and add 2",sum_inst);
            end
            4'b1110, 4'b1000: begin
                sum_inst  <= sum_inst + 5'd1;
            //$display("Fifo's left instrion is 0x%5b and add 1",sum_inst);
            end
            4'b1011, 4'b0010: begin
                sum_inst  <= sum_inst - 5'd1;
            end
            4'b0011: begin
                sum_inst  <= sum_inst == 5'd1 ? 5'd0 : sum_inst - 5'd2;
            end
            default:
                sum_inst  <= sum_inst;
            endcase
        end
    end

//write in new
    always @(posedge clk) begin
        if(write_en1 ) begin
            inst[ptr_wr] <= write_inst1;
            pc_value[ptr_wr] <= write_pc1;
            inst_exp[ptr_wr] <= write_inst_exp1;
        end
        if(write_en2 ) begin
            inst[ptr_wr + 5'd1] <= write_inst2;
            pc_value[ptr_wr + 5'd1] <= write_pc2;
            inst_exp[ptr_wr + 5'd1] <= write_inst_exp1; 
        end
    end


endmodule