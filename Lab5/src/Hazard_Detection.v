//Subject:     CO project 5 - Hazard Detection
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
module Hazard_Detection(
    PCSrc_i,
    MemRead_IdEx_i,
    Rs_IfId_i,
    Rt_IfId_i,
    Rt_IdEx_i,
    PCWrite_o,
    IF_ID_Write_o,
    IF_Flush_o,
    ID_Flush_o,
    EX_Flush_o
);

//I/O ports
input         PCSrc_i;
input         MemRead_IdEx_i;
input [5-1:0] Rs_IfId_i;
input [5-1:0] Rt_IfId_i;
input [5-1:0] Rt_IdEx_i;

output        PCWrite_o;
output        IF_ID_Write_o;
output        IF_Flush_o;
output        ID_Flush_o;
output        EX_Flush_o;

//Internal Signals
reg           PCWrite_o;
reg           IF_ID_Write_o;
reg           IF_Flush_o;
reg           ID_Flush_o;
reg           EX_Flush_o;

//Parameter

//Main function
always @(*) begin
    //init
    {PCWrite_o, IF_ID_Write_o, IF_Flush_o, ID_Flush_o, EX_Flush_o} <= 5'b11000;
    
    //lw
    if(MemRead_IdEx_i && ((Rt_IdEx_i==Rs_IfId_i)||(Rt_IdEx_i==Rt_IfId_i))) begin
        PCWrite_o <= 1'b0;
        IF_ID_Write_o <= 1'b0;
        ID_Flush_o <= 1'b1;
    end
    
    //branch
    if(PCSrc_i) begin
        IF_Flush_o <= 1'b1;
        ID_Flush_o <= 1'b1;
        EX_Flush_o <= 1'b1;
    end
end

endmodule