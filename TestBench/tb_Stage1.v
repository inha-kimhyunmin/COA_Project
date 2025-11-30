`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/19 22:11:52
// Design Name: 
// Module Name: tb_Stage1
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

module tb_Stage1;

    reg         clk;
    reg         reset;
    reg [21:0]  control;
    reg [31:0]  next_pc;
    reg [31:0]  data_y;     // write_data
    reg [31:0]  data_z;     // z_Reg (= ALUOut)

    wire [31:0] current_pc;
    wire [31:0] instr_data_out;

    // ==========================
    // DUT: Stage1 Instance
    // ==========================
    Stage1 DUT (
        .clk(clk),
        .reset(reset),
        .control(control),
        .next_pc(next_pc),
        .data_y(data_y),
        .data_z(data_z),

        .current_pc(current_pc),
        .instr_data_out(instr_data_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Control bit mapping
    localparam PCWrite   = 18;
    localparam Inst_Data = 17;
    localparam MemRead   = 16;
    localparam MemWrite  = 15;

    // ==========================
    // Testbench Procedure
    // ==========================
    initial begin
        $display("===== Stage1 Testbench Start =====");

        clk = 0;
        reset = 1;
        control = 0;
        next_pc = 32'h00000000;
        data_y  = 32'h00000000;
        data_z  = 32'h00000000;

        // --- Reset ---
        #12 reset = 0;

        // ==================================================
        // 1) PCWrite=1 -> PC update test
        // ==================================================
        $display("[Test 1] PCWrite=1 -> PC update (time=%0t)", $time);

        next_pc = 32'h00000004;
        control[PCWrite] = 1;

        #10;
        if(current_pc == 32'h00000004)
            $display("PASS: PC correctly updated to %h (time=%0t)", current_pc, $time);
        else
            $display("FAIL: PC incorrect (time=%0t)", $time);

        // ==================================================
        // 2) PCWrite=0 -> PC maintenance test
        // ==================================================
        $display("[Test 2] PCWrite=0 -> PC maintain (time=%0t)", $time);

        next_pc = 32'h00000008;
        control[PCWrite] = 0;

        #10;
        if(current_pc == 32'h00000004)
            $display("PASS: PC hold OK (time=%0t)", $time);
        else
            $display("FAIL: PC changed incorrectly (time=%0t)", $time);

        // ==================================================
        // 3) Inst_Data=0 -> Instruction Fetch (address=PC)
        // ==================================================
        $display("[Test 3] Inst_Data=0 -> Fetch instruction (time=%0t)", $time);

        control[Inst_Data] = 0;
        control[MemRead]   = 1;
        control[MemWrite]  = 0;

        #10;
        $display("Fetch Instr Data: %h(time=%0t)", instr_data_out, $time);

        // ==================================================
        // 4) Inst_Data=1 -> Data Access (address=data_z)
        // ==================================================
        $display("[Test 4] Inst_Data=1 -> Use data_z as address (time=%0t)", $time);

        data_z = 32'h00000010;   // 주소 0x10
        control[Inst_Data] = 1;

        #10;
        $display("Data Access Out: %h (time=%0t)", instr_data_out, $time);

        // ==================================================
        // 5) MemWrite test (SW scenario)
        // ==================================================
        $display("[Test 5] MemWrite=1 -> Data write to cache (time=%0t)", $time);

        control[MemRead]  = 0;
        control[MemWrite] = 1;
        data_y = 32'hFEEDFACE;   // store value

        #10;

        // read operation to confirm stored value
        control[MemWrite] = 0;
        control[MemRead]  = 1;

        #10;
        $display("Read After SW: %h (time=%0t)", instr_data_out, $time);

        $display("===== Stage1 Testbench End ===== (time=%0t)", $time);
        $finish;
    end

endmodule