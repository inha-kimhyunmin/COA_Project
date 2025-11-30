`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 15:11:43
// Design Name: 
// Module Name: tb_cache_mem
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

module tb_cache_mem;

  reg         clk;
  reg         MemRead;
  reg         MemWrite;
  reg  [31:0] address;
  reg  [31:0] write_data;
  wire [31:0] read_data;

  // DUT 인스턴스
  cache_mem dut (
    .clk(clk),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .address(address),
    .write_data(write_data),
    .read_data(read_data)
  );

  // Clock generation: 10ns 주기
  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("cache_mem_tb.vcd");
    $dumpvars(0, tb_cache_mem);

    $display("==== cache_mem Test start ====");

    // 초기화
    MemRead = 0;
    MemWrite = 0;
    address = 0;
    write_data = 0;

    #10;

    // Write 0xDEADBEEF to address 4 (word address 1)
    address = 32'd4;
    write_data = 32'hDEADBEEF;
    MemWrite = 1;
    #10;

    MemWrite = 0;
    #10;

    // Read from address 4
    MemRead = 1;
    #1;
    $display("Read from addr 0x04 = %h (expected DEADBEEF)", read_data);
    #10;

    MemRead = 0;

    // Write 0x12345678 to address 8 (word address 2)
    address = 32'd8;
    write_data = 32'h12345678;
    MemWrite = 1;
    #10;

    MemWrite = 0;
    #10;

    // Read from address 8
    MemRead = 1;
    #1;
    $display("Read from addr 0x08 = %h (expected 12345678)", read_data);
    #10;

    $display("==== cache_mem Test complete ====");
    $finish;
  end

endmodule