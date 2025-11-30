`timescale 1ns / 1ps

module ALU_PC4_TB;

    reg clk;
    reg reset;

    reg [31:0] pc_in;
    reg [31:0] z_in;
    reg [31:0] imm_in;
    reg [31:0] x_in;
    reg [31:0] y_in;
    reg [21:0] ctrl_in;

    wire [31:0] z_out;
    wire alu_zero, ovfl;
    wire [21:0] ctrl_dbg;
    wire [31:0] alu_logic_dbg, alu_shift_dbg, alu_arith_dbg;

    // ALU_TOP 인스턴스
    ALU_TOP alu(
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .z_in(z_in),
        .imm_in(imm_in),
        .x_in(x_in),
        .y_in(y_in),
        .ctrl_in(ctrl_in),
        .x_out(),
        .y_out(),
        .z_out(z_out),
        .alu_zero(alu_zero),
        .ovfl(ovfl),
        .ctrl_dbg(ctrl_dbg),
        .alu_logic_dbg(alu_logic_dbg),
        .alu_shift_dbg(alu_shift_dbg),
        .alu_arith_dbg(alu_arith_dbg)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk; // 10ns 주기

    initial begin
        reset = 1;
        pc_in = 0;
        z_in  = 0;
        imm_in = 0;
        x_in = 0;
        y_in = 0;

        // Control 세팅: x_mux=PC, y_mux=4, FNTYPE=Arithmetic, ADDSUB=0
        ctrl_in = 22'd0;
        ctrl_in[7:6] = 2'b01; // ALUSRCX = PC
        ctrl_in[5:4] = 2'b00; // ALUSRCY = 4
        ctrl_in[1:0] = 2'b00; // FNTYPE = Arithmetic
        ctrl_in[2]   = 1'b0;  // ADDSUB = 0 (Add)

        #10;
        reset = 0;

        // 10 클록 동안 PC+4 확인
        $display("Time\tPC_in\t\tZ_out(PC+4)");
        repeat (10) begin
            @(posedge clk);
            $display("%0t\t%d\t%d", $time, pc_in, z_out);
            pc_in = z_out; // 다음 클록에 PC 갱신
        end

        $finish;
    end

endmodule
