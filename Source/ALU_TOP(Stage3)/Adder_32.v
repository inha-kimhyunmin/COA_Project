`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 19:27:26
// Design Name: 
// Module Name: Adder_32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module Adder_32(
    input  [31:0] a,
    input  [31:0] b_pre,
    input         cin,
    output [31:0] sum,
    output        cout,
    output        zero, 
    output        ovf
    );
    
    wire [30:0] c;
    wire [31:0] b;
    
    assign b = (cin) ? ~b_pre : b_pre;

    // 첫 번째 비트: cin 사용
    fa_1 fa0  (.a(a[0]),  .b(b[0]),  .cin(cin),     .sum(sum[0]),  .cout(c[0]));
    fa_1 fa1  (.a(a[1]),  .b(b[1]),  .cin(c[0]),    .sum(sum[1]),  .cout(c[1]));
    fa_1 fa2  (.a(a[2]),  .b(b[2]),  .cin(c[1]),    .sum(sum[2]),  .cout(c[2]));
    fa_1 fa3  (.a(a[3]),  .b(b[3]),  .cin(c[2]),    .sum(sum[3]),  .cout(c[3]));
    fa_1 fa4  (.a(a[4]),  .b(b[4]),  .cin(c[3]),    .sum(sum[4]),  .cout(c[4]));
    fa_1 fa5  (.a(a[5]),  .b(b[5]),  .cin(c[4]),    .sum(sum[5]),  .cout(c[5]));
    fa_1 fa6  (.a(a[6]),  .b(b[6]),  .cin(c[5]),    .sum(sum[6]),  .cout(c[6]));
    fa_1 fa7  (.a(a[7]),  .b(b[7]),  .cin(c[6]),    .sum(sum[7]),  .cout(c[7]));
    fa_1 fa8  (.a(a[8]),  .b(b[8]),  .cin(c[7]),    .sum(sum[8]),  .cout(c[8]));
    fa_1 fa9  (.a(a[9]),  .b(b[9]),  .cin(c[8]),    .sum(sum[9]),  .cout(c[9]));
    fa_1 fa10 (.a(a[10]), .b(b[10]), .cin(c[9]),    .sum(sum[10]), .cout(c[10]));
    fa_1 fa11 (.a(a[11]), .b(b[11]), .cin(c[10]),   .sum(sum[11]), .cout(c[11]));
    fa_1 fa12 (.a(a[12]), .b(b[12]), .cin(c[11]),   .sum(sum[12]), .cout(c[12]));
    fa_1 fa13 (.a(a[13]), .b(b[13]), .cin(c[12]),   .sum(sum[13]), .cout(c[13]));
    fa_1 fa14 (.a(a[14]), .b(b[14]), .cin(c[13]),   .sum(sum[14]), .cout(c[14]));
    fa_1 fa15 (.a(a[15]), .b(b[15]), .cin(c[14]),   .sum(sum[15]), .cout(c[15]));
    fa_1 fa16 (.a(a[16]), .b(b[16]), .cin(c[15]),   .sum(sum[16]), .cout(c[16]));
    fa_1 fa17 (.a(a[17]), .b(b[17]), .cin(c[16]),   .sum(sum[17]), .cout(c[17]));
    fa_1 fa18 (.a(a[18]), .b(b[18]), .cin(c[17]),   .sum(sum[18]), .cout(c[18]));
    fa_1 fa19 (.a(a[19]), .b(b[19]), .cin(c[18]),   .sum(sum[19]), .cout(c[19]));
    fa_1 fa20 (.a(a[20]), .b(b[20]), .cin(c[19]),   .sum(sum[20]), .cout(c[20]));
    fa_1 fa21 (.a(a[21]), .b(b[21]), .cin(c[20]),   .sum(sum[21]), .cout(c[21]));
    fa_1 fa22 (.a(a[22]), .b(b[22]), .cin(c[21]),   .sum(sum[22]), .cout(c[22]));
    fa_1 fa23 (.a(a[23]), .b(b[23]), .cin(c[22]),   .sum(sum[23]), .cout(c[23]));
    fa_1 fa24 (.a(a[24]), .b(b[24]), .cin(c[23]),   .sum(sum[24]), .cout(c[24]));
    fa_1 fa25 (.a(a[25]), .b(b[25]), .cin(c[24]),   .sum(sum[25]), .cout(c[25]));
    fa_1 fa26 (.a(a[26]), .b(b[26]), .cin(c[25]),   .sum(sum[26]), .cout(c[26]));
    fa_1 fa27 (.a(a[27]), .b(b[27]), .cin(c[26]),   .sum(sum[27]), .cout(c[27]));
    fa_1 fa28 (.a(a[28]), .b(b[28]), .cin(c[27]),   .sum(sum[28]), .cout(c[28]));
    fa_1 fa29 (.a(a[29]), .b(b[29]), .cin(c[28]),   .sum(sum[29]), .cout(c[29]));
    fa_1 fa30 (.a(a[30]), .b(b[30]), .cin(c[29]),   .sum(sum[30]), .cout(c[30]));
    fa_1 fa31 (.a(a[31]), .b(b[31]), .cin(c[30]),   .sum(sum[31]), .cout(cout));
    
    // overflow, zero flag
    assign ovf  = c[30] ^ cout;
    assign zero = (sum == 32'd0);
    
endmodule