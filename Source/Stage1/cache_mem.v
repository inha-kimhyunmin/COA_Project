`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 15:08:58
// Design Name: 
// Module Name: cache_mem
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

module cache_mem #(
    parameter MEM_DEPTH = 1024  // 1024 words = 4KB
)(
    input         clk,
    input         MemRead,
    input         MemWrite,
    input  [31:0] address,       // byte address
    input  [31:0] write_data,
    output [31:0] read_data
);

  // Word-addressable memory (32bit x 1024)
  reg [31:0] mem [0:MEM_DEPTH-1];

  wire [9:0] word_addr = address[11:2];  // assuming word-aligned address (skip 2 LSBs)

  // Read (combinational)
  assign read_data = (MemRead) ? mem[word_addr] : 32'd0;

  // Write (synchronous)
  always @(posedge clk) begin
    if (MemWrite)
      mem[word_addr] <= write_data;
  end

endmodule