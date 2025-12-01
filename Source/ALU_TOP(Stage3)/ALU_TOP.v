`timescale 1ns / 1ps

module ALU_TOP(
    input clk,
    input reset,
    input [5:0] op,
    input [5:0] fn,

    // x mux
    input  [31:0] pc_in, // 0
    input  [31:0] z_in, // 2
    
    // y mux
    // input               // 0, add 4 !!
    input  [31:0] imm_in, // 2 ~ 4
    
    input  [31:0] x_in,      // X 레지스터에 넣을 데이터
    input  [31:0] y_in,      // Y 레지스터에 넣을 데이터
    input  [21:0] ctrl_in,
    
    output [31:0] x_out,
    output [31:0] y_out,
    output [31:0] z_out,
    output alu_zero,
    output ovfl,

    // 디버그용 / 결과 확인용
    output [21:0]  ctrl_dbg,
    output [31:0]  alu_logic_dbg,
    output [31:0]  alu_shift_dbg,
    output [31:0]  alu_arith_dbg,
    
    output [31:0] x_mux_out_dbg,
    output [31:0] y_mux_out_dbg
    );
    
    // reg
    wire [31:0] x_in_w;
    wire [31:0] y_in_w;
    wire [31:0] x_reg_w;
    wire [31:0] y_reg_w;
    
    // ALU 외부
    wire [31:0] x_data_w;        // x_mux 0
    wire [31:0] pc_data_w;        // x_mux 1
    wire [31:0] z_data_w;        // x_mux 2
    
    wire [31:0] x_mux_w;
    
    wire [31:0] four_data_w;     // y_mux 0
    wire [31:0] y_data_w;        // y_mux 1
    wire [31:0] imm_data_w;     // y_mux 2
    wire [31:0] offset_data_w;  // y_mux 3
    
    wire [31:0] y_mux_w;
    
    // ALU 내부
    wire [31:0] alu_logic_w;     // alu_logic_unit 출력
    wire [31:0] alu_shift_w;     //
    wire [31:0] alu_arith_w;     //
    
    wire [31:0] alu_w;
    wire [3:0] fn_code_w;

    wire [1:0] ALUSRCX;
    wire [1:0] ALUSRCY;
    wire [1:0] LOGICFN;
    wire [1:0] FNTYPE;
    wire ADDSUB;
    
    // ALU 내부
    assign ALUSRCX = ctrl_in[7:6];
    assign ALUSRCY = ctrl_in[5:4];
    assign LOGICFN = ctrl_in[3:2];
    assign FNTYPE  = ctrl_in[1:0];
    assign ADDSUB  = ctrl_in[2];
    
    // ALU 외부
    assign x_data_w   = x_reg_w;
    assign x_out = x_reg_w;
    assign y_out = y_reg_w;
    assign pc_data_w  = pc_in;
    assign z_data_w   = z_in;
    // assign fn_code_w   = fn[5:2];

    assign four_data_w   = 32'd4;
    // assign y_data_w      = y_reg_w;
    assign imm_data_w    = imm_in;
    assign offset_data_w = {imm_in[29:0], 2'b00};  // imm << 2 
    
    // ALU zero
    // wire alu_zero_w = alu_zero;
    // wire ovfl_w = ovfl;

    // 디버그 출력
    assign ctrl_dbg      = ctrl_in;
    assign alu_logic_dbg = alu_logic_w;
    assign alu_shift_dbg = alu_shift_w;
    assign alu_arith_dbg = alu_arith_w;

    
    reg [31:0] x_mux_r;
    always @* begin
        case (ALUSRCX)
            2'b00: x_mux_r = pc_data_w;  // X 레지스터
            2'b01: x_mux_r = x_data_w; // PC
            2'b10: x_mux_r = z_data_w;  // 이전 ALU 결과
            default: x_mux_r = 32'd0;
        endcase
    end
    assign x_mux_w = x_mux_r;
    
    reg [31:0] y_mux_r;
    always @(*) begin
        case (ALUSRCY)
            2'b00: y_mux_r = four_data_w;    // 상수 4 (PC+4, branch 등)
            2'b01: y_mux_r = y_reg_w;       // Y 레지스터
            2'b10: y_mux_r = imm_data_w;     // 즉시값
            2'b11: y_mux_r = offset_data_w;  // 브랜치 오프셋 (imm << 2)
            default: y_mux_r = 32'd0;
        endcase
    end
    assign y_mux_w = y_mux_r;
    
    reg [31:0] alu_mux_r;
    always @(*) begin
        case (FNTYPE)
            2'b00: alu_mux_r = alu_arith_w;    // 
            2'b01: alu_mux_r = alu_logic_w;       // 
            2'b10: alu_mux_r = alu_shift_w;     // 
            default: alu_mux_r = 32'd0;
        endcase
    end
    assign alu_w = alu_mux_r;
    
    // ALU 결과 z_out : 먹스로 구현
    assign z_out = alu_w;
    
    assign x_mux_out_dbg = x_mux_w;
    assign y_mux_out_dbg = y_mux_w;
    
    x_reg u_x_reg (
        .clk      (clk),
        .rst      (reset),
        .in_data  (x_in),
        .out_data (x_reg_w)
    );

    y_reg u_y_reg (
        .clk      (clk),
        .rst      (reset),
        .in_data  (y_in),
        .out_data (y_reg_w)
    );

    alu_logic_unit u_alu_logic (
        .in_x_data     (x_mux_w),
        .in_y_data     (y_mux_w),
        .logic_fn      (LOGICFN),
        .out_logic_data(alu_logic_w)
    );
    
    barrel_shifter u_barrel_shifter(
        .fn(fn),
        .in_data(x_mux_w),   // shift 대상
        .shamt_32(y_mux_w),     // shift amount
        .ALUFunc(LOGICFN),      // 00=ROT, 01=SRL, 10=SLL, 11=SRA
        .out_data(alu_shift_w)
    );
    
    Adder_32 u_Adder_32(
        .a(x_mux_w),
        .b_pre(y_mux_w),
        .cin(ADDSUB),
        .sum(alu_arith_w),
        .cout(),
        .zero(alu_zero),
        .ovf(ovfl)
    );

endmodule
