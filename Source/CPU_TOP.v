`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 17:26:08
// Design Name: 
// Module Name: CPU_TOP
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


module CPU_TOP(
    input clk,
    input reset,
    
    // debug outputs (individual)
    output [21:0] dbg_ctrl,
    output [3:0]  dbg_state,
    output [31:0] dbg_pc,
    output [31:0] dbg_pc_next,
    output [31:0] dbg_inst,
    output [31:0] dbg_rs,
    output [31:0] dbg_rt,
    output [31:0] dbg_imm,
    output [31:0] dbg_jta,
    output [5:0]  dbg_op,
    output [5:0]  dbg_fn,
    output [31:0] dbg_x,
    output [31:0] dbg_y,
    output [31:0] dbg_alu_out,
    output [31:0] dbg_z,
    output        dbg_alu_zero,
    
    output [31:0] x_mux_out_dbg,
    output [31:0] y_mux_out_dbg
    );
    
    // ctrl
    wire [21:0] ctrl_w;
    wire [3:0] state_w;
    wire alu_zero_w;
    
    // 1 > 4
    wire [31:0] pc_w; // 현재 pc
    
    // 1 > 2
    wire [31:0] inst_data_w;
    
    // 2 > 3
    wire [31:0] rs_w;
    wire [31:0] rt_w;
    wire [31:0] imm_w;
    
    // 2 > 4
    wire [26:0] jta_w;
    
    // 2 >>
    wire [5:0] op_w;
    wire [5:0] fn_w;
    
    // 3 >
    wire [31:0] x_reg_w;
    wire [31:0] y_reg_w;
    
    // 4 > 1
    wire [31:0] pc_next_w; // 이후 pc
    
    // 4 > 2
    wire [31:0] alu_out_w;
    wire [31:0] z_reg_out_w;
    
    // assign internal wires to outputs
    assign dbg_ctrl = ctrl_w;
    assign dbg_state = state_w;
    assign dbg_pc   = pc_w;
    assign dbg_pc_next   = pc_next_w;
    assign dbg_inst = inst_data_w;
    assign dbg_rs   = rs_w;
    assign dbg_rt   = rt_w;
    assign dbg_imm  = imm_w;
    assign dbg_jta  = jta_w;
    assign dbg_op   = op_w;
    assign dbg_fn   = fn_w;
    assign dbg_x    = x_reg_w;
    assign dbg_y    = y_reg_w;
    assign dbg_alu_out = alu_out_w;
    assign dbg_z    = z_reg_out_w;
    assign dbg_alu_zero = alu_zero_w;
    
    // 1
    Stage1 u_Cache_TOP(
        .clk(clk),
        .reset(reset),
        
        .control(ctrl_w),        
        .next_pc(pc_next_w),           // next PC
        .data_y(y_reg_w),
        .data_z(z_reg_out_w),

        .current_pc(pc_w),        // current PC
        .instr_data_out(inst_data_w)    // instruction(or data) from Cache
    
    );
    
    // 2
    Reg_TOP u_Reg_TOP(
        .clk(clk),
        .reset(reset),

        .instr_in(inst_data_w),// === IR 입력 ===
        .data_in(inst_data_w), // === Data Reg 입력 ===
        .alu_out(z_reg_out_w), // === ALUOut 입력 ===
        .ctrl_in(ctrl_w), // === Control Signal ===
        
        .rs_data_out(rs_w),
        .rt_data_out(rt_w),
        .jta_out(jta_w),
        .imm_out(imm_w),
        .op_out(op_w),
        .fn_out(fn_w)
    );
    
    // 3
    ALU_TOP u_ALU_TOP(
        .clk(clk),
        .reset(reset),
        .op(op_w),
        .fn(fn_w),
        
        .pc_in(pc_w), // 0
        .z_in(z_reg_out_w), // 2
        .imm_in(imm_w), // 2 ~ 4
        .x_in(rs_w),      // X 레지스터에 넣을 데이터
        .y_in(rt_w),      // Y 레지스터에 넣을 데이터
        .ctrl_in(ctrl_w),
        
        .x_out(x_reg_w),
        .y_out(y_reg_w),
        .z_out(alu_out_w),
        .alu_zero(alu_zero_w),
        .ovfl(),  // not use
        .ctrl_dbg(), // not use
        .alu_logic_dbg(), // not use
        .alu_shift_dbg(), // not use
        .alu_arith_dbg(), // not use
        .x_mux_out_dbg(x_mux_out_dbg),
        .y_mux_out_dbg(y_mux_out_dbg)
    );
    
    // 4
    PC_TOP u_PC_TOP(
        .clk(clk),
        .reset(reset),
    
        .alu_out(alu_out_w),
        .x_reg_out(x_reg_w),
        .jta(jta_w),
        .pc(pc_w), // 이걸 사용하는 순간엔 pc+4 의 값임
        .syscall(),  // not use
        .ctrl_in(ctrl_w),
        
        .pc_src(pc_next_w),
        .z_reg_out(z_reg_out_w)
    );
    
    Controller_FSM u_Controller_FSM(
        .clk(clk),
        .reset(reset),
        
        .op_in(op_w),
        .funct_in(fn_w),
        .alu_zero(alu_zero_w),
        
        .state(dbg_state),  // not use
        .ctrl_out(ctrl_w),
        .op_dbg(), // not use
        .funct_dbg(), // not use
        .ctrl_dbg() // not use
    );

endmodule
