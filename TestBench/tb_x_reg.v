`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 16:54:20
// Design Name: 
// Module Name: tb_x_reg
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

module tb_x_reg;

  reg clk;
  reg rst;
  reg [31:0] in_data;
  wire [31:0] out_data;

  // DUT
  x_reg uut (
    .clk(clk),
    .rst(rst),
    .in_data(in_data),
    .out_data(out_data)
  );

  // 클럭 생성
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $display("==== x_reg Test Start ====");

    rst = 1; in_data = 32'h12345678;
    #10;

    rst = 0; in_data = 32'hDEADBEEF;
    #10;  // clk 상승 시 latch

    in_data = 32'hCAFEBABE;
    #10;

    $display("out_data = %h (Expectancy: DEADBEEF)", out_data);

    rst = 1;
    #10;

    $display("Reset -> out_data = %h (Expectancy: 00000000)", out_data);

    $display("==== x_reg Test End ====");
    $finish;
  end

endmodule