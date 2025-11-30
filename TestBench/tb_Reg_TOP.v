`timescale 1ns/1ps

module Reg_TOP_tb;

    reg clk;
    reg reset;

    reg IRWrite;
    reg [31:0] instr_in;

    reg [31:0] data_in;
    reg [31:0] alu_out;

    reg DRegSel0;
    reg DRegSel1;
    reg [1:0] RegDst;
    reg RegInSrc;
    reg RegWrite;

    wire [31:0] rs_data_out;
    wire [31:0] rt_data_out;
    wire [25:0] jta_out;
    wire [31:0] imm_out;
    wire [5:0]  op_out;
    wire [5:0]  fn_out;

    // =============================
    // DUT 연결
    // =============================
    Reg_TOP dut (
        .clk(clk),
        .reset(reset),
        .IRWrite(IRWrite),
        .instr_in(instr_in),
        .data_in(data_in),
        .alu_out(alu_out),
        .DRegSel0(DRegSel0),
        .DRegSel1(DRegSel1),
        .RegDst(RegDst),
        .RegInSrc(RegInSrc),
        .RegWrite(RegWrite),
        .rs_data_out(rs_data_out),
        .rt_data_out(rt_data_out),
        .jta_out(jta_out),
        .imm_out(imm_out),
        .op_out(op_out),
        .fn_out(fn_out)
    );

    // =============================
    // Clock 생성
    // =============================
    initial clk = 0;
    always #5 clk = ~clk;

    // =============================
    // Testbench 시작
    // =============================
    initial begin
        $display("\n===== Reg_TOP TEST START =====");

        // 초기값
        reset = 1;
        IRWrite = 0;
        instr_in = 0;
        data_in = 0;
        alu_out = 0;

        DRegSel0 = 0;
        DRegSel1 = 0;
        RegDst   = 2'b00;
        RegInSrc = 0;
        RegWrite = 0;

        #20 reset = 0;

        // =============================
        // RegFile 초기값 넣기
        // =============================
        $display("\n--- RegFile 초기화 ---");
        dut.u_regfile.regs[0]  = 32'h00000000;
        dut.u_regfile.regs[1]  = 32'h11111111;
        dut.u_regfile.regs[2]  = 32'h22222222;
        dut.u_regfile.regs[3]  = 32'h33333333;
        dut.u_regfile.regs[4]  = 32'h44444444;
        dut.u_regfile.regs[5]  = 32'h55555555; // rs 테스트용
        dut.u_regfile.regs[6]  = 32'h66666666;
        dut.u_regfile.regs[7]  = 32'h77777777; // rt 테스트용
        dut.u_regfile.regs[10] = 32'hAAAAAAAA;
        dut.u_regfile.regs[12] = 32'hBBBBBBBB;

        #10;

        // =============================
        // TEST 1: IR load 테스트
        // instr = op(6) rs(5) rt(5) rd(5) shamt(5) funct(6)
        // =============================
        $display("\n--- TEST1: IR Write, op/rs/rt/rd/shamt/fn/jta ---");

        instr_in = 32'b000000_00101_00111_01100_00011_100000;
        /*
           op=0
           rs=5
           rt=7
           rd=12
           shamt=3
           funct=32
        */
        IRWrite = 1; #10;
        IRWrite = 0; #10;

        $display("op=%d, rs=%d, rt=%d, rd=%d, shamt=%d, fn=%d",
                 op_out, dut.u_ir.rs, dut.u_ir.rt,
                 dut.u_ir.rd, dut.u_ir.shamt, fn_out);

        // =============================
        // TEST 2: rs_data, rt_data 읽기 테스트
        // =============================
        $display("\n--- TEST2: rs/rt read test ---");

        DRegSel0 = 0; // rs_idx = rs = 5
        DRegSel1 = 0; // rt_idx = rt = 7
        #5;

        $display("RS data = %h (expect 55555555)", rs_data_out);
        $display("RT data = %h (expect 77777777)", rt_data_out);

        // =============================
        // TEST 3: DRegSel0 / DRegSel1 (rs=rd or rt=shamt)
        // =============================
        $display("\n--- TEST3: DRegSel0/DRegSel1 ---");

        DRegSel0 = 1; // rs_idx = rd = 12
        DRegSel1 = 1; // rt_idx = shamt = 3
        #5;

        $display("RS data = %h (expect BBBBBBBB)", rs_data_out);
        $display("RT data = %h (expect 33333333)", rt_data_out);

        // =============================
        // TEST 4: imm sign extension
        // imm = instr[15:0] = 16'b0000_0000_1010_1010 (0x00AA)
        // =============================
        $display("\n--- TEST4: IMM sign extension ---");

        instr_in = 32'b100011_00000_00000_0000000010101010; // op=35( LW )
        IRWrite = 1; #10; IRWrite = 0;

        $display("IMM out = %h (expect 0000_0000_0000_00AA)", imm_out);

        // =============================
        // TEST 5: RegWrite + RegDst 확인
        // RegDst = 00 → rt
        // =============================
        $display("\n--- TEST5: RegWrite to RT ---");
        instr_in = 32'b100011_01000_10001_01011_00010_101010; // op=35( LW )
        IRWrite = 1; data_in = 32'hDEADBEEF; #10; IRWrite = 0;
        
        alu_out = 32'hDEAD0001;
        RegInSrc = 0;
        RegDst = 2'b00; // write_idx = rt
        RegWrite = 1;

        #10;
        RegWrite = 0;

        $display("Written rt register (%0d) = %h",
                 dut.u_ir.rt,
                 dut.u_regfile.regs[dut.u_ir.rt]);

        // =============================
        // TEST 6: RegDst = 01 → rd
        // =============================
        $display("\n--- TEST6: RegWrite to RD ---");

        alu_out = 32'hDEAD0002;
        RegInSrc = 1;
        RegDst = 2'b01; // rd
        RegWrite = 1; #10;
        RegWrite = 0;

        $display("Written rd register (%0d) = %h",
                 dut.u_ir.rd,
                 dut.u_regfile.regs[dut.u_ir.rd]);

        // =============================
        // TEST 7: RegDst = 10 → 31번 레지스터
        // =============================
        $display("\n--- TEST7: RegWrite to R31 ---");

        alu_out = 32'hDEAD0031;
        RegDst = 2'b10;
        RegWrite = 1; #10;
        RegWrite = 0;

        $display("R31 = %h", dut.u_regfile.regs[31]);

        // =============================
        // TEST 8: RegDst = 11 → shamt 위치 레지스터
        // shamt = 2
        // =============================
        $display("\n--- TEST8: RegWrite to shamt index ---");

        alu_out = 32'hDEAD0003;
        RegDst = 2'b11;
        RegWrite = 1; #10;
        RegWrite = 0;

        $display("R[shamt=%0d] = %h",
                 dut.u_ir.shamt,
                 dut.u_regfile.regs[dut.u_ir.shamt]);
        
        // =============================
        // TEST 9: 9번 레지스터의 값 확인
        // shamt = 3
        // =============================
        $display("\n--- TEST9: Recheck rt_data_out ---");
        
        DRegSel0 = 1; // rs_idx = rs = 8
        DRegSel1 = 1; // rt_idx = shamt = 2
        #5;

        $display("RD data = %h", rs_data_out);
        $display("shamt data = %h", rt_data_out);
                 
        // =============================
        // 종료
        // =============================
        $display("\n===== Reg_TOP TEST END =====\n");
        $finish;
    end

endmodule
