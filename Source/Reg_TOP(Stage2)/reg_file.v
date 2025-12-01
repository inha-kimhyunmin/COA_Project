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

    // ? ˆì§??Š¤?„° ?¸?±?Š¤ ?„ ?ƒ
    input  [4:0] rs_idx,
    input  [4:0] rt_idx,
    input  [4:0] write_idx,  // mux?—?„œ ?„ ?ƒ?œ ëª©ì ì§? ?¸?±?Š¤

    // ? ˆì§??Š¤?„° ?“°ê¸?
    input        RegWrite,
    input [31:0] write_data,

    // ? ˆì§??Š¤?„° ?½ê¸?
    output [31:0] rs_data,
    output [31:0] rt_data
);

  // 32ê°? 32-bit ? ˆì§??Š¤?„°
  reg [31:0] regs[0:31];
  integer i;

  // ë¦¬ì…‹ ?‹œ ëª¨ë“  ? ˆì§??Š¤?„° 0?œ¼ë¡? ì´ˆê¸°?™”
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1)
        regs[i] <= 32'd0;
    end else if (RegWrite && write_idx != 0) begin
      regs[write_idx] <= write_data;
    end
  end

  // ?½ê¸°ëŠ” ?•­?ƒ ì¡°í•© ?…¼ë¦? (read?Š” ë¹„ë™ê¸?)
  assign rs_data = regs[rs_idx];
  assign rt_data = regs[rt_idx];

endmodule