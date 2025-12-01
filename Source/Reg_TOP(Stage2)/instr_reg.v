`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 15:03:34
// Design Name: 
// Module Name: instr_reg
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

module instr_reg (
    input        clk,
    input        reset,
    input        IRWrite,           // ? œ?–´ ?‹ ?˜¸
    input [31:0] instr_in,          // ë©”ëª¨ë¦¬ì—?„œ ?½?? instruction
    output [5:0] op,                // opcode: instr[31:26]
    output [4:0] rs, rt, rd, shamt, // instr[25:21], ...
    output [5:0] funct,             // instr[5:0]
    output [15:0] imm,              // instr[15:0]
    output [25:0] jta               // instr[25:0] (Jump target address)
);

  reg [31:0] instr;

  always @(posedge clk or posedge reset) begin
    if (reset)
      ;//instr <= 32'b0;
    else if (IRWrite)
      instr <= instr_in;
  end

  assign op     = instr[31:26];
  assign rs     = instr[25:21];
  assign rt     = instr[20:16];
  assign rd     = instr[15:11];
  assign shamt  = instr[10:6];
  assign funct  = instr[5:0];
  assign imm    = instr[15:0];
  assign jta    = instr[25:0];

endmodule