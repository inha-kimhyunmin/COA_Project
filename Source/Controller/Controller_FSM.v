`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/11/18 21:18:49
// Design Name: 
// Module Name: Controller_FSM
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


module Controller_FSM(
    input        clk,
    input        reset,
    input  [5:0] op_in,
    input  [5:0] funct_in,
    input        alu_zero,
    
    output reg [3:0] state,
    output reg [21:0] ctrl_out,
    
    output [5:0] op_dbg,
    output [5:0] funct_dbg,
    output [21:0]ctrl_dbg
    );
    
  // ?†àÏß??ä§?Ñ∞
  reg [3:0] next_state;
  reg [5:0] op, funct;
  
  // ===== ?ÉÅ?Éú ?†ï?ùò =====
  localparam S0 = 4'd0,  // Fetch
             S1 = 4'd1,  // Decode
             S2 = 4'd2,  // ?†ëÍ∑? Ï£ºÏÜå Í≥ÑÏÇ∞ (LW/SW Í≥µÌÜµ)
             S3 = 4'd3,  // MemRead (LW)
             S4 = 4'd4,  // WriteBack (LW)
             S5 = 4'd5,  // Branch/Jump
             S6 = 4'd6,  // MemWrite (SW)
             S7 = 4'd7,  // ALU-type 1Ï∞? ?ó∞?Ç∞
             S8 = 4'd8,  // ALU-type WB
             S9 = 4'd9,  // SLXOR/SRXOR 2Ï∞? ?ó∞?Ç∞ ?ã®Í≥?
             S10= 4'd10, // DXOR 1
             S11= 4'd11, // DXOR 2
             S12= 4'd12; // DXOR WB
             
  // Opcode field [31:26]
  localparam [5:0]
            // R-type
             OP_RTYPE  = 6'b000000,
            // I-type
             OP_ADDI   = 6'b001000,
             OP_SUBI   = 6'b001001,
             OP_ANDI   = 6'b001100,
             OP_ORI    = 6'b001101,
             OP_XORI   = 6'b001110,
             OP_LW     = 6'b100011,
             OP_SW     = 6'b101011,
             OP_BEQ    = 6'b000100,
             OP_BNE    = 6'b000101,
            // J-type
             OP_J      = 6'b000010,
             OP_JAL    = 6'b000011;

  // Funct field [5:0] (only valid when opcode == OP_RTYPE)
  localparam [5:0]
             F_ADD      = 6'b100000,
             F_SUB      = 6'b100001,
             F_AND      = 6'b100100,
             F_OR       = 6'b100101,
             F_XOR      = 6'b100110,
             F_NOR      = 6'b100111,
             F_ROT      = 6'b000000,
             F_SLL      = 6'b000001,
             F_SRL      = 6'b000010,
             F_SRA      = 6'b000011,
             // 
             F_JR       = 6'b001000,
             F_SYSCALL  = 6'b001100,

  // Custom operations
             F_SLXOR    = 6'b101001,
             F_SRXOR    = 6'b101010,
             F_DXOR     = 6'b110010;
 
  // 22-bit Control Bit Mapping
    localparam integer
             JUMPADDR   = 21,
             PCSRC1     = 20,
             PCSRC0     = 19,
             PCWRITE    = 18,
             INSTDATA   = 17,
             MEMREAD    = 16,
             MEMWRITE   = 15,
             IRWRITE    = 14,
             REGWRITE   = 13,
             REGDST1    = 12,
             REGDST0    = 11,
             REGINSRC   = 10,
             DREGSEL1   = 9,
             DREGSEL0   = 8,
             ALUSRCX1   = 7,
             ALUSRCX0   = 6,
             ALUSRCY1   = 5,
             ALUSRCY0   = 4,
             LOGICFN1   = 3,
             LOGICFN0   = 2,
             FNTYPE1    = 1,
             FNTYPE0    = 0;

localparam
  JumpAddr_JTA = 1'b0, // JumpAddr
  JumpAddr_SCA = 1'b1, // JumpAddr
  PCW_N = 1'b0, // PC Write
  PCW_Y = 1'b1, // PC Write
  ID_PC = 1'b0, // Inst'Data
  ID_Z =1'b1, // Inst'Data
  MR_N = 1'b0, // MemRead
  MR_Y = 1'b1, // MemRead
  MW_N = 1'b0, // MemWrite
  MW_Y = 1'b1, // MemWrite
  IRW_N = 1'b0, // IRWrite
  IRW_Y = 1'b1, // IRWrite
  RW_N = 1'b0, // RegWrite
  RW_Y = 1'b1, // RegWrite
  RIS_DATA = 1'b0, // RegInSrc
  RIS_ALU = 1'b1, // RegInSrc
  DRS0_RS = 1'b0, // DRegSel0
  DRS0_RD = 1'b1, // DRegSel0
  DRS1_RT = 1'b0, // DRegSel1
  DRS1_RI = 1'b1; // DRegSel1
  
localparam [1:0]
  PCS_JTA    = 2'b00, // jta / syscall
  PCS_XR = 2'b01, // x
  PCS_ZR   = 2'b10, // z
  PCS_ALUOUT   = 2'b11, // ALUout
  
  RD_RT = 2'b00, // rt
  RD_RD = 2'b01, // rd
  RD_R31 = 2'b10, // r31
  RD_RI = 2'b11, // ri

  AX_PC = 2'b00, // PC
  AX_XR = 2'b01, // x
  AX_ZR = 2'b10, // z
  
  AY_P4     = 2'b00, // 4
  AY_YR    = 2'b01, // y
  AY_IMM  = 2'b10, // imm
  AY_X4 = 2'b11, // x4
  
  FT_ARITH = 2'b00, // ADD SUB
  FT_LOGIC = 2'b01, // and/or/xor/nor
  FT_SHIFT = 2'b10, // sll/srl/sra/rot
  FT_COMARE  = 2'b11, // ÎπÑÍµê?
  
  LF_0 = 2'b00, // ADD / AND / ROT
  LF_1 = 2'b01, // SUB / OR / SLL
  LF_2 = 2'b10, //     / XOR / SRL
  LF_3 = 2'b11; //     / NOR / SRA
  
  // ===== IR (S0?óê?ÑúÎß? ?ûòÏπ?) =====
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      op    <= 6'd0;
      funct <= 6'd0;
    end else if (state == S0) begin
      op    <= op_in;
      funct <= funct_in;
    end
  end

  // ===== opcode ?îîÏΩîÎìú =====
  wire isR      = (op == OP_RTYPE);
  wire isRArith  = isR && (funct[5:2] == 4'b1000); // ?çß?Öà
  wire isRLogic  = isR && (funct[5:2] == 4'b1001); // ?ÖºÎ¶?
  wire isRShift  = isR && (funct[5:2] == 4'b0000); // ?ù¥?èô
  // wire isRCompare = 
  wire isALUF0 = isR && (funct[1:0] == 2'b00); // + and Rot
  wire isALUF1 = isR && (funct[1:0] == 2'b01); // - or SLL
  wire isALUF2 = isR && (funct[1:0] == 2'b10); //   xor SRL
  wire isALUF3 = isR && (funct[1:0] == 2'b11); //   nor SRA
  // wire isRJump?
  wire isRJump = isR && (funct[5:3] == 3'b001);
  wire isJR = isR && (funct == F_JR);
  wire isSYSCALL = isR && (funct == F_SYSCALL);
  
  wire isADD    = isR && (funct == F_ADD);
  wire isSUB    = isR && (funct == F_SUB);
  wire isAND    = isR && (funct == F_AND);
  wire isOR     = isR && (funct == F_OR);
  wire isXOR    = isR && (funct == F_XOR);
  wire isNOR    = isR && (funct == F_NOR);
  wire isROT    = isR && (funct == F_ROT);
  wire isSLL    = isR && (funct == F_SLL);
  wire isSRL    = isR && (funct == F_SRL);
  wire isSRA    = isR && (funct == F_SRA);
  wire isSLXOR  = isR && (funct == F_SLXOR);
  wire isSRXOR  = isR && (funct == F_SRXOR);
  wire isDXOR   = isR && (funct == F_DXOR);

  wire isIAlu   = (op[5:3] == 3'b001); // ADDI, ANDI, ORI, XORI
  wire isIArith = (op[5:2] == 4'b0010); // ?çß?Öà
  wire isILogic = (op[5:2] == 4'b0011); // ?ÖºÎ¶?
  wire isIALUF0  = (op[1:0] == 2'b00); // + and
  wire isIALUF1  = (op[1:0] == 2'b01); // - or
  wire isIALUF2  = (op[1:0] == 2'b10); //   xor
  // wire isIALUF3  = (op[1:0] == 2'b11); //   nor
  
  wire isADDI   = (op == OP_ADDI);
  wire isSUBI   = (op == OP_SUBI);
  wire isANDI   = (op == OP_ANDI);
  wire isORI    = (op == OP_ORI);
  wire isXORI   = (op == OP_XORI);
  wire isLW     = (op == OP_LW);
  wire isSW     = (op == OP_SW);
  wire isBEQ    = (op == OP_BEQ); // op[5:2] = 4'b0001 Î¨∂Ïúº?†§Î©? Î¨∂ÏùÑ ?àò ?ûà?ùÑ ?ìØ
  wire isBNE    = (op == OP_BNE); // op[5:2] = 4'b0001 Î¨∂Ïúº?†§Î©? Î¨∂ÏùÑ ?àò ?ûà?ùÑ ?ìØ
  
  wire isJ      = (op == OP_J);
  wire isJAL    = (op == OP_JAL);

  // ===== Next-State Logic (IR Í∞íÎßå ?Ç¨?ö©) =====
  always @* begin
    next_state = S0;  // default
    case (state)
      S0: next_state = S1;

      S1: begin
        if      (isDXOR)           next_state = S10; // DXOR
        else if (isLW || isSW)     next_state = S2;  // Ï£ºÏÜå Í≥ÑÏÇ∞
        else if (isBEQ || isBNE || isRJump)     next_state = S5;  // Î∂ÑÍ∏∞/?†ê?îÑ
        else if (isR || isIAlu)    next_state = S7;  // ?ùºÎ∞? ALU-type Î∂ÑÍ∏∞?†ê
        else                       next_state = S0; // Jtype ?? Î∞îÎ°ú 0?úºÎ°? Î∂ÑÍ∏∞
      end

      S2:  next_state = (isLW ? S3 : S6); // S1?óê?Ñú Í≤∞Ï†ï?êú op Í∏∞Ï?
      S3:  next_state = S4;
      S4:  next_state = S0;
      S5:  next_state = S0;
      S6:  next_state = S0;

      S7:  next_state = (isSLXOR || isSRXOR) ? S9 : S8; // SLXOR/SRXORÎß? S9 Í≤ΩÏú†
      S8:  next_state = S0;
      S9:  next_state = S8;

      S10: next_state = S11; // DXOR 1?Üí2?Üí3
      S11: next_state = S12;
      S12: next_state = S0;

      default: next_state = S0;
    endcase
  end
  
//
// --- Control Output ---
always @* begin
  ctrl_out = 22'd0;
  case (state)
    S0: begin
      // ctrl_out[INSTDATA] = INSTDATA_PC;
      ctrl_out[MEMREAD]  = MR_Y;
      // ctrl_out[MEMWRITE]  = MW_N;
      ctrl_out[IRWRITE]  = IRW_Y;
      
      ctrl_out[PCSRC1:PCSRC0] = PCS_ALUOUT;
      ctrl_out[PCWRITE]  = PCW_Y;
      // ctrl_out[ALUSRCX1:ALUSRCX0] = AX_PC;
      // ctrl_out[ALUSRCY1:ALUSRCY0] = AY_P4;
    end

    S1: begin
      // ctrl_out[REGWRITE] = RW_N;
      ctrl_out[IRWRITE]  = IRW_N;
      ctrl_out[ALUSRCY1:ALUSRCY0] = AY_X4;
      
      // J ???ûÖ
      ctrl_out[PCWRITE]  = (isJ || isJAL) ? PCW_Y : PCW_N;
      // JAL
      ctrl_out[REGWRITE]  = (isJAL) ? RW_Y : 1'b0;
      ctrl_out[REGDST1:REGDST0]  = (isJAL) ? RD_R31 : 2'b00;
      ctrl_out[REGINSRC] = (isJAL) ? RIS_ALU : 1'b0;
    end

    S2: begin
      ctrl_out[ALUSRCX1:ALUSRCX0] = AX_XR;
      ctrl_out[ALUSRCY1:ALUSRCY0] = AY_IMM;
      ctrl_out[FNTYPE1:FNTYPE0] = FT_ARITH; // ADD for address calc
    end
      
    S3: begin
      ctrl_out[INSTDATA]  = ID_Z;
      ctrl_out[MEMREAD]  = MR_Y;
    end
    
    S4: begin
      ctrl_out[REGWRITE]  = RW_Y;
    end
    
    S5: begin // ?ó¨Í∏∞Îäî RJump Îß?
      ctrl_out[PCSRC1:PCSRC0] = (isJR) ? PCS_XR : PCS_ZR; // (isJ) ? PCS_JTA :
                                
      ctrl_out[PCWRITE]  = (isJR) ? PCW_Y :
                           (isBEQ) ? alu_zero :
                           (isBNE) ? ~alu_zero : 1'b0;
                           
      ctrl_out[JUMPADDR] = (isSYSCALL) ? JumpAddr_SCA : 1'b0;
    end
    
    S6: begin
      ctrl_out[INSTDATA]  = ID_Z;
      ctrl_out[MEMWRITE]  = MW_Y;
    end
    
    S7: begin
      ctrl_out[ALUSRCX1:ALUSRCX0] = AX_XR;
      ctrl_out[ALUSRCY1:ALUSRCY0] = (isROT || isRArith || isRLogic) ? AY_YR :
                                    (isSLXOR || isSRXOR || isRShift || isIAlu) ? AY_IMM
                                    : 2'b00;
      // rot ?óá?ÇòÍ∞??Ñú ?òº?ûê ÎπºÏïº?ê®
      
      ctrl_out[LOGICFN1:LOGICFN0] = (isALUF1 || isIALUF1) ? LF_1 :
                                  (isALUF2 || isIALUF2) ? LF_2 :
                                  (isALUF3) ? LF_3 :
                                  2'b00;
                                  
      ctrl_out[FNTYPE1:FNTYPE0] = (isRLogic || isILogic) ? FT_LOGIC :
                                  (isSLXOR || isSRXOR || isRShift) ? FT_SHIFT :
                                  2'b00;
                                  
      // ctrl_out[FNTYPE1:FNTYPE0] = (isRLogic) ? FT_LOGIC : (isRShift) ? FT_SHIFT : (isRCompare) ? FT_COMARE : 2'b00;
    end
    
    S8: begin
      ctrl_out[REGWRITE]  = RW_Y;
      ctrl_out[REGDST1:REGDST0]  = (isR) ? RD_RD : (isIAlu) ? RD_RT : 2'b00; // r31 ?†ï?ùò ÎØ∏Íµ¨?òÑ
      ctrl_out[REGINSRC] = RIS_ALU;
    end
    
    S9: begin
      ctrl_out[ALUSRCX1:ALUSRCX0] = AX_ZR;
      ctrl_out[ALUSRCY1:ALUSRCY0] = AY_YR;
      ctrl_out[LOGICFN1:LOGICFN0] = LF_2;
      ctrl_out[FNTYPE1:FNTYPE0] = FT_LOGIC;
    end
    
    S10: begin
      ctrl_out[DREGSEL0] = DRS0_RD;
      ctrl_out[DREGSEL1] = DRS1_RI;
      ctrl_out[ALUSRCX1:ALUSRCX0] = AX_XR;
      ctrl_out[ALUSRCY1:ALUSRCY0] = AY_YR;
      ctrl_out[LOGICFN1:LOGICFN0] = LF_2;
      ctrl_out[FNTYPE1:FNTYPE0] = FT_LOGIC;
    end
    
    S11: begin
      ctrl_out[REGWRITE]  = RW_Y;
      ctrl_out[REGINSRC] = RIS_ALU;
      ctrl_out[ALUSRCX1:ALUSRCX0] = AX_XR;
      ctrl_out[ALUSRCY1:ALUSRCY0] = AY_YR;
      ctrl_out[LOGICFN1:LOGICFN0] = LF_2;
      ctrl_out[FNTYPE1:FNTYPE0] = FT_LOGIC;
    end
    
    S12: begin
      ctrl_out[REGWRITE]  = RW_Y;
      ctrl_out[REGDST1:REGDST0]  = RD_RI;
      ctrl_out[REGINSRC] = RIS_ALU;
    end


  endcase
end
//

  // ===== ?ÉÅ?Éú ?†àÏß??ä§?Ñ∞ =====
  always @(posedge clk or posedge reset) begin
    if (reset)
      state <= S0;
    else
      state <= next_state;
  end
  
 assign op_dbg    = op;
 assign funct_dbg = funct;
 assign ctrl_dbg = ctrl_out;
endmodule