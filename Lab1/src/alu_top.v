`timescale 1ns/1ps
// 110550093
module alu_top(
    /* input */
    src1,       //1 bit, source 1 (A)
    src2,       //1 bit, source 2 (B)
    less,       //1 bit, less
    A_invert,   //1 bit, A_invert
    B_invert,   //1 bit, B_invert
    cin,        //1 bit, carry in
    operation,  //2 bit, operation
    /* output */
    result,     //1 bit, result
    cout        //1 bit, carry out
);

/*==================================================================*/
/*                          input & output                          */
/*==================================================================*/

input src1;
input src2;
input less;
input A_invert;
input B_invert;
input cin;
input [1:0] operation;

output result;
output cout;

/*==================================================================*/
/*                            reg & wire                            */
/*==================================================================*/

reg result, cout;

/*==================================================================*/
/*                              design                              */
/*==================================================================*/

always@(*) begin
    case({A_invert, B_invert, operation})
        4'b0000: begin
            cout=0;
            result=src1&src2;
        end
        4'b0001: begin
            cout=0;
            result=src1|src2;
        end
        4'b0010: begin
            {cout, result}=cin+src1+src2;
        end
        4'b0110: begin
            {cout, result}=cin+src1+(!src2);
        end
        4'b1100: begin
            cout=0;
            result=(~src1)&(~src2);
        end
        4'b0111: begin
            result=less;
            cout=(cin&src1)|(src1&(~src2))|(cin&(~src2));
        end
    endcase
end

endmodule
