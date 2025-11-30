`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 15:11:15
// Design Name: 
// Module Name: alu_logic_unit
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

module alu_logic_unit(
    input [31:0] in_x_data,
    input [31:0] in_y_data,
    input [1:0] logic_fn,
    output reg [31:0] out_logic_data
);
  always @* begin
    out_logic_data = 32'd0;
      
    case (logic_fn)
        2'b00 : out_logic_data = in_x_data & in_y_data;
        2'b01 : out_logic_data = in_x_data | in_y_data;
        2'b10 : out_logic_data = in_x_data ^ in_y_data;
        2'b11 : out_logic_data = ~(in_x_data | in_y_data); // NOR
    endcase
    
  end
endmodule
