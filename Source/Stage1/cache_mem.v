`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/23 19:33:42
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


module cache_mem(
    input               clk,
    input               MemRead,
    input               MemWrite,
    input        [31:0] addr,      // full address, but we'll use addr[11:2]
    input        [31:0] in_data,
    output reg   [31:0] out_data
    );
    
    // Simple 4KB memory (1024 words)
    reg [31:0] mem [0:255];
    integer i;

    // ---------------------------------------------------
    // Memory Initialize & Instruction Hardcoding 영역
    // ---------------------------------------------------
    initial begin
//        // 전체 clear
//        for (i = 0; i < 256; i = i + 1)
//            mem[i] = 32'd0;

        // -----------------------------
        // 여기에 원하는 명령어 입력
        // -----------------------------
        // 예: addi $1 $0 5
        // mem[0] = 32'h20010005;

        // 예: addi $2 $0 10
        // mem[1] = 32'h2002000A;

        // 예: add $3 $1 $2   ($3 = $1 + $2)
        // mem[2] = 32'h00221820;

        // 예: sw $3, 0($0)
        // mem[3] = 32'hAC030000;

        // 예: lw $4, 0($0)
        // mem[4] = 32'h8C040000;

        // 필요한 만큼 계속 추가하면 됨.
    end
    
    // ---------------------------------------------------
    // Address decoding
    // ---------------------------------------------------
    // addr[11:2] -> word addressing
    wire [7:0] waddr = addr[9:2];

    // ---------------------------------------------------
    // Synchronous Write
    // ---------------------------------------------------
    always @(posedge clk) begin
        if (MemWrite && !MemRead) begin
            mem[waddr] <= in_data;
        end
    end

    // ---------------------------------------------------
    // Asynchronous Read
    // ---------------------------------------------------
    always @(*) begin
        if (MemRead && !MemWrite)
            out_data = mem[waddr];
        else
            out_data = 32'd0;
    end
    
endmodule
