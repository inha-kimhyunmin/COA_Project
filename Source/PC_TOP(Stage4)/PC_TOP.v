`timescale 1ns / 1ps

module PC_TOP(
    input clk,
    input reset,
    
    input  [31:0] alu_out,
    input  [31:0] x_reg_out,
    input  [25:0] jta,
    input  [31:0] pc, // 이걸 사용하는 순간엔 pc+4 의 값임
    input  [29:0] syscall,
    input  [21:0] ctrl_in,
    
    output [31:0] pc_src,
    output [31:0] z_reg_out
    );
    
    // ctrl bit
    wire JUMPADDR;
    wire [1:0] PCSRC;
    
    assign JUMPADDR = ctrl_in[21];
    assign PCSRC = ctrl_in[20:19];
    
    // wire
    wire [29:0] real_jump_addr_w = { pc[31:28], jta };
    wire [31:0] x_reg_out_w;
    wire [31:0] z_reg_out_w;
    wire [31:0] alu_out_w;
    
    assign x_reg_out_w = x_reg_out;
    assign alu_out_w = alu_out;
    assign z_reg_out = z_reg_out_w;
    
    // z_reg
    z_reg u_z_reg (
        .clk      (clk),
        .rst      (reset),
        .in_data  (alu_out),
        .out_data (z_reg_out_w)
    );
    
    // jump_addr_mux
    reg [29:0] jump_addr_mux_r;
    wire [29:0] jumpaddr_mux_out_w;
    always @(*) begin
        case (JUMPADDR)
            1'b0: jump_addr_mux_r = real_jump_addr_w;
            1'b1: jump_addr_mux_r = syscall;
            default: jump_addr_mux_r = 30'd0;
        endcase
    end
    assign jumpaddr_mux_out_w = jump_addr_mux_r;
    
    // pc_src_mux
    wire [31:0] jump32_w = { jumpaddr_mux_out_w, 2'b00 };
    reg [31:0] z_mux_r;
    always @(*) begin
        case (PCSRC)
            2'b00: z_mux_r = jump32_w;
            2'b01: z_mux_r = x_reg_out_w;
            2'b10: z_mux_r = z_reg_out_w;
            2'b11: z_mux_r = alu_out_w;
            default: z_mux_r = 32'd0;
        endcase
    end
    assign pc_src = z_mux_r;
    
endmodule
