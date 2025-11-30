`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 15:59:34
// Design Name: 
// Module Name: pc
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

module pc (
    input        clk,
    input        reset,
    input        PCWrite,         // enable
    input  [31:0] next_pc,
    output reg [31:0] pc_out
);

  always @(posedge clk or posedge reset) begin
    if (reset)
      pc_out <= 32'd0;           // ì´ˆê¸°ê°? 0ë²? ì£¼ì†Œ
    else if (PCWrite)
      pc_out <= next_pc;         // enable ?  ?•Œë§? update
  end

endmodule