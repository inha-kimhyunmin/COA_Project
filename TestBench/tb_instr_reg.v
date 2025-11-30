`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 15:52:03
// Design Name: 
// Module Name: tb_instr_reg
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

module tb_instr_reg;

  reg clk;
  reg reset;
  reg IRWrite;
  reg [31:0] instr_in;

  wire [5:0] op, funct;
  wire [4:0] rs, rt, rd, shamt;
  wire [15:0] imm;
  wire [25:0] jta;

  // DUT
  instr_reg uut (
    .clk(clk),
    .reset(reset),
    .IRWrite(IRWrite),
    .instr_in(instr_in),
    .op(op),
    .rs(rs),
    .rt(rt),
    .rd(rd),
    .shamt(shamt),
    .funct(funct),
    .imm(imm),
    .jta(jta)
  );

  // Clock generation (10ns 주기)
  initial clk = 0;
  always #5 clk = ~clk;

  // Test sequence
  initial begin
    $display("==== Instruction Register Test Start ====");

    // 초기화
    reset = 1; IRWrite = 0; instr_in = 32'd0;
    #10;

    reset = 0;
    #10;

    // 테스트용 instruction: addi $t2, $t1, 10
    // binary: 001000 01001 01010 0000000000001010
    //         op     rs    rt    imm
    instr_in = 32'b001000_01001_01010_0000000000001010;

    // IRWrite가 0일 때는 래치되지 않음
    IRWrite = 0;
    #10;

    // IRWrite가 1일 때 래치됨
    IRWrite = 1;
    #10;

    // 결과 출력
    $display("op     = %b", op);     // 기대값: 001000
    $display("rs     = %d", rs);     // 기대값: 9
    $display("rt     = %d", rt);     // 기대값: 10
    $display("imm    = %h", imm);    // 기대값: 000A
    $display("jta    = %h", jta);    // 기대값: 25:0 전체

    $display("==== Instruction Register Test End ====");
    $finish;
  end

endmodule