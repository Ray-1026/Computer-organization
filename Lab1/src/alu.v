`timescale 1ns/1ps
// 110550093
module alu(
    /* input */
    clk,            // system clock
    rst_n,          // negative reset
    src1,           // 32 bits, source 1
    src2,           // 32 bits, source 2
    ALU_control,    // 4 bits, ALU control input
    /* output */
    result,         // 32 bits, result
    zero,           // 1 bit, set to 1 when the output is 0
    cout,           // 1 bit, carry out
    overflow        // 1 bit, overflow
);

/*==================================================================*/
/*                          input & output                          */
/*==================================================================*/

input clk;
input rst_n;
input [31:0] src1;
input [31:0] src2;
input [3:0] ALU_control;

output [32-1:0] result;
output zero;
output cout;
output overflow;

/*==================================================================*/
/*                            reg & wire                            */
/*==================================================================*/

reg [32-1:0] result;
reg zero, cout, overflow;

wire set;
wire [32-1:0]carryout;
wire [32-1:0]temp_res;

/*==================================================================*/
/*                              design                              */
/*==================================================================*/

alu_top ALU00(
    .src1(src1[0]),
    .src2(src2[0]),
    .less(set),
    .A_invert(ALU_control[3]),
    .B_invert(ALU_control[2]),
    .cin(ALU_control[3:2]==2'b01),
    .operation(ALU_control[1:0]),
    .result(temp_res[0]),
    .cout(carryout[0])
);

genvar idx;
generate
    for(idx=1;idx<=31;idx=idx+1) begin
        alu_top ALU01_to_31(
            .src1(src1[idx]),
            .src2(src2[idx]),
            .less(1'b0),
            .A_invert(ALU_control[3]),
            .B_invert(ALU_control[2]),
            .cin(carryout[idx-1]),
            .operation(ALU_control[1:0]),
            .result(temp_res[idx]),
            .cout(carryout[idx])
        );
    end
endgenerate

assign set=src1[31]^(~src2[31])^carryout[30];

always@(posedge clk or negedge rst_n) 
begin
	if(!rst_n) begin
        result=0;
        zero=1'b0;
        cout=1'b0;
        overflow=1'b0;
	end
	else begin
        cout=1'b0;
        overflow=1'b0;
        result=temp_res;

        if(ALU_control[1:0]==2'b10) begin
            cout=carryout[31];
            if(ALU_control[2]==1'b0) begin
                overflow=(src1[31]&src2[31]&(~result[31]))|((~src1[31])&(~src2[31])&result[31]);
            end
            else begin
                overflow=((~src1[31])&src2[31]&result[31])|(src1[31]&(~src2[31])&(~result[31]));
            end
        end

        if(result==0) begin
            zero=1'b1;
        end
        else begin
            zero=1'b0;
        end
	end
end

endmodule
