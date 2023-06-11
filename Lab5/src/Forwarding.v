//Subject:     CO project 5 - Forwarding
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
module Forwarding(
    Rs_IdEx_i,
    Rt_IdEx_i,
    Rd_ExMem_i,
    RegWrite_ExMem_i,
    Rd_MemWb_i,
    RegWrite_MemWb_i,
    ForwardA_o,
    ForwardB_o
);

//I/O ports
input  [5-1:0] Rs_IdEx_i;
input  [5-1:0] Rt_IdEx_i;
input  [5-1:0] Rd_ExMem_i;
input          RegWrite_ExMem_i;
input  [5-1:0] Rd_MemWb_i;
input          RegWrite_MemWb_i;

output [2-1:0] ForwardA_o;
output [2-1:0] ForwardB_o;

//Internal Signals
reg    [2-1:0] ForwardA_o;
reg    [2-1:0] ForwardB_o;

//Parameter

//Main function
always @(*) begin
    //ForwardA
    if(RegWrite_MemWb_i && Rd_MemWb_i!=0 && Rd_MemWb_i==Rs_IdEx_i)
        ForwardA_o <= 2'b10;
    else if(RegWrite_ExMem_i && Rd_ExMem_i!=0 && Rd_ExMem_i==Rs_IdEx_i)
        ForwardA_o <= 2'b01;
    else
        ForwardA_o <= 2'b00;

    //ForwardB
    if(RegWrite_MemWb_i && Rd_MemWb_i!=0 && Rd_MemWb_i==Rt_IdEx_i)
        ForwardB_o <= 2'b10;
    else if(RegWrite_ExMem_i && Rd_ExMem_i!=0 && Rd_ExMem_i==Rt_IdEx_i)
        ForwardB_o <= 2'b01;
    else
        ForwardB_o <= 2'b00;
end

endmodule