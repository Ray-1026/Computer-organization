// ??? 110550093
`timescale 1ns / 1ps
module Pipe_CPU_1(
    clk_i,
    rst_i
);
    
/*==================================================================*/
/*                          input & output                          */
/*==================================================================*/

input clk_i;
input rst_i;

/*==================================================================*/
/*                            reg & wire                            */
/*==================================================================*/

/**** IF stage ****/
wire [31:0] pc_in, pc_out;
wire [31:0] next_addr;
wire [31:0] instruction;

/**** ID stage ****/
wire [63:0] IF_to_ID;
wire [31:0] rs, rt;
wire [31:0] se_out;
wire [1:0] ALUop, BranchType;
wire RegWrite, ALUSrc, RegDst, Branch, MemtoReg, MemRead, MemWrite;
wire [10:0] ctrl;

/**** EX stage ****/
wire [153:0] ID_to_EX;
wire [1:0] wb;
wire [4:0] mem;
wire [4:0] rd;
wire [3:0] ALU_ctrl;
wire [31:0] shift, goto_addr;
wire [31:0] forwarded_rs, forwarded_rt;
wire [31:0] src_out, ALU_res;
wire zero;

/**** MEM stage ****/
wire [108:0] EX_to_MEM;
wire [31:0] mem_out;
wire branchtype_out;

/**** WB stage ****/
wire [70:0] MEM_to_WB;
wire [31:0] rd_data;

/**** Hazard Detection Unit ****/
wire PCWrite, IF_ID_Write;
wire IF_Flush, ID_Flush, EX_Flush;

/**** Forwarding Unit ****/
wire [1:0] ForwardA, ForwardB;


/*==================================================================*/
/*                              design                              */
/*==================================================================*/

//Instantiate the components in IF stage

MUX_2to1 #(.size(32)) Mux0( // Modify N, which is the total length of input/output
    .data0_i(next_addr),
    .data1_i(EX_to_MEM[101:70]),
    .select_i(branchtype_out&EX_to_MEM[106]),
    .data_o(pc_in)
);

ProgramCounter PC(
    .clk_i(clk_i),
	.rst_i(rst_i),
    .pc_write(PCWrite),
	.pc_in_i(pc_in),
	.pc_out_o(pc_out)
);

Instruction_Memory IM(
    .addr_i(pc_out),
    .instr_o(instruction)
);
			
Adder Add_pc(
    .src1_i(pc_out),
    .src2_i(32'd4),
    .sum_o(next_addr)
);
		
Pipe_Reg #(.size(64)) IF_ID( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(IF_Flush),
    .write(IF_ID_Write),
    .data_i({next_addr, instruction}),
    .data_o(IF_to_ID)
);


//Instantiate the components in ID stage

Reg_File RF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(IF_to_ID[25:21]),
    .RTaddr_i(IF_to_ID[20:16]),
    .RDaddr_i(MEM_to_WB[4:0]),
    .RDdata_i(rd_data),
    .RegWrite_i(MEM_to_WB[70]), //RegWrite
    .RSdata_o(rs),
    .RTdata_o(rt)
);

Decoder Control(
    .instr_op_i(IF_to_ID[31:26]),
    .RegWrite_o(RegWrite),
    .ALU_op_o(ALUop),
    .ALUSrc_o(ALUSrc),
    .RegDst_o(RegDst),
    .Branch_o(Branch),
    .MemtoReg_o(MemtoReg),
    .MemRead_o(MemRead),
    .MemWrite_o(MemWrite),
    .BranchType_o(BranchType)
);

MUX_2to1 #(.size(11)) Mux1( // Modify N, which is the total length of input/output
    .data0_i({RegWrite, MemtoReg, Branch, BranchType, MemRead, MemWrite, RegDst, ALUop, ALUSrc}),
    .data1_i(11'd0),
    .select_i(ID_Flush),
    .data_o(ctrl)
);

Sign_Extend SE(
    .data_i(IF_to_ID[15:0]),
    .data_o(se_out)
);

Pipe_Reg #(.size(11+32*4+15)) ID_EX( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(1'b0),
    .write(1'b1),
    .data_i({ctrl, IF_to_ID[63:32], rs, rt, se_out, IF_to_ID[25:11]}),
    .data_o(ID_to_EX)
);


//Instantiate the components in EX stage

MUX_2to1 #(.size(2)) Mux2( // Modify N, which is the total length of input/output
    .data0_i(ID_to_EX[153:152]),
    .data1_i(2'd0),
    .select_i(EX_Flush),
    .data_o(wb)
);

MUX_2to1 #(.size(5)) Mux3( // Modify N, which is the total length of input/output
    .data0_i(ID_to_EX[151:147]),
    .data1_i(5'd0),
    .select_i(EX_Flush),
    .data_o(mem)
);

Shift_Left_Two_32 Shifter(
    .data_i(ID_to_EX[46:15]),
    .data_o(shift)
);

Adder Add_pc_branch(
    .src1_i(ID_to_EX[142:111]),
	.src2_i(shift),
	.sum_o(goto_addr)
);

ALU_Ctrl ALU_Control(
    .funct_i(ID_to_EX[20:15]),
    .ALUOp_i(ID_to_EX[145:144]), //ALUOp
    .ALUCtrl_o(ALU_ctrl)
);

MUX_3to1 #(.size(32)) Mux4( // Modify N, which is the total length of input/output
    .data0_i(ID_to_EX[110:79]),
    .data1_i(EX_to_MEM[68:37]),
    .data2_i(rd_data),
    .select_i(ForwardA),
    .data_o(forwarded_rs)
);

MUX_3to1 #(.size(32)) Mux5( // Modify N, which is the total length of input/output
    .data0_i(ID_to_EX[78:47]),
    .data1_i(EX_to_MEM[68:37]),
    .data2_i(rd_data),
    .select_i(ForwardB),
    .data_o(forwarded_rt)
);

MUX_2to1 #(.size(32)) Mux6( // Modify N, which is the total length of input/output
    .data0_i(forwarded_rt),
    .data1_i(ID_to_EX[46:15]),
    .select_i(ID_to_EX[143]),    //ALUSrc
    .data_o(src_out)
);

ALU ALU(
    .src1_i(forwarded_rs),
    .src2_i(src_out),
    .ctrl_i(ALU_ctrl),
    .result_o(ALU_res),
    .zero_o(zero)
);
		
MUX_2to1 #(.size(5)) Mux7( // Modify N, which is the total length of input/output
    .data0_i(ID_to_EX[9:5]),
    .data1_i(ID_to_EX[4:0]),
    .select_i(ID_to_EX[146]),    //RegDst
    .data_o(rd)
);

Pipe_Reg #(.size(2+5+32*3+1+5)) EX_MEM( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(1'b0),
    .write(1'b1),
    .data_i({wb, mem, goto_addr, zero, ALU_res, forwarded_rt, rd}),
    .data_o(EX_to_MEM)
);


//Instantiate the components in MEM stage

Data_Memory DM(
    .clk_i(clk_i),
    .addr_i(EX_to_MEM[68:37]),
    .data_i(EX_to_MEM[36:5]),
    .MemRead_i(EX_to_MEM[103]),
    .MemWrite_i(EX_to_MEM[102]),
    .data_o(mem_out)
);

MUX_4to1 #(.size(1)) Mux8( // Modify N, which is the total length of input/output
    .data0_i(EX_to_MEM[69]),
    .data1_i(~(EX_to_MEM[69]|EX_to_MEM[68])),
    .data2_i(~EX_to_MEM[68]),
    .data3_i(~EX_to_MEM[69]),
    .select_i(EX_to_MEM[105:104]),
    .data_o(branchtype_out)
);

Pipe_Reg #(.size(2+32*2+5)) MEM_WB( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .flush(1'b0),
    .write(1'b1),
    .data_i({EX_to_MEM[108:107], mem_out, EX_to_MEM[68:37], EX_to_MEM[4:0]}),
    .data_o(MEM_to_WB)
);


//Instantiate the components in WB stage

MUX_2to1 #(.size(32)) Mux9( // Modify N, which is the total length of input/output
    .data0_i(MEM_to_WB[68:37]),
    .data1_i(MEM_to_WB[36:5]),
    .select_i(MEM_to_WB[69]),    //MemtoReg
    .data_o(rd_data)
);


//Instantiate the unit

Hazard_Detection Hazard(
    .PCSrc_i(branchtype_out&EX_to_MEM[106]),
    .MemRead_IdEx_i(ID_to_EX[148]),
    .Rs_IfId_i(IF_to_ID[25:21]),
    .Rt_IfId_i(IF_to_ID[20:16]),
    .Rt_IdEx_i(ID_to_EX[9:5]),
    .PCWrite_o(PCWrite),
    .IF_ID_Write_o(IF_ID_Write),
    .IF_Flush_o(IF_Flush),
    .ID_Flush_o(ID_Flush),
    .EX_Flush_o(EX_Flush)
);

Forwarding Forward(
    .Rs_IdEx_i(ID_to_EX[14:10]),
    .Rt_IdEx_i(ID_to_EX[9:5]),
    .Rd_ExMem_i(EX_to_MEM[4:0]),
    .RegWrite_ExMem_i(EX_to_MEM[108]),
    .Rd_MemWb_i(MEM_to_WB[4:0]),
    .RegWrite_MemWb_i(MEM_to_WB[70]),
    .ForwardA_o(ForwardA),
    .ForwardB_o(ForwardB)
);

endmodule