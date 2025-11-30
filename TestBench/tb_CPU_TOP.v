`timescale 1ns / 1ps

module tb_CPU_TOP;

    reg clk;
    reg reset;

    // Debug outputs from CPU_TOP
    wire [21:0] dbg_ctrl;
    wire [3:0]  dbg_state;
    wire [31:0] dbg_pc;
    wire [31:0] dbg_pc_next;
    wire [31:0] dbg_inst;
    wire [31:0] dbg_rs;
    wire [31:0] dbg_rt;
    wire [31:0] dbg_imm;
    wire [31:0] dbg_jta;
    wire [5:0]  dbg_op;
    wire [5:0]  dbg_fn;
    wire [31:0] dbg_x;
    wire [31:0] dbg_y;
    wire [31:0] dbg_alu_out;
    wire [31:0] dbg_z;
    wire        dbg_alu_zero;

    // Instantiate CPU_TOP
    CPU_TOP uut (
        .clk(clk),
        .reset(reset),
        .dbg_ctrl(dbg_ctrl),
        .dbg_state(dbg_state),
        .dbg_pc(dbg_pc),
        .dbg_pc_next(dbg_pc_next),
        .dbg_inst(dbg_inst),
        .dbg_rs(dbg_rs),
        .dbg_rt(dbg_rt),
        .dbg_imm(dbg_imm),
        .dbg_jta(dbg_jta),
        .dbg_op(dbg_op),
        .dbg_fn(dbg_fn),
        .dbg_x(dbg_x),
        .dbg_y(dbg_y),
        .dbg_alu_out(dbg_alu_out),
        .dbg_z(dbg_z),
        .dbg_alu_zero(dbg_alu_zero)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Simulation sequence
    initial begin
        $dumpfile("tb_CPU_TOP.vcd");
        $dumpvars(0, tb_CPU_TOP);

        reset = 1;
        #20 reset = 0; // release reset

        // run simulation for sufficient cycles
        #2000 $finish;
    end

    // Monitor key signals
    initial begin
        $display("Time\tPC\tINST\tALU\tCTRL");
        forever @(posedge clk) begin
            $display("%0t\t%h\t%h\t%h\t%b",
                     $time, dbg_pc, dbg_inst, dbg_alu_out, dbg_ctrl);
        end
    end

endmodule
