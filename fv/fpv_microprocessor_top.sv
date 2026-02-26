module fpv_microprocessor_top (
  input logic clk,
  input logic arst_n,
  input logic instr_en, 
  input logic [DATA_WIDTH-1:0] driven_instr
);

`include "property_defines.svh"

logic [31:0] instr;
assign instr  = driven_instr;

logic [6:0] opcode = instr[6:0];
logic [2:0] funct3 = instr[14:12];
logic [6:0] funct7 = instr[31:25];
logic [4:0] rd     = instr[11:7];
logic [4:0] rs1    = instr[19:15];
logic [4:0] rs2    = instr[24:20];

// imm 
logic signed [11:0] imm_i = instr[31:20];
logic signed [11:0] imm_s = {instr[31:25], instr[11:7]};
logic signed [12:0] imm_b = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
logic        [19:0] imm_u = instr[31:12];
logic signed [20:0] imm_j = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};


`ASM(asm, driven_instruction, arst_n |->, instr_en == 1'b1); //Enable dirven instruction instead of instruction_mem
`ASM(asm, no_x0_reg, arst_n |->, (|rd) & (|rs1) & (|rs2));  // {rs1, rs2, rd} ≠ 0 
`ASM(asm, opcode_supported, arst_n |->, 
    (opcode inside {OPCODE_R_TYPE, OPCODE_I_TYPE, OPCODE_L_TYPE, OPCODE_S_TYPE, OPCODE_B_TYPE, OPCODE_U_LUI, OPCODE_U_AUIPC, OPCODE_JAL_TYPE}));  //supported opcodes

`ASM(asm, rtype_legal_pairs,
  (arst_n && (opcode == OPCODE_R_TYPE)) |->,  //supported rtypes
  ({funct7, funct3} inside {
    {7'b0000000, F3_ADD_SUB},  // ADD
    {7'b0100000, F3_ADD_SUB},  // SUB
    {7'b0000000, F3_SLL},
    {7'b0000000, F3_SLT},
    {7'b0000000, F3_SLTU},
    {7'b0000000, F3_XOR},
    {7'b0000000, F3_SRL_SRA},  // SRL
    {7'b0100000, F3_SRL_SRA},  // SRA
    {7'b0000000, F3_OR},
    {7'b0000000, F3_AND}
  })
);

`ASM(asm, funct3_legal_i,
  (arst_n && (opcode == OPCODE_I_TYPE)) |->,
  (funct3 inside {F3_ADD_SUB, F3_SLT, F3_SLTU, F3_XOR, F3_OR, F3_AND}) //supported type i fucnt3
);

`ASM(asm, funct3_legal_b,
  (arst_n && (opcode == OPCODE_B_TYPE)) |->,
  (funct3 inside {F3_BEQ, F3_BNE, F3_BLT, F3_BGE, F3_BLTU, F3_BGEU})  //supported btypes
);

`ASM(asm, funct3_legal_l,
  (arst_n && (opcode == OPCODE_L_TYPE)) |->,
  (funct3 inside {F3_LB, F3_LH, F3_LW, F3_LBU, F3_LHU})  //supported ltypes
);

`ASM(asm, funct3_legal_s,
  (arst_n && (opcode == OPCODE_S_TYPE)) |->,
  (funct3 inside {F3_SB, F3_SH, F3_SW})   //supported stypes
);

`ASM(asm, funct3_u_j_dontcare_zero,
  (arst_n && (opcode inside {OPCODE_U_LUI, OPCODE_U_AUIPC, OPCODE_JAL_TYPE})) |->,  //other instrucctions that dont uses funct3
  (funct3 == 3'b000)
);

`ASM(asm, lw_sw_word_aligned,
  (arst_n && (opcode inside {OPCODE_L_TYPE, OPCODE_S_TYPE}) && (funct3 inside {F3_LW, F3_SW})) |->,
  ((imm_i[1:0] == 2'b00) && (imm_s[1:0] == 2'b00))
);

  // ---------------------------------------------------------------------------
  // ASSERTIONS
  // ---------------------------------------------------------------------------

  //  =============================================================================================================
  //  PC AND PRF
  `AST (it, pc_aligned,
       1'b1 |->, (pc_i.pc_out[1:0] == 2'b00)
  )

  `AST(it, next_instr,
      (opcode inside {OPCODE_R_TYPE, OPCODE_I_TYPE, OPCODE_U_LUI, OPCODE_U_AUIPC, OPCODE_L_TYPE, OPCODE_S_TYPE}) |->,
      (pc_i.pc_in == pc_i.pc_out + 32'd4)
  )

  `AST (it, x0_always_zero,
       1'b1 |->, (prf_i.prf[0] == '0)
  )

  //  ===========================================================================================================
  //  TYPE_I INSTRUCTIONS
  `AST (it, imm_I_type,
       (opcode == OPCODE_I_TYPE) |->, (imm_gen_i.imm_sel == IMM_I)
  )

  `AST(it, prf_we_i_type,
      (opcode == OPCODE_I_TYPE) |->, (prf_i.write_en == 1'b1)
  )

  `AST(it, pc_4_i_type,
      (opcode == OPCODE_I_TYPE) |->, (pc_i.pc_in == pc_i.pc_out + 32'd4)
  )

  // =========================================================
  // I-type: ADDI, SLTI, SLTIU, XORI, ORI, ANDI
  // =========================================================

  `AST(it, addi_result,
    ((opcode == OPCODE_I_TYPE) && (funct_3 == F3_ADD_SUB)) |->,
    (prf_i.write_data == (alu_i.operand1 + alu_i.operand2))
  )

  `AST(it, sltiu_result,
    ((opcode == OPCODE_I_TYPE) && (funct_3 == F3_SLTU)) |->,
    (prf_i.write_data == ((alu_i.operand1 < alu_i.operand2) ? 32'd1 : 32'd0))
  )

  `AST(it, xori_result,
    ((opcode == OPCODE_I_TYPE) && (funct_3 == F3_XOR)) |->,
    (prf_i.write_data == (alu_i.operand1 ^ alu_i.operand2))
  )

  `AST(it, ori_result,
    ((opcode == OPCODE_I_TYPE) && (funct_3 == F3_OR)) |->,
    (prf_i.write_data == (alu_i.operand1 | alu_i.operand2))
  )

  `AST(it, andi_result,
    ((opcode == OPCODE_I_TYPE) && (funct_3 == F3_AND)) |->,
    (prf_i.write_data == (alu_i.operand1 & alu_i.operand2))
  )

  //  ===========================================================
  //  R-type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
  //  ==========================================================

  `AST(it, sub,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_ADD_SUB) && (funct_7 == 7'b0100_000)) |->,
      (prf_i.write_data == (prf_i.read_data1 - prf_i.read_data2))
  )

  `AST(it, add,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_ADD_SUB) && (funct_7 == 7'b0000_000)) |->,
      (prf_i.write_data == (prf_i.read_data1 + prf_i.read_data2))
  )

  `AST(it, sll,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_SLL) && (funct_7 == 7'b0000_000)) |->,
      (prf_i.write_data == (prf_i.read_data1 << prf_i.read_data2[4:0]))
  )

  `AST(it, slt,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_SLT) && (funct_7 == 7'b0000_000)) |->,
      (prf_i.write_data == ($signed(prf_i.read_data1) < $signed(prf_i.read_data2) ? 32'd1 : 32'd0))
  )

  `AST(it, sltu,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_SLTU) && (funct_7 == 7'b0000_000)) |->,
      (prf_i.write_data == (prf_i.read_data1 < prf_i.read_data2 ? 32'd1 : 32'd0))
  )

  `AST(it, xor_,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_XOR) && (funct_7 == 7'b0000_000)) |->,
      (prf_i.write_data == (prf_i.read_data1 ^ prf_i.read_data2))
  )

  `AST(it, srl,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_SRL_SRA) && (funct_7 == 7'b0000_000)) |->,
      (prf_i.write_data == (prf_i.read_data1 >> prf_i.read_data2[4:0]))
  )

  `AST(it, sra,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_SRL_SRA) && (funct_7 == 7'b0100_000)) |->,
      ($signed(prf_i.write_data) == ($signed(prf_i.read_data1) >>> prf_i.read_data2[4:0]))
  )

  `AST(it, or_,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_OR) && (funct_7 == 7'b0000_000)) |->,
      (prf_i.write_data == (prf_i.read_data1 | prf_i.read_data2))
  )

  `AST(it, and_,
      ((opcode == OPCODE_R_TYPE) && (funct_3 == F3_AND) && (funct_7 == 7'b0000_000)) |->,
      (prf_i.write_data == (prf_i.read_data1 & prf_i.read_data2))
  )

  //  ==============================================================================================
  //  JAL (JUMP AND LINK) INSTRUCTION
  //  =============================================================================================
  `AST(it, jal,
      (opcode == OPCODE_JAL_TYPE) |->,
      (pc_i.pc_in == (pc_i.pc_out + alu_i.operand2))
  )

  // ===============================================================================================
  // LUI INSTRUCTION
  // ==============================================================================================
  `AST (it, lui,
       (opcode == OPCODE_U_LUI) |->,
       (prf_i.write_data == (32'd0 + imm_gen_i.imm_out))
  )

  //  =============================================================================================
  //  AUIPC INSTRUCTION
  //  ============================================================================================
  `AST (it, auipc,
       (opcode == OPCODE_U_AUIPC) |->,
       (prf_i.write_data == (pc_i.pc_out + imm_gen_i.imm_out))
  )

  //  =============================================================================================
  //  TYPE B INSTRUCTIONS
  //  ============================================================================================

  `AST(it, b_instr,
      (opcode == OPCODE_B_TYPE) |->,
      ((cu_i.branch_taken) ? (pc_i.pc_in == pc_i.pc_out + imm_gen_i.imm_out)
                           : (pc_i.pc_in == pc_i.pc_out + 32'd4))
  )

  `AST(it, beq,
      ((opcode == OPCODE_B_TYPE) && (funct_3 == F3_BEQ)) |->,
      ((prf_i.read_data1 == prf_i.read_data2) ? (pc_i.pc_in == pc_i.pc_out + imm_gen_i.imm_out)
                                              : (pc_i.pc_in == pc_i.pc_out + 32'd4))
  )

  `AST(it, bne,
      ((opcode == OPCODE_B_TYPE) && (funct_3 == F3_BNE)) |->,
      ((prf_i.read_data1 != prf_i.read_data2) ? (pc_i.pc_in == pc_i.pc_out + imm_gen_i.imm_out)
                                              : (pc_i.pc_in == pc_i.pc_out + 32'd4))
  )

  `AST(it, blt,
      ((opcode == OPCODE_B_TYPE) && (funct_3 == F3_BLT)) |->,
      (($signed(prf_i.read_data1) < $signed(prf_i.read_data2)) ? (pc_i.pc_in == pc_i.pc_out + imm_gen_i.imm_out)
                                                               : (pc_i.pc_in == pc_i.pc_out + 32'd4))
  )

  `AST(it, bge,
      ((opcode == OPCODE_B_TYPE) && (funct_3 == F3_BGE)) |->,
      (($signed(prf_i.read_data1) >= $signed(prf_i.read_data2)) ? (pc_i.pc_in == pc_i.pc_out + imm_gen_i.imm_out)
                                                                : (pc_i.pc_in == pc_i.pc_out + 32'd4))
  )

  `AST(it, bltu,
      ((opcode == OPCODE_B_TYPE) && (funct_3 == F3_BLTU)) |->,
      ((prf_i.read_data1 < prf_i.read_data2) ? (pc_i.pc_in == pc_i.pc_out + imm_gen_i.imm_out)
                                             : (pc_i.pc_in == pc_i.pc_out + 32'd4))
  )

  `AST(it, bgeu,
      ((opcode == OPCODE_B_TYPE) && (funct_3 == F3_BGEU)) |->,
      ((prf_i.read_data1 >= prf_i.read_data2) ? (pc_i.pc_in == pc_i.pc_out + imm_gen_i.imm_out)
                                              : (pc_i.pc_in == pc_i.pc_out + 32'd4))
  )

  //  ================================================================================================================
  //  TYPE S INSTRUCTIONS
  //  ================================================================================================================
  `AST(it, dmem_we,
      (opcode == OPCODE_S_TYPE) |->,
      (data_mem_i.wr_en == 1'b1)
  )

  `AST(it, s_type,
      (opcode == OPCODE_S_TYPE) |->,
      ((data_mem_i.addr == (prf_i.read_data1 + imm_gen_i.imm_out)) &&
       (data_mem_i.data_in == prf_i.read_data2))
  )

  //  ================================================================================================================
  //  TYPE L INSTRUCTIONS
  //  ================================================================================================================
  `AST(it, write_back_from_dmem,
      (opcode == OPCODE_L_TYPE) |->,
      ((data_mem_i.wr_en == 1'b0) && (prf_i.write_en == 1'b1))
  )

  `AST(it, data_to_prf,
      (opcode == OPCODE_L_TYPE) |->,
      (data_mem_i.addr == (prf_i.read_data1 + imm_gen_i.imm_out))
  )

bind microprocessor_top fpv_microprocessor_top fpv_microprocessor_top_i (.*);

