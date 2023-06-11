//Subject:     CO project 5 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      蔡師睿 110550093
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
`timescale 1ns/1ps
module Decoder(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o,
	MemtoReg_o,
	MemRead_o,
	MemWrite_o,
	BranchType_o
);
     
//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [2-1:0] ALU_op_o;
output         ALUSrc_o;
output         RegDst_o;
output         Branch_o;
output         MemtoReg_o;
output         MemRead_o;
output         MemWrite_o;
output [2-1:0] BranchType_o;
 
//Internal Signals
reg            RegWrite_o;
reg    [2-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegDst_o;
reg            Branch_o;
reg            MemtoReg_o;
reg            MemRead_o;
reg            MemWrite_o;
reg    [2-1:0] BranchType_o;

//Parameter

//Main function
always @(instr_op_i) begin
	case(instr_op_i)
		//R-format : add, sub, and, or, slt, mult
		6'b000000: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o, BranchType_o} <= 11'b11001010000;
		//bge
		6'b000001: {RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o, MemRead_o, MemWrite_o, BranchType_o} <= 9'b001010010;	//RegDst, MemtoReg => x
		//beq
		6'b000100: {RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o, MemRead_o, MemWrite_o, BranchType_o} <= 9'b001010000;	//RegDst, MemtoReg => x
		//bne
		6'b000101: {RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o, MemRead_o, MemWrite_o, BranchType_o} <= 9'b001010011;	//RegDst, MemtoReg => x
		//bgt
		6'b000111: {RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o, MemRead_o, MemWrite_o, BranchType_o} <= 9'b001010001;	//RegDst, MemtoReg => x
		//addi
		6'b001000: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o} <= 9'b100100100;	//BranchType => xx
		//slti
		6'b001010: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o} <= 9'b111100100;	//BranchType => xx
		//lw
		6'b100011: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o} <= 9'b100100010;	//BranchType => xx
		//sw
		6'b101011: {RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o, MemRead_o, MemWrite_o} <= 7'b0001001;	//RegDst, MemtoReg => x ; BranchType => xx
		//others
		default: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o, BranchType_o} <= 11'b00000000000;
	endcase
end

endmodule