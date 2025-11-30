`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 16:08:00
// Design Name: 
// Module Name: tb_pc
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

module tb_pc;

  reg clk;
  reg reset;
  reg PCWrite;
  reg [31:0] next_pc;
  wire [31:0] pc_out;

  // DUT
  pc dut (
    .clk(clk),
    .reset(reset),
    .PCWrite(PCWrite),
    .next_pc(next_pc),
    .pc_out(pc_out)
  );

  // Clock generation (10ns 주기)
  initial clk = 0;
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    $display("==== Program Counter Test Start ====");

    // 초기화
    reset = 1; PCWrite = 0; next_pc = 0;
    #10;

    reset = 0;
    #10;

    // PCWrite가 0일 때: PC 유지
    next_pc = 32'h00000010;
    PCWrite = 0;
    #10;
    $display("PCWrite=0, next_pc=0x10 -> pc_out=%h (Expectancy: 00000000)", pc_out);

    // PCWrite가 1일 때: PC 갱신
    PCWrite = 1;
    #10;
    $display("PCWrite=1, next_pc=0x10 -> pc_out=%h (Expectancy: 00000010)", pc_out);

    // 또다시 PCWrite가 1, 값 변경
    next_pc = 32'h00000020;
    #10;
    $display("PCWrite=1, next_pc=0x20 -> pc_out=%h (Expectancy: 00000020)", pc_out);

    // PCWrite 다시 0, 값 유지
    PCWrite = 0;
    next_pc = 32'h00000030;
    #10;
    $display("PCWrite=0, next_pc=0x30 -> pc_out=%h (Expectancy: 00000020)", pc_out);

    // Reset → PC 초기화
    reset = 1;
    #10;
    reset = 0;
    $display("Reset -> pc_out=%h (Expectancy: 00000000)", pc_out);

    $display("==== Program Counter Test End ====");
    $finish;
  end

endmodule