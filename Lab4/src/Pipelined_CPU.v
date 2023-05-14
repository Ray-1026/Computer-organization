`timescale 1ns / 1ps
// 蔡師睿 110550093
module Pipelined_CPU(
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
wire [1:0] ALUop;
wire RegWrite, ALUSrc, RegDst, Branch, MemtoReg, MemRead, MemWrite;


/**** EX stage ****/
wire [146:0] ID_to_EX;
wire [31:0] shift, goto_addr;
wire [4:0] rd;
wire [3:0] ALU_ctrl;
wire [31:0] src_out, ALU_res;
wire zero;


/**** MEM stage ****/
wire [106:0] EX_to_MEM;
wire [31:0] mem_out;


/**** WB stage ****/
wire [70:0] MEM_to_WB;
wire [31:0] rd_data;



/*==================================================================*/
/*                              design                              */
/*==================================================================*/

//Instantiate the components in IF stage

MUX_2to1 #(.size(32)) Mux0( // Modify N, which is the total length of input/output
    .data0_i(next_addr),
    .data1_i(EX_to_MEM[101:70]),
    .select_i(EX_to_MEM[69]&EX_to_MEM[104]),
    .data_o(pc_in)
);

ProgramCounter PC(
    .clk_i(clk_i),
	.rst_i(rst_i),
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
	.MemWrite_o(MemWrite)
);

Sign_Extend SE(
    .data_i(IF_to_ID[15:0]),
    .data_o(se_out)
);

Pipe_Reg #(.size(9+32*4+5*2)) ID_EX( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({RegWrite, MemtoReg, Branch, MemRead, MemWrite, RegDst, ALUop, ALUSrc,
        IF_to_ID[63:32], rs, rt, se_out, IF_to_ID[20:16], IF_to_ID[15:11]}),
    .data_o(ID_to_EX)
);


//Instantiate the components in EX stage

Shift_Left_Two_32 Shifter(
    .data_i(ID_to_EX[41:10]),
    .data_o(shift)
);

ALU ALU(
    .src1_i(ID_to_EX[105:74]),
	.src2_i(src_out),
	.ctrl_i(ALU_ctrl),
	.result_o(ALU_res),
	.zero_o(zero)
);
		
ALU_Ctrl ALU_Control(
    .funct_i(ID_to_EX[15:10]),
    .ALUOp_i(ID_to_EX[140:139]), //ALUOp
    .ALUCtrl_o(ALU_ctrl)
);

MUX_2to1 #(.size(32)) Mux1( // Modify N, which is the total length of input/output
    .data0_i(ID_to_EX[73:42]),
    .data1_i(ID_to_EX[41:10]),
    .select_i(ID_to_EX[138]),    //ALUSrc
    .data_o(src_out)
);
		
MUX_2to1 #(.size(5)) Mux2( // Modify N, which is the total length of input/output
    .data0_i(ID_to_EX[9:5]),
    .data1_i(ID_to_EX[4:0]),
    .select_i(ID_to_EX[141]),    //RegDst
    .data_o(rd)
);

Adder Add_pc_branch(
    .src1_i(ID_to_EX[137:106]),
	.src2_i(shift),
	.sum_o(goto_addr)
);

Pipe_Reg #(.size(5+32*3+1+5)) EX_MEM( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({ID_to_EX[146:142], goto_addr, zero, ALU_res, ID_to_EX[73:42], rd}),
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

Pipe_Reg #(.size(2+32*2+5)) MEM_WB( // Modify N, which is the total length of input/output
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({EX_to_MEM[106:105], mem_out, EX_to_MEM[68:37], EX_to_MEM[4:0]}),
    .data_o(MEM_to_WB)
);


//Instantiate the components in WB stage

MUX_2to1 #(.size(32)) Mux3( // Modify N, which is the total length of input/output
    .data0_i(MEM_to_WB[68:37]),
    .data1_i(MEM_to_WB[36:5]),
    .select_i(MEM_to_WB[69]),    //MemtoReg
    .data_o(rd_data)
);


endmodule