`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 21:43:42
// Design Name: 
// Module Name: Stage1
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

module Stage1(
    input         clk,
    input         reset,
    input  [21:0] control,        
    input  [31:0] next_pc,           // next PC
    input  [31:0] data_y,
    input  [31:0] data_z,

    output [31:0] current_pc,        // current PC
    output [31:0] instr_data_out    // instruction(or data) from Cache
    );
    
    // internal wire
    wire [31:0] pc_wire;
    wire [31:0] address;
    wire PCWrite, Inst_Data, MemRead, MemWrite;
    
    assign PCWrite = control[18];
    assign Inst_Data = control[17];
    assign MemRead = control[16];
    assign MemWrite = control[15];
    
    assign address = (Inst_Data) ? data_z : pc_wire;

    // PC Instantiation
    pc PC_inst (
        .clk(clk),
        .reset(reset),
        .PCWrite(PCWrite),
        .next_pc(next_pc),
        .pc_out(pc_wire)
    );

    // Cache Instantiation
    cache_mem Cache_inst (
        .clk(clk),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(address),
        .in_data(data_y),
        .out_data(instr_data_out)
    );

    assign current_pc = pc_wire;
    
    initial begin
        $display("Loading imem.mem into cache_mem.mem");
        $readmemh("imem2.mem", Cache_inst.mem);
    end
endmodule