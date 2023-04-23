//Subject:     CO project 2 - Decoder
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
module Decoder(
    instr_op_i,
	RegWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegDst_o,
	Branch_o
);
     
//I/O ports
input  [6-1:0] instr_op_i;

output         RegWrite_o;
output [3-1:0] ALU_op_o;
output         ALUSrc_o;
output         RegDst_o;
output         Branch_o;
 
//Internal Signals
reg            RegWrite_o;
reg    [3-1:0] ALU_op_o;
reg            ALUSrc_o;
reg            RegDst_o;
reg            Branch_o;

//Parameter

//Main function
always @(instr_op_i) begin
	case(instr_op_i)
		6'b000000: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o} = 7'b1010010;
		6'b000100: {RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o} = 6'b000101;
		6'b001000: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o} = 7'b1000100;
		6'b001010: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o} = 7'b1011100;
		default: {RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o} = 7'bxxxxxxx;
	endcase
end

endmodule