module Reg_TOP (
    input        clk,
    input        reset,

    // === IR 입력 ===
    // input        IRWrite,
    input [31:0] instr_in,

    // === Data Reg 입력 ===
    input [31:0] data_in,

    // === ALUOut 입력 ===
    input [31:0] alu_out,

    // === Control Signal ===
    input  [21:0] ctrl_in,
    
    // input        DRegSel0,    // 0=rs, 1=rd
    // input        DRegSel1,    // 0=rt, 1=imm[4:0]
    // input  [1:0] RegDst,      // 00=rt, 01=rd, 10=31, 11=imm[4:0]
    // input        RegInSrc,    // 0=data_reg_out, 1=alu_out
    // input        RegWrite,

    // === 최종 출력 ===
    output [31:0] rs_data_out,
    output [31:0] rt_data_out,
    output [25:0] jta_out,
    output [31:0] imm_out,
    
    output [5:0] op_out,
    output [5:0] fn_out
);

    wire IRWrite;
    wire DRegSel0;
    wire DRegSel1;
    wire [1:0] RegDst;
    wire RegInSrc;
    wire RegWrite;
    
    assign IRWrite = ctrl_in[14];
    assign DRegSel0 = ctrl_in[8];
    assign DRegSel1 = ctrl_in[9];
    assign RegDst = ctrl_in[12:11];
    assign RegInSrc  = ctrl_in[10];
    assign RegWrite  = ctrl_in[13];


    // ============================
    //     1. Instruction Register
    // ============================
    wire [5:0]  op, funct;
    wire [4:0]  rs, rt, rd, shamt;
    wire [15:0] imm;
    wire [25:0] jta;
    
    instr_reg u_ir (
        .clk(clk),
        .reset(reset),
        .IRWrite(IRWrite),
        .instr_in(instr_in),

        .op(op_out),
        .rs(rs),
        .rt(rt),
        .rd(rd),
        .shamt(shamt),
        .funct(fn_out),
        .imm(imm),
        .jta(jta)
    );
    
    assign imm_out = {{16{imm[15]}}, imm};
    // assign op_out = op;
    // assign fn_out = funct;
    assign jta_out = jta;

    // ============================
    //     2. Data Register
    // ============================
    wire [31:0] data_reg_out;

    Data_reg u_data (
        .clk(clk),
        .rst(reset),
        .in_data(data_in),
        .out_data(data_reg_out)
    );

    // ============================
    //     3. RegFile MUX logic
    // ============================

    // rs select: 0=rs, 1=rd
    wire [4:0] rs_idx = (DRegSel0 == 1'b0) ? rs : rd;

    // rt select: 0=rt, 1=ri(=shamt)
    wire [4:0] rt_idx = (DRegSel1 == 1'b0) ? rt : shamt;

    // write_idx select
    reg [4:0] write_idx;
    always @(*) begin
        case (RegDst)
            2'b00: write_idx = rt;
            2'b01: write_idx = rd;
            2'b10: write_idx = 5'd31;
            2'b11: write_idx = shamt;
        endcase
    end

    // write_data: 0=data_reg_out, 1=alu_out
    wire [31:0] write_data = (RegInSrc == 1'b0) ? data_reg_out : alu_out;

    // ============================
    //     4. Register File
    // ============================
    wire [31:0] rs_data, rt_data;

    reg_file u_regfile (
        .clk(clk),
        .rst(reset),

        .rs_idx(rs_idx),
        .rt_idx(rt_idx),
        .write_idx(write_idx),

        .RegWrite(RegWrite),
        .write_data(write_data),

        .rs_data(rs_data),
        .rt_data(rt_data)
    );

    assign rs_data_out = rs_data;
    assign rt_data_out = rt_data;

endmodule
