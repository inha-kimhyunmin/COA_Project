`timescale 1ns / 1ps

module tb_PC_TOP;

    // -------------------------
    // Signals
    // -------------------------
    reg clk;
    reg reset;

    reg  [31:0] alu_out;
    reg  [31:0] x_reg_out;
    reg  [25:0] jta;
    reg  [31:0] pc;
    reg  [29:0] syscall;
    reg  [21:0] ctrl_in;

    wire [31:0] pc_src;
    wire [31:0] z_reg_out;

    // -------------------------
    // DUT
    // -------------------------
    PC_TOP uut (
        .clk        (clk),
        .reset      (reset),
        .alu_out    (alu_out),
        .x_reg_out  (x_reg_out),
        .jta        (jta),
        .pc         (pc),
        .syscall    (syscall),
        .ctrl_in    (ctrl_in),
        .pc_src     (pc_src),
        .z_reg_out  (z_reg_out)
    );

    // -------------------------
    // Clock generation
    // -------------------------
    initial clk = 0;
    always #5 clk = ~clk; // 10ns period

    // -------------------------
    // Test sequence
    // -------------------------
    initial begin
        // 초기화
        reset = 1;
        alu_out = 32'd0;
        x_reg_out = 32'd0;
        jta = 26'd0;
        pc = 32'h1000_0000; // 예시 PC (이미 PC+4)
        syscall = 30'h3FFF_FFFF; 
        ctrl_in = 22'd0;

        #20;
        reset = 0;

        // --- 테스트 1: JUMPADDR=0, PCSRC=00 (jump) ---
        ctrl_in = 22'b0_00_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0; // JUMPADDR=0, PCSRC=00
        jta = 26'h3FFFFF;  // 최대 jump 값
        #10;
        $display("TEST1: pc_src=%h, z_reg_out=%h", pc_src, z_reg_out);

        // --- 테스트 2: JUMPADDR=1 (syscall jump), PCSRC=00 ---
        ctrl_in[21] = 1; // JUMPADDR=1
        #10;
        $display("TEST2: pc_src=%h, z_reg_out=%h", pc_src, z_reg_out);

        // --- 테스트 3: PCSRC=01 (x_reg_out) ---
        ctrl_in[21] = 0;
        ctrl_in[20:19] = 2'b01;
        x_reg_out = 32'h1234_5678;
        #10;
        $display("TEST3: pc_src=%h, z_reg_out=%h", pc_src, z_reg_out);

        // --- 테스트 4: PCSRC=10 (z_reg_out) ---
        ctrl_in[20:19] = 2'b10;
        alu_out = 32'hDEAD_BEEF; 
        #10;
        $display("TEST4: pc_src=%h, z_reg_out=%h", pc_src, z_reg_out);

        // --- 테스트 5: PCSRC=11 (alu_out 직접) ---
        ctrl_in[20:19] = 2'b11;
        alu_out = 32'hCAFEBABE;
        #10;
        $display("TEST5: pc_src=%h, z_reg_out=%h", pc_src, z_reg_out);

        $finish;
    end

endmodule
