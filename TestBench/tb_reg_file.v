`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/18 22:50:05
// Design Name: 
// Module Name: tb_reg_file
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


module tb_reg_file;

  reg clk;
  reg rst;

  reg  [4:0] rs_idx, rt_idx, write_idx;
  reg        RegWrite;
  reg [31:0] write_data;

  wire [31:0] rs_data, rt_data;

  // DUT 인스턴스
  reg_file dut (
    .clk(clk),
    .rst(rst),
    .rs_idx(rs_idx),
    .rt_idx(rt_idx),
    .write_idx(write_idx),
    .RegWrite(RegWrite),
    .write_data(write_data),
    .rs_data(rs_data),
    .rt_data(rt_data)
  );

  // 클럭 생성 (10ns 주기)
  initial clk = 0;
  always #5 clk = ~clk;

  // 테스트 시나리오
  initial begin
    $dumpfile("reg_file_tb.vcd");
    $dumpvars(0, tb_reg_file);
    
    $display("==== reg_file Test start ====");
    
    // 초기화
    rst = 1; RegWrite = 0;
    rs_idx = 0; rt_idx = 0; write_idx = 0; write_data = 0;

    // Reset assert
    #10;
    rst = 0;
    $display("Reset complete");

    // Write 42 to reg[5]
    write_idx   = 5;
    write_data  = 32'h0000_0042;
    RegWrite    = 1;
    #10;

    // Read from reg[5]
    RegWrite = 0;
    rs_idx = 5;
    rt_idx = 0;
    #1;  // 읽기용 짧은 지연
    $display("reg[5] read (rs_data): %08x", rs_data);

    // Write 1234_5678 to reg[10]
    write_idx   = 10;
    write_data  = 32'h1234_5678;
    RegWrite    = 1;
    #10;

    // Read from reg[10]
    RegWrite = 0;
    rs_idx = 10;
    #1;
    $display("reg[10] read (rs_data): %08x", rs_data);

    // Try writing to reg[0] (should remain 0)
    write_idx   = 0;
    write_data  = 32'hFFFF_FFFF;
    RegWrite    = 1;
    #10;

    RegWrite = 0;
    rs_idx = 0;
    #1;
    $display("reg[0] read after write attempt: %08x", rs_data);

    $display("==== reg_file Test Succeed ====");
    $finish;
  end

endmodule