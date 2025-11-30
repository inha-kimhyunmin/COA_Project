`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 19:35:14
// Design Name: 
// Module Name: tb_Adder_32
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

module tb_Adder_32;

    reg  [31:0] a, b;
    reg         cin;        // 0: add, 1: subtract
    wire [31:0] sum;
    wire        cout;
    wire        zero;
    wire        ovf;

    // DUT 인스턴스
    Adder_32 DUT (
        .a(a),
        .b_pre(b),
        .cin(cin),
        .sum(sum),
        .cout(cout),
        .zero(zero),
        .ovf(ovf)
    );

    initial begin
        $display("===== 32-bit Adder Testbench Start =====");
        $monitor("Time=%0t | a=%h | b=%h | cin=%b | sum=%h | cout=%b | zero=%b | ovf=%b",
                  $time, a, b, cin, sum, cout, zero, ovf);

        // Test 1: Simple addition
        a = 32'd10; b = 32'd20; cin = 0;
        #10;

        // Test 2: Addition with carry-out
        a = 32'hFFFF_FFFF; b = 32'd1; cin = 0;
        #10;

        // Test 3: Subtraction (a - b)
        a = 32'd50; b = 32'd10; cin = 1;
        #10;

        // Test 4: Zero result
        a = 32'd15; b = 32'd15; cin = 1;   // 15 - 15 = 0
        #10;

        // Test 5: Overflow test (positive + positive = negative)
        a = 32'h7FFF_FFFF; b = 32'd1; cin = 0;
        #10;

        // Test 6: Overflow test (negative + negative = positive)
        a = 32'h8000_0000; b = 32'h8000_0000; cin = 0;
        #10;

        // Test 7: Random test
        a = 32'hABCD_1234; b = 32'h1000_0001; cin = 0;
        #10;

        $display("===== 32-bit Adder Testbench End =====");
        $finish;
    end

endmodule