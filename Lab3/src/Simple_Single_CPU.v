//Subject:     CO project 3 - Simple Single CPU
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      蔡師睿 110550093
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------
module Simple_Single_CPU(
        clk_i,
	rst_i,
);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire [31:0] pc_in, pc_out, instruction, next_addr, goto_addr;
wire [31:0] pc_src, jump_addr;

wire Branch, MemRead, MemWrite, ALUSrc, RegWrite;
wire [1:0] MemtoReg, BranchType, Jump, ALUop, RegDst;

wire [31:0] rs, rt, rd_data, se_out, src_out, mem_out, shift;
wire [4:0] rd;

wire [3:0] ALU_ctrl;
wire [31:0] ALU_res;
wire zero, branchtype_out;

//Greate componentes
ProgramCounter PC(
        .clk_i(clk_i),      
	.rst_i(rst_i),     
	.pc_in_i(pc_in),   
	.pc_out_o(pc_out) 
);
	
Adder Adder1(
        .src1_i(32'd4),     
	.src2_i(pc_out),     
	.sum_o(next_addr)
);
	
Instr_Memory IM(
        .pc_addr_i(pc_out),  
	.instr_o(instruction)    
);

MUX_3to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instruction[20:16]),
        .data1_i(instruction[15:11]),
        .data2_i(5'd31),
        .select_i(RegDst),
        .data_o(rd)
);	
		
Reg_File Registers(
        .clk_i(clk_i),
	.rst_i(rst_i),
        .RSaddr_i(instruction[25:21]),
        .RTaddr_i(instruction[20:16]),
        .RDaddr_i(rd),
        .RDdata_i(rd_data),
        .RegWrite_i(RegWrite),
        .RSdata_o(rs),
        .RTdata_o(rt)
);
	
Decoder Decoder(
        .instr_op_i(instruction[31:26]),
        .instr_funct_i(instruction[5:0]),
	.Branch_o(Branch),
        .MemtoReg_o(MemtoReg),
        .BranchType_o(BranchType),
	.Jump_o(Jump),
	.MemRead_o(MemRead),
	.MemWrite_o(MemWrite),
	.ALU_op_o(ALUop),
	.ALUSrc_o(ALUSrc),
	.RegWrite_o(RegWrite),
	.RegDst_o(RegDst)
);

ALU_Ctrl AC(
        .funct_i(instruction[5:0]),
        .ALUOp_i(ALUop),
        .ALUCtrl_o(ALU_ctrl)
);
	
Sign_Extend SE(
        .data_i(instruction[15:0]),
        .data_o(se_out)
);

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(rt),
        .data1_i(se_out),
        .select_i(ALUSrc),
        .data_o(src_out)
);
		
ALU ALU(
        .src1_i(rs),
	.src2_i(src_out),
	.ctrl_i(ALU_ctrl),
	.result_o(ALU_res),
	.zero_o(zero)
);
	
Data_Memory Data_Memory(
	.clk_i(clk_i),
	.addr_i(ALU_res),
	.data_i(rt),
	.MemRead_i(MemRead),
	.MemWrite_i(MemWrite),
	.data_o(mem_out)
);

Shift_Left_Two_32 Shifter(
        .data_i(se_out),
        .data_o(shift)
);

Shift_Left_Two_32 Shift_Jump(
        .data_i(instruction),
        .data_o(jump_addr)
);

Adder Adder2(
        .src1_i(next_addr),
	.src2_i(shift),
	.sum_o(goto_addr)
);

MUX_4to1 #(.size(1)) Mux_BranchType(
        .data0_i(zero),
        .data1_i(~(ALU_res[31]|zero)),
        .data2_i(~ALU_res[31]),
        .data3_i(~zero),
        .select_i(BranchType),
        .data_o(branchtype_out)
);

MUX_4to1 #(.size(32)) Mux_MemtoReg(
        .data0_i(ALU_res),
        .data1_i(mem_out),
        .data2_i(se_out),
        .data3_i(next_addr),
        .select_i(MemtoReg),
        .data_o(rd_data)
);

MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(next_addr),
        .data1_i(goto_addr),
        .select_i(branchtype_out&Branch),
        .data_o(pc_src)
);	

MUX_3to1 #(.size(32)) Mux_PC_Jump(
        .data0_i({next_addr[31:28], jump_addr[27:0]}),
        .data1_i(pc_src),
        .data2_i(rs),
        .select_i(Jump),
        .data_o(pc_in)
);

endmodule