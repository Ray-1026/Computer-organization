//Subject:     CO project 3 - ALU Controller
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
        8'b10_100100: ALUCtrl_o <= 4'b0000; //AND
        8'b10_100101: ALUCtrl_o <= 4'b0001; //OR
        8'b00_xxxxxx, 8'b10_100000: ALUCtrl_o <= 4'b0010; //addi, lw, sw, add
        8'b01_xxxxxx, 8'b10_100010: ALUCtrl_o <= 4'b0110; //beq, sub
        8'b10_101010, 8'b11_xxxxxx: ALUCtrl_o <= 4'b0111; //slt, slti
        default: ALUCtrl_o <= 4'b1111;
    endcase
end

endmodule 