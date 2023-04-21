//Subject:     CO project 2 - ALU Controller
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
module ALU_Ctrl(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);
          
//I/O ports 
input      [6-1:0] funct_i;
input      [3-1:0] ALUOp_i;

output     [4-1:0] ALUCtrl_o;    
     
//Internal Signals
reg        [4-1:0] ALUCtrl_o;

//Parameter

//Select exact operation
always @(funct_i, ALUOp_i) begin
    casex({ALUOp_i, funct_i})
        9'b010_100100: ALUCtrl_o <= 4'b0000;
        9'b010_100101: ALUCtrl_o <= 4'b0001;
        9'b000_xxxxxx, 9'b010_100000: ALUCtrl_o <= 4'b0010;
        9'b001_xxxxxx, 9'b010_100010: ALUCtrl_o <= 4'b0110;
        9'b010_101010, 9'b011_xxxxxx: ALUCtrl_o <= 4'b0111;
    endcase
end

endmodule     





                    
                    