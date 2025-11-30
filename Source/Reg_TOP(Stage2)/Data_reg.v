`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 17:39:29
// Design Name: 
// Module Name: Data_reg
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

module Data_reg (
    input clk,
    input rst,
    input [31:0] in_data,
    output reg [31:0] out_data
);

  always @(posedge clk or posedge rst) begin
    if (rst)
      out_data <= 32'd0;
    else
      out_data <= in_data;
  end

endmodule