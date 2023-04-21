//Subject:     CO project 2 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      蔡師睿
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
`timescale 1ns/1ps
module Simple_Single_CPU(
        clk_i,
	rst_i
);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire [31:0] pc_in, pc_out;
wire [31:0] next_add;
wire [31:0] instruction;

wire RegDst, RegWrite, ALUSrc, branch;
wire [2:0] ALUOp;

wire [4:0] write_reg;
wire [31:0] rs, rt;

wire [31:0] const, shift;
wire [31:0] target;

wire [3:0] ALU_ctrl;
wire [31:0] src2;
wire [31:0] ALU_res;
wire zero;

//Greate componentes
ProgramCounter PC(
        .clk_i(clk_i),      
	.rst_i (rst_i),     
        .pc_in_i(pc_in),   
	.pc_out_o(pc_out) 
);
	
Adder Adder1(
        .src1_i(32'd4),     
	.src2_i(pc_out),     
	.sum_o(next_add)    
);
	
Instr_Memory IM(
        .pc_addr_i(pc_out),  
	.instr_o(instruction)    
);

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instruction[20:16]),
        .data1_i(instruction[15:11]),
        .select_i(RegDst),
        .data_o(write_reg)
);	
		
Reg_File RF(
        .clk_i(clk_i),      
	.rst_i(rst_i),     
        .RSaddr_i(instruction[25:21]),  
        .RTaddr_i(instruction[20:16]),  
        .RDaddr_i(write_reg),  
        .RDdata_i(ALU_res), 
        .RegWrite_i(RegWrite),
        .RSdata_o(rs),  
        .RTdata_o(rt)   
);
	
Decoder Decoder(
        .instr_op_i(instruction[31:26]), 
	.RegWrite_o(RegWrite), 
        .ALU_op_o(ALUOp),   
	.ALUSrc_o(ALUSrc),   
	.RegDst_o(RegDst),   
	.Branch_o(branch)   
);

ALU_Ctrl AC(
        .funct_i(instruction[5:0]),   
        .ALUOp_i(ALUOp),   
        .ALUCtrl_o(ALU_ctrl) 
);
	
Sign_Extend SE(
        .data_i(instruction[15:0]),
        .data_o(const)
);

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(rt),
        .data1_i(const),
        .select_i(ALUSrc),
        .data_o(src2)
);	
		
ALU ALU(
        .src1_i(rs),
	.src2_i(src2),
	.ctrl_i(ALU_ctrl),
	.result_o(ALU_res),
	.zero_o(zero)
);
		
Adder Adder2(
        .src1_i(next_add),     
	.src2_i(shift),     
	.sum_o(target)      
);
		
Shift_Left_Two_32 Shifter(
        .data_i(const),
        .data_o(shift)
); 		
		
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(next_add),
        .data1_i(target),
        .select_i(zero&branch),
        .data_o(pc_in)
);	

endmodule