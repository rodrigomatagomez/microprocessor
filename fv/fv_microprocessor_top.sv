// fv/fv_microprocessor_top.sv
`timescale 1ns/1ps
`include "property_defines.svh"

//------------------------------------------------------------------------------
// Module: fv_microprocessor_top
// Description:
//   Top-level SVA checker using microprocessor_if signals.
//   - Keeps the original assertion text and naming.
//   - Uses vif.* as the signal source.
//------------------------------------------------------------------------------

module fv_microprocessor_top #(
  parameter int DATA_W = 32,
  parameter int DIR_W  = 5
)(
  input  logic clk,
  input  logic arst_n,
  microprocessor_if.monitor vif
);


  // ---------------------------------------------------------------------------
  // ORIGINAL ASSERTIONS (unchanged text & naming)
  // ---------------------------------------------------------------------------

  //  =============================================================================================================
  //  PC AND PRF
  `AST (it, pc_aligned,
       1'b1 |->, (`PC_Q[1:0] == 2'b00)
  )

  `AST(it, next_instr,
      (`OPCODE inside{ OPCODE_R_TYPE, OPCODE_I_TYPE, OPCODE_U_LUI, OPCODE_U_AUIPC, OPCODE_L_TYPE, OPCODE_S_TYPE}) |->,
      (`PC_NEXT == `PC_Q + 3'b100)
  )

  `AST (it, x0_always_zero,
       1'b1 |->, (`X0 == '0)
  )

  //  ===========================================================================================================
  //  TYPE_I INSTRUCTIONS
  `AST (it, imm_I_type,
       (`OPCODE == OPCODE_I_TYPE) |->, (`IMM_SEL == IMM_I)
  )

  `AST(it, prf_we,
      (`OPCODE == OPCODE_I_TYPE) |->, (`RF_WE == 1'b1)
  )

  `AST(it, pc_4,
      (`OPCODE == OPCODE_I_TYPE) |->, (`PC_NEXT == `PC_Q + 3'b100)
  )

  // =========================================================
  // I-type: ADDI, SLTI, SLTIU, XORI, ORI, ANDI
  // =========================================================

  `AST(it, addi_result,
    ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == F3_ADD_SUB)) |->,
    (`WB_DATA == (`ALU_OP1 + `ALU_OP2))
  )

/*  `AST(it, slti_result,
    ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == F3_SLT)) |->,
    (`WB_DATA ==
    ( $signed(`ALU_OP1) < $signed(`ALU_OP2) ))
  )*/
  

  `AST(it, sltiu_result,
    ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == F3_SLTU)) |->,
    (`WB_DATA == ((`ALU_OP1 < `ALU_OP2) ? 32'd1 : 32'd0))
  )

  `AST(it, xori_result,
    ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == F3_XOR)) |->,
    (`WB_DATA == (`ALU_OP1 ^ `ALU_OP2))
  )

  `AST(it, ori_result,
    ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == F3_OR)) |->,
    (`WB_DATA == (`ALU_OP1 | `ALU_OP2))
  )

  `AST(it, andi_result,
    ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == F3_AND)) |->,
    (`WB_DATA == (`ALU_OP1 & `ALU_OP2))
  )

  //  ===========================================================
  //  R-type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
  //  ==========================================================

  `AST(it, sub,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_ADD_SUB) && (`FUNCT7 == 7'b0100_000)) |->,
      (`WB_DATA == (`RS1_DATA - `RS2_DATA))
  )

  `AST(it, add,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_ADD_SUB) && (`FUNCT7 == 7'b0000_000)) |->,
      (`WB_DATA == (`RS1_DATA + `RS2_DATA))
  )

  `AST(it, sll,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_SLL) && (`FUNCT7 == 7'b0000_000)) |->,
      (`WB_DATA == (`RS1_DATA << `RS2_DATA[4:0]))
  )

  `AST(it, slt,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_SLT) && (`FUNCT7 == 7'b0000_000)) |->,
      ((`WB_DATA) == ($signed(`RS1_DATA) < $signed(`RS2_DATA) ? 32'd1 : 32'd0))
  )

  `AST(it, sltu,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_SLTU) && (`FUNCT7 == 7'b0000_000)) |->,
      (`WB_DATA == (`RS1_DATA < `RS2_DATA ? 32'd1 : 32'd0) )
  )

  `AST(it, xor_,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_XOR) && (`FUNCT7 == 7'b0000_000)) |->,
      (`WB_DATA == (`RS1_DATA ^ `RS2_DATA))
  )

  `AST(it, srl,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_SRL_SRA) && (`FUNCT7 == 7'b0000_000)) |->,
      (`WB_DATA == (`RS1_DATA >> `RS2_DATA[4:0]))
  )

  `AST(it, sra,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_SRL_SRA) && (`FUNCT7 == 7'b0100_000)) |->,
      ($signed(`WB_DATA) == ($signed(`RS1_DATA) >>> `RS2_DATA[4:0]) )
  )

  `AST(it, or_,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_OR) && (`FUNCT7 == 7'b0000_000)) |->,
      (`WB_DATA == (`RS1_DATA | `RS2_DATA))
  )

  `AST(it, and_,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_AND) && (`FUNCT7 == 7'b0000_000)) |->,
      (`WB_DATA == (`RS1_DATA & `RS2_DATA))
  )

  //  ==============================================================================================
  //  JAL (JUMP AND LINK) INSTRUCTION
  //  =============================================================================================
  `AST(it, jal,
      (`OPCODE == OPCODE_JAL_TYPE) |->,
      (`PC_NEXT == (`PC_Q + `ALU_OP2))
  )

  // ===============================================================================================
  // LUI INSTRUCTION
  // ==============================================================================================
  `AST (it, lui,
       (`OPCODE == OPCODE_U_LUI) |->,
       (`WB_DATA == (32'd0 + `IMM))
  )

  //  =============================================================================================
  //  AUIPC INSTRUCTION
  //  ============================================================================================
  `AST (it, auipc,
       (`OPCODE == OPCODE_U_AUIPC) |->,
       (`WB_DATA == (`PC_Q + `IMM))
  )

  //  =============================================================================================
  //  TYPE B INSTRUCTIONS
  //  ============================================================================================

  `AST(it, b_instr,
      (`OPCODE == OPCODE_B_TYPE) |->,
      ((`BR_TAKEN) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
  )

  `AST(it, beq,
      ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == F3_BEQ) ) |->,
      ((`RS1_DATA == `RS2_DATA) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
  )

  `AST(it, bne,
      ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == F3_BNE) ) |->,
      ((`RS1_DATA != `RS2_DATA) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
  )

  `AST(it, blt,
      ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == F3_BLT) ) |->,
      (($signed(`RS1_DATA) < $signed(`RS2_DATA)) ?  (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
  )

  `AST(it, bge,
      ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == F3_BGE) ) |->,
      (($signed(`RS1_DATA) >= $signed(`RS2_DATA)) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
  )

  `AST(it, bltu,
      ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == F3_BLTU) ) |->,
      ((`RS1_DATA < `RS2_DATA) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
  )

  `AST(it, bgeu,
      ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == F3_BGEU) ) |->,
      ((`RS1_DATA >= `RS2_DATA) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
  )

  //  ================================================================================================================
  //  TYPE S INSTRUCTIONS
  //  ================================================================================================================
  `AST(it,dmem_we,
      (`OPCODE == OPCODE_S_TYPE) |->,
      (`DMEM_WE == 1'b1)
  )

  `AST(it, s_type,
      (`OPCODE == OPCODE_S_TYPE) |->,
      ((`DMEM_ADDR == `RS1_DATA + `IMM) && (`DMEM_WDATA == `RS2_DATA))
  )

  //  ================================================================================================================
  //  TYPE L INSTRUCTIONS
  //  ================================================================================================================
  `AST(it,write_back_from_dmem,
      (`OPCODE == OPCODE_L_TYPE) |->,
      ((`DMEM_WE == 1'b0) && (`RF_WE == 1'b1))
  )

  `AST(it, data_to_prf,
      (`OPCODE == OPCODE_L_TYPE) |->,
      (`DMEM_ADDR == `RS1_DATA + `IMM )
  )

  // ---------------------------------------------------------------------------
  // Simple coverage (you can expand later)
  // ---------------------------------------------------------------------------
  `COV(it, cov_any_i_type, (`OPCODE == OPCODE_I_TYPE) |->, 1'b1)
  `COV(it, cov_any_r_type, (`OPCODE == OPCODE_R_TYPE) |->, 1'b1)
  `COV(it, cov_any_b_type, (`OPCODE == OPCODE_B_TYPE) |->, 1'b1)
  `COV(it, cov_any_l_type, (`OPCODE == OPCODE_L_TYPE) |->, 1'b1)
  `COV(it, cov_any_s_type, (`OPCODE == OPCODE_S_TYPE) |->, 1'b1)
  `COV(it, cov_any_lui,    (`OPCODE == OPCODE_U_LUI)  |->, 1'b1)
  `COV(it, cov_any_auipc,  (`OPCODE == OPCODE_U_AUIPC)|->, 1'b1)
  `COV(it, cov_any_jal,    (`OPCODE == OPCODE_JAL_TYPE)|->, 1'b1)

  // Cleanup macro namespace inside this module
  `undef PC_Q
  `undef PC_NEXT
  `undef PC_PLUS_INC
  `undef BR_TAKEN
  `undef BR_TARGET
  `undef OPCODE
  `undef FUNCT3
  `undef FUNCT7
  `undef INSTR_WORD
  `undef INSTR_SEL
  `undef RF_WE
  `undef X0
  `undef RS1
  `undef RS2
  `undef RD
  `undef RS1_DATA
  `undef RS2_DATA
  `undef WB_DATA
  `undef WB_SEL
  `undef IMM_SEL
  `undef IMM
  `undef OP1_SEL_PC
  `undef OP2_SEL_IMM
  `undef ALU_CTRL
  `undef ALU_OP1
  `undef ALU_OP2
  `undef ALU_RES
  `undef BCOND
  `undef DMEM_WE
  `undef DMEM_ADDR
  `undef DMEM_WDATA
  `undef DMEM_RDATA

endmodule

