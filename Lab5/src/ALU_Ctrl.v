//Subject:     CO project 5 - ALU Controller
//--------------------------------------------------------------------------------
//Version:     1
//--------------------------------------------------------------------------------
//Writer:      蔡師睿 110550093
//----------------------------------------------
//Date:        
//----------------------------------------------
//Description: 
//--------------------------------------------------------------------------------

module ALU_Ctrl(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);
          
//I/O ports 
input      [6-1:0] funct_i;
input      [2-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;

//Parameter

//Select exact operation
always @(*) begin
    casex({ALUOp_i, funct_i})
        8'b10_100100: ALUCtrl_o <= 4'b0000; //and
        8'b10_100101: ALUCtrl_o <= 4'b0001; //or
        8'b10_100110: ALUCtrl_o <= 4'b0011; //xor
        8'b10_011000: ALUCtrl_o <= 4'b1000; //mult
        8'b10_100000, 8'b00_xxxxxx: ALUCtrl_o <= 4'b0010; //addi, lw, sw, add
        8'b10_100010, 8'b01_xxxxxx: ALUCtrl_o <= 4'b0110; //beq, sub
        8'b10_101010, 8'b11_xxxxxx: ALUCtrl_o <= 4'b0111; //slt, slti
        default: ALUCtrl_o <= 4'b1111;  //others
    endcase
end

endmodule 