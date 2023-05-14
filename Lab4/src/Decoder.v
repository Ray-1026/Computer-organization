//Subject:     CO project 4 - Decoder
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
	MemWrite_o
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
 
//Internal Signals
reg            RegWrite_o;
reg    [2-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegDst_o;
reg            Branch_o;
reg            MemtoReg_o;
reg            MemRead_o;
reg            MemWrite_o;

//Parameter

//Main function
always @(instr_op_i) begin
	case(instr_op_i)
		//R-format
		6'b000000: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o} = 9'b110010100;
		//beq
		6'b000100: {RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o, MemRead_o, MemWrite_o} = 7'b0010100;	//RegDst, MemtoReg => x
		//addi
		6'b001000: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o} = 9'b100100100;
		//slti
		6'b001010: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o} = 9'b111100100;
		//lw
		6'b100011: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o} = 9'b100100010;
		//sw
		6'b101011: {RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o, MemRead_o, MemWrite_o} = 7'b0001001;	//RegDst, MemtoReg => x
		default: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o, MemtoReg_o, MemRead_o, MemWrite_o} = 9'b000000100;
	endcase
end

endmodule