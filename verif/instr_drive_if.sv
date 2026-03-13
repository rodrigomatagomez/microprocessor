interface instr_drive_if #(int DATA_W = 32) (input logic clk);

  // ---------------------------------------------
  // Signals driven into the DUT
  // ---------------------------------------------
  logic              instr_en;
  logic [DATA_W-1:0] driven_instr;

  // ---------------------------------------------
  // Driver modport (direct access)
  // ---------------------------------------------
  modport driver (
    input  clk,
    output instr_en,
    output driven_instr
  );

  // -----------------------------
  // RV32I opcodes
  // -----------------------------
  localparam logic [6:0] OPCODE_R     = 7'b0110011;
  localparam logic [6:0] OPCODE_I     = 7'b0010011;
  localparam logic [6:0] OPCODE_L     = 7'b0000011;
  localparam logic [6:0] OPCODE_S     = 7'b0100011;
  localparam logic [6:0] OPCODE_B     = 7'b1100011;
  localparam logic [6:0] OPCODE_LUI   = 7'b0110111;
  localparam logic [6:0] OPCODE_AUIPC = 7'b0010111;
  localparam logic [6:0] OPCODE_JAL   = 7'b1101111;

  // funct3 constants
  localparam logic [2:0] F3_ADD_SUB_MUL = 3'b000;
  localparam logic [2:0] F3_SLL         = 3'b001;
  localparam logic [2:0] F3_SLT         = 3'b010;
  localparam logic [2:0] F3_SLTU        = 3'b011;
  localparam logic [2:0] F3_XOR         = 3'b100;
  localparam logic [2:0] F3_SRL_SRA     = 3'b101;
  localparam logic [2:0] F3_OR          = 3'b110;
  localparam logic [2:0] F3_AND         = 3'b111;
  localparam logic [2:0] F3_MULH        = 3'b001;

  localparam logic [2:0] F3_BEQ  = 3'b000;
  localparam logic [2:0] F3_BNE  = 3'b001;
  localparam logic [2:0] F3_BLT  = 3'b100;
  localparam logic [2:0] F3_BGE  = 3'b101;
  localparam logic [2:0] F3_BLTU = 3'b110;
  localparam logic [2:0] F3_BGEU = 3'b111;

  localparam logic [2:0] F3_LB  = 3'b000;
  localparam logic [2:0] F3_LH  = 3'b001;
  localparam logic [2:0] F3_LW  = 3'b010;
  localparam logic [2:0] F3_LBU = 3'b100;
  localparam logic [2:0] F3_LHU = 3'b101;

  localparam logic [2:0] F3_SB  = 3'b000;
  localparam logic [2:0] F3_SH  = 3'b001;
  localparam logic [2:0] F3_SW  = 3'b010;

  // funct7 constants
  localparam logic [6:0] F7_BASE = 7'b0000_000;
  localparam logic [6:0] F7_SUB  = 7'b0100_000;
  localparam logic [6:0] F7_SRA  = 7'b0100_000;
  localparam logic [6:0] F7_MUL  = 7'b0000_001;

  // -----------------------------
  // Build instruction from randomized item
  // NOTE: This assumes riscv32_rand_instruction and riscv32_kind_enum exist.
  // -----------------------------
  function automatic logic [31:0] build_instr(input riscv32_rand_instruction it);
    logic [31:0] instr;
    instr = 32'h0000_0013; // default NOP

    case (it.kind)

      // NOP (encoded as ADDI x0,x0,0)
      M_NOP: begin
        instr = 32'h0000_0013;
      end

      // -------------------------
      // I-type ALU
      // -------------------------
      I_ADDI: begin
        instr[31:20] = it.imm_i[11:0];
        instr[19:15] = it.rs1;
        instr[14:12] = 3'b000;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_I;
      end

      I_SLTI: begin
        instr[31:20] = it.imm_i[11:0];
        instr[19:15] = it.rs1;
        instr[14:12] = 3'b010;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_I;
      end

      I_SLTIU: begin
        instr[31:20] = it.imm_i[11:0];
        instr[19:15] = it.rs1;
        instr[14:12] = 3'b011;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_I;
      end

      I_XORI: begin
        instr[31:20] = it.imm_i[11:0];
        instr[19:15] = it.rs1;
        instr[14:12] = 3'b100;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_I;
      end

      I_ORI: begin
        instr[31:20] = it.imm_i[11:0];
        instr[19:15] = it.rs1;
        instr[14:12] = 3'b110;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_I;
      end

      I_ANDI: begin
        instr[31:20] = it.imm_i[11:0];
        instr[19:15] = it.rs1;
        instr[14:12] = 3'b111;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_I;
      end

      // -------------------------
      // R-type ALU
      // -------------------------
      R_ADD: begin
        instr[31:25] = F7_BASE;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_ADD_SUB_MUL;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_SUB: begin
        instr[31:25] = F7_SUB;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_ADD_SUB_MUL;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_MUL: begin
        instr[31:25] = F7_MUL;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_ADD_SUB_MUL;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_MULH: begin
        instr[31:25] = F7_MUL;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_MULH;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_SLL: begin
        instr[31:25] = F7_BASE;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_SLL;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_SLT: begin
        instr[31:25] = F7_BASE;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_SLT;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_SLTU: begin
        instr[31:25] = F7_BASE;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_SLTU;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_XOR: begin
        instr[31:25] = F7_BASE;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_XOR;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_SRL: begin
        instr[31:25] = F7_BASE;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_SRL_SRA;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_SRA: begin
        instr[31:25] = F7_SRA;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_SRL_SRA;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_OR: begin
        instr[31:25] = F7_BASE;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_OR;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      R_AND: begin
        instr[31:25] = F7_BASE;
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[14:12] = F3_AND;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_R;
      end

      // -------------------------
      // Loads
      // -------------------------
      L_LB, L_LH, L_LW, L_LBU, L_LHU: begin
        instr[31:20] = it.imm_i[11:0];
        instr[19:15] = it.rs1;
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_L;

        unique case (it.kind)
          L_LB:  instr[14:12] = F3_LB;
          L_LH:  instr[14:12] = F3_LH;
          L_LW:  instr[14:12] = F3_LW;
          L_LBU: instr[14:12] = F3_LBU;
          L_LHU: instr[14:12] = F3_LHU;
          default: instr[14:12] = F3_LW;
        endcase
      end

      // -------------------------
      // Stores
      // -------------------------
      S_SB, S_SH, S_SW: begin
        instr[31:25] = it.imm_s[11:5];
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[11:7]  = it.imm_s[4:0];
        instr[6:0]   = OPCODE_S;

        unique case (it.kind)
          S_SB: instr[14:12] = F3_SB;
          S_SH: instr[14:12] = F3_SH;
          S_SW: instr[14:12] = F3_SW;
          default: instr[14:12] = F3_SW;
        endcase
      end

      // -------------------------
      // Branches (B-type immediate bit placement)
      // imm_b[12|10:5|4:1|11] with bit0 = 0
      // -------------------------
      B_BEQ, B_BNE, B_BLT, B_BGE, B_BLTU, B_BGEU: begin
        instr[31]    = it.imm_b[12];
        instr[30:25] = it.imm_b[10:5];
        instr[24:20] = it.rs2;
        instr[19:15] = it.rs1;
        instr[11:8]  = it.imm_b[4:1];
        instr[7]     = it.imm_b[11];
        instr[6:0]   = OPCODE_B;

        unique case (it.kind)
          B_BEQ:  instr[14:12] = F3_BEQ;
          B_BNE:  instr[14:12] = F3_BNE;
          B_BLT:  instr[14:12] = F3_BLT;
          B_BGE:  instr[14:12] = F3_BGE;
          B_BLTU: instr[14:12] = F3_BLTU;
          B_BGEU: instr[14:12] = F3_BGEU;
          default: instr[14:12] = F3_BEQ;
        endcase
      end

      // -------------------------
      // U-type (LUI/AUIPC)
      // -------------------------
      U_LUI: begin
        instr[31:12] = it.imm_u[19:0];
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_LUI;
      end

      U_AUIPC: begin
        instr[31:12] = it.imm_u[19:0];
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_AUIPC;
      end

      // -------------------------
      // J-type (JAL)
      // -------------------------
      J_JAL: begin
        instr[31]    = it.imm_j[20];
        instr[30:21] = it.imm_j[10:1];
        instr[20]    = it.imm_j[11];
        instr[19:12] = it.imm_j[19:12];
        instr[11:7]  = it.rd;
        instr[6:0]   = OPCODE_JAL;
      end

      default: instr = 32'h0000_0013;
    endcase

    return instr;
  endfunction

  // -------------------------------------------------------
  // Illegal instruction generator
  // -------------------------------------------------------
  function automatic logic [31:0] build_illegal_instr();
    logic [31:0] instr;
    logic [6:0]  bad_opcode;

    // Choose an opcode that is not in the legal set
    bad_opcode = 7'b1111111;

    instr = 32'h0;
    instr[6:0] = bad_opcode;

    // Fill other fields arbitrarily
    instr[11:7]  = 5'd7;     // rd
    instr[19:15] = 5'd1;     // rs1
    instr[24:20] = 5'd2;     // rs2
    instr[31:25] = 7'h55;
    instr[14:12] = 3'b101;

    return instr;
  endfunction

  // -------------------------------------------------------
  // Drive one instruction for one cycle (posedge-to-posedge)
  // -------------------------------------------------------
  task automatic drive_raw(input logic [31:0] instr);
    // Drive at posedge (DUT will see it for the next posedge sample)
    @(posedge clk);
    instr_en     = 1'b1;
    driven_instr = instr;

    // Deassert enable next cycle
    @(posedge clk);
    instr_en     = 1'b0;
    driven_instr = 32'h0000_0013; // keep NOP on bus when idle
  endtask

  task automatic drive_item(input riscv32_rand_instruction it);
    drive_raw(build_instr(it));
  endtask

  // -----------------------------------------
  // Directed sweep: generate all legal kinds
  // -----------------------------------------
  task automatic drive_all_legal_once();
    riscv32_rand_instruction it;

    riscv32_kind_enum legal_kinds[$] = '{
      M_NOP,
      I_ADDI, U_LUI, U_AUIPC, J_JAL,
      B_BEQ, B_BNE, B_BLT, B_BGE, B_BLTU, B_BGEU,
      L_LB, L_LH, L_LW, L_LBU, L_LHU,
      S_SB, S_SH, S_SW,
      I_SLTI, I_SLTIU, I_XORI, I_ORI, I_ANDI,
      R_ADD, R_SUB, R_MUL, R_MULH, R_SLL, R_SLT, R_SLTU, R_XOR, R_SRL, R_SRA, R_OR, R_AND
    };

    foreach (legal_kinds[i]) begin
      it = new();
      it.set_kind_directed(legal_kinds[i]);
      drive_item(it);
    end
  endtask

  // -------------------------------------------------------
  // Drive illegal instruction test
  // -------------------------------------------------------
  task automatic drive_illegal_nop_test(input int unsigned n);
    logic [31:0] illegal_instr;
    for (int unsigned k = 0; k < n; k++) begin
      illegal_instr = build_illegal_instr();
      drive_raw(illegal_instr);
    end
  endtask

endinterface
