`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/18 21:21:56
// Design Name: 
// Module Name: tb_Controller_FSM
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


module tb_Controller_FSM;

  reg        clk;
  reg        reset;
  reg  [5:0] op_in;
  reg  [5:0] funct_in;
  wire [3:0] state;

  // DUT
  Controller_FSM dut (
    .clk(clk),
    .reset(reset),
    .op_in(op_in),
    .funct_in(funct_in),
    .state(state)
  );

  // 클럭 10ns
  initial clk = 1'b0;
  always #5 clk = ~clk;

  // 유틸
  task step; begin @(posedge clk); #1; end endtask
  task wait_S0; begin while (state !== 4'd0) step(); end endtask

  task show(input [200*8:0] tag);
    begin
      $display("%0t ns | %-20s | state=%0d op=%b funct=%b",
               $time, tag, state, op_in, funct_in);
    end
  endtask

  // S0에서만 명령 갱신하는 헬퍼
  task issue_instr(input [5:0] op, input [5:0] fn, input [200*8:0] name);
    begin
      wait_S0;                 // 반드시 S0(페치) 때만 변경
      op_in    = op;
      funct_in = fn;
      show({ "ISSUE ", name });
      step();                  // S0->S1
    end
  endtask

  // 시나리오
  initial begin
    $dumpfile("Controller_FSM.vcd"); $dumpvars(0, tb_Controller_FSM);

    // 초기화
    reset=1; op_in=0; funct_in=0; show("RESET");
    repeat(2) step(); reset=0; show("RELEASE");

    // 1) LW: S1->S2->S3->S4->S0
    issue_instr(6'b100011, 6'd0, "LW");
    step(); // S1
    step(); // S2
    step(); // S3
    step(); // S4
    // S0로 복귀될 때까지 자동 진행
    wait_S0; show("LW DONE");

    // 2) SW: S1->S2->S6->S0
    issue_instr(6'b101011, 6'd0, "SW");
    step(); // S1
    step(); // S2
    step(); // S6
    wait_S0; show("SW DONE");

    // 3) BEQ: S1->S5->S0
    issue_instr(6'b000100, 6'd0, "BEQ");
    step(); // S1
    step(); // S5
    wait_S0; show("BEQ DONE");

    // 4) J: S1->S5->S0 (다이어그램상 S5에서 처리)
    issue_instr(6'b000010, 6'd0, "J");
    step(); // S1
    step(); // S5
    wait_S0; show("J DONE");

    // 5) 일반 R-type: S1->S7->S8->S0 (funct가 SL/SR/DXOR이 아니어야 함)
    issue_instr(6'b000000, 6'b100000, "R-ADD(general)");
    step(); // S1
    step(); // S7
    step(); // S8
    wait_S0; show("R(general) DONE");

    // 6) SLXOR: S1->S7->S9->S8->S0
    issue_instr(6'b000000, 6'b111001, "SLXOR"); // 파라미터와 동일
    step(); // S1
    step(); // S7
    step(); // S9
    step(); // S8
    wait_S0; show("SLXOR DONE");

    // 7) SRXOR: S1->S7->S9->S8->S0
    issue_instr(6'b000000, 6'b111010, "SRXOR");
    step(); // S1
    step(); // S7
    step(); // S9
    step(); // S8
    wait_S0; show("SRXOR DONE");

    // 8) DXOR: S1->S10->S11->S12->S0
    issue_instr(6'b000000, 6'b111011, "DXOR");
    step(); // S1
    step(); // S10
    step(); // S11
    step(); // S12
    wait_S0; show("DXOR DONE");

    repeat(4) step();
    $display("=== TEST COMPLETE ===");
    $finish;
  end
endmodule