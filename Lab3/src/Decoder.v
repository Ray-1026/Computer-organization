//Subject:     CO project 3 - Decoder
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      蔡師睿 110550093
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module Decoder(
    instr_op_i,
	instr_funct_i,
	Branch_o,
	MemtoReg_o,
	BranchType_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	ALU_op_o,
	ALUSrc_o,
	RegWrite_o,
	RegDst_o
);

//I/O ports
input  [6-1:0] instr_op_i, instr_funct_i;

output         Branch_o, MemRead_o, MemWrite_o, ALUSrc_o, RegWrite_o;
output [2-1:0] MemtoReg_o, BranchType_o, Jump_o, ALU_op_o, RegDst_o;

//Internal Signals
reg            Branch_o, MemRead_o, MemWrite_o, ALUSrc_o, RegWrite_o;
reg    [2-1:0] MemtoReg_o, BranchType_o, Jump_o, ALU_op_o, RegDst_o;

//Parameter

//Main function
always @(*) begin
	case(instr_op_i)
		//R-format
		6'd0: begin
			if(instr_funct_i==6'd8) begin //jr
				RegWrite_o <= 1'b0; //ALUSrc, Branch => x ; ALU_op, RegDst => xx
				{Jump_o, MemRead_o, MemWrite_o} <= 4'b1000; //MemtoReg, BranchType => xx
			end
			else begin //and, or, add, sub, slt
				{RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o} <= 7'b1100010;
				{Jump_o, MemtoReg_o, MemRead_o, MemWrite_o, BranchType_o} <= 8'b01000000;
			end
		end
		//jump
		6'd2: begin
			RegWrite_o <= 1'b0; //ALUSrc, Branch => x ; ALU_op, RegDst => xx
			{Jump_o, MemRead_o, MemWrite_o} <= 4'b0000; //MemtoReg, BranchType => xx
		end
		//jal
		6'd3: begin
			{RegWrite_o, RegDst_o} <= 3'b110; //ALUSrc, Branch => x ; ALUop => xx
			{Jump_o, MemtoReg_o, MemRead_o, MemWrite_o} <= 6'b001100; //BranchType => xx
		end
		//beq
		6'd4: begin
			{RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o} <= 5'b00101; //RegDst => xx
			{Jump_o, MemRead_o, MemWrite_o, BranchType_o} <= 6'b010000; //MemtoReg => xx
		end
		//bne
		6'd5: begin
			{RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o} <= 5'b00101; //RegDst => xx
			{Jump_o, MemRead_o, MemWrite_o, BranchType_o} <= 6'b010011; //MemtoReg => xx
		end
		//addi
		6'd8: begin
			{RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o} <= 7'b1001000;
			{Jump_o, MemtoReg_o, MemRead_o, MemWrite_o} <= 6'b010000; //BranchType => xx
		end
		//slti
		6'd10: begin
			{RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o} <= 7'b1111000;
			{Jump_o, MemtoReg_o, MemRead_o, MemWrite_o} <= 6'b010000; //BranchType => xx
		end
		//lw
		6'd35: begin
			{RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o} <= 7'b1001000;
			{Jump_o, MemtoReg_o, MemRead_o, MemWrite_o} <= 6'b010110; //BranchType => xx
		end
		//sw
		6'd43: begin
			{RegWrite_o, ALU_op_o, ALUSrc_o, Branch_o} <= 5'b00010; //RegDst => xx
			{Jump_o, MemRead_o, MemWrite_o} <= 4'b0101; //MemtoReg, BranchType => xx
		end
		default: begin
			{RegWrite_o, ALU_op_o, ALUSrc_o, RegDst_o, Branch_o} <= 7'b0000000;
			{Jump_o, MemtoReg_o, MemRead_o, MemWrite_o, BranchType_o} <= 8'b01000000;
		end
	endcase
end

endmodule