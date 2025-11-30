`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/18 22:24:41
// Design Name: 
// Module Name: reg_file
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


module reg_file (
    input clk,
    input rst,

    // 레지스터 인덱스 선택
    input  [4:0] rs_idx,
    input  [4:0] rt_idx,
    input  [4:0] write_idx,  // mux에서 선택된 목적지 인덱스

    // 레지스터 쓰기
    input        RegWrite,
    input [31:0] write_data,

    // 레지스터 읽기
    output [31:0] rs_data,
    output [31:0] rt_data
);

  // 32개 32-bit 레지스터
  reg [31:0] regs[0:31];
  integer i;

  // 리셋 시 모든 레지스터 0으로 초기화
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1)
        regs[i] <= 32'd0;
    end else if (RegWrite && write_idx != 0) begin
      regs[write_idx] <= write_data;
    end
  end

  // 읽기는 항상 조합 논리 (read는 비동기)
  assign rs_data = regs[rs_idx];
  assign rt_data = regs[rt_idx];

endmodule