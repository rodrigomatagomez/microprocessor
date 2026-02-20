// fv/fv_microprocessor_top.sv
`timescale 1ns/1ps
//`include "property_defines.svh"

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
  // ASSERTIONS  
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
    ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == F3_ADD_SUB_MUL)) |->,
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
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_ADD_SUB_MUL) && (`FUNCT7 == 7'b0100_000)) |->,
      (`WB_DATA == (`RS1_DATA - `RS2_DATA))
  )

  `AST(it, add,
      ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == F3_ADD_SUB_MUL) && (`FUNCT7 == 7'b0000_000)) |->,
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
  // COVERS
  // ---------------------------------------------------------------------------
  `COV(it, cov_any_i_type, (`OPCODE == OPCODE_I_TYPE) |->, 1'b1)
  `COV(it, cov_any_r_type, (`OPCODE == OPCODE_R_TYPE) |->, 1'b1)
  `COV(it, cov_any_b_type, (`OPCODE == OPCODE_B_TYPE) |->, 1'b1)
  `COV(it, cov_any_l_type, (`OPCODE == OPCODE_L_TYPE) |->, 1'b1)
  `COV(it, cov_any_s_type, (`OPCODE == OPCODE_S_TYPE) |->, 1'b1)
  `COV(it, cov_any_lui,    (`OPCODE == OPCODE_U_LUI)  |->, 1'b1)
  `COV(it, cov_any_auipc,  (`OPCODE == OPCODE_U_AUIPC)|->, 1'b1)
  `COV(it, cov_any_jal,    (`OPCODE == OPCODE_JAL_TYPE)|->, 1'b1)

  // ---------------------------------------------------------------------------
  // COVERGROUPS
  // ---------------------------------------------------------------------------


  // Sample coverage on every cycle after reset
  covergroup cg_instr @(posedge clk);
    option.per_instance = 1;

    // Cover that we ever saw a NOP on the instruction bus
    cp_nop: coverpoint (`OPCODE == 7'b1111111) iff (arst_n) {
      bins seen_nop = {1'b1};
    }

    // Basic opcode coverage 
    cp_opcode: coverpoint `OPCODE iff (arst_n) {
      bins r_type = {OPCODE_R_TYPE};
      bins i_type = {OPCODE_I_TYPE};
      bins l_type = {OPCODE_L_TYPE};
      bins s_type = {OPCODE_S_TYPE};
      bins b_type = {OPCODE_B_TYPE};
      bins lui    = {OPCODE_U_LUI};
      bins auipc  = {OPCODE_U_AUIPC};
      bins jal    = {OPCODE_JAL_TYPE};
    }

    // Funct3 
    cp_funct3_i: coverpoint `FUNCT3 iff (arst_n && (`OPCODE == OPCODE_I_TYPE)) {
      bins addi  = {F3_ADD_SUB_MUL};
      bins slti  = {F3_SLT};
      bins sltiu = {F3_SLTU};
      bins xori  = {F3_XOR};
      bins ori   = {F3_OR};
      bins andi  = {F3_AND};
    }

    cp_funct3_r: coverpoint `FUNCT3 iff (arst_n && (`OPCODE == OPCODE_R_TYPE)) {
      bins add_sub_mul = {F3_ADD_SUB_MUL};
      bins sll         = {F3_SLL};
      bins slt         = {F3_SLT};
      bins sltu        = {F3_SLTU};
      bins xor_        = {F3_XOR};
      bins srl_sra     = {F3_SRL_SRA};
      bins or_         = {F3_OR};
      bins and_        = {F3_AND};
    }
    
    cp_funct3_b: coverpoint `FUNCT3 iff (arst_n && (`OPCODE == OPCODE_B_TYPE)) {
      bins beq =  {F3_BEQ};
      bins bne =  {F3_BNE};
      bins blt =  {F3_BLT};
      bins bge =  {F3_BGE}; 
      bins bltu = {F3_BLTU};
      bins bgeu = {F3_BGEU};

    }

    cp_funct3_s: coverpoint `FUNCT3 iff (arst_n && (`OPCODE == OPCODE_S_TYPE)) {
      bins sb =  {F3_SB};
      bins sh =  {F3_SH};
      bins sw =  {F3_SW};
    }

    cp_funct3_l: coverpoint `FUNCT3 iff (arst_n && (`OPCODE == OPCODE_L_TYPE)) {
      bins lb  =  {F3_LB};
      bins lh  =  {F3_LH};
      bins lw  =  {F3_LW};
      bins lbu =  {F3_LBU};
      bins lhu =  {F3_LHU};
   }
    // Funct7 
    cp_funct7_r: coverpoint `FUNCT7 iff (arst_n && (`OPCODE == OPCODE_R_TYPE)) {
      bins base = {7'b0000_000};
      bins sub  = {7'b0100_000};
      bins mul  = {7'b0000_001};
    }

    cx_rtype: cross cp_funct3_r, cp_funct7_r iff (arst_n && (`OPCODE == OPCODE_R_TYPE)) {

      bins f7_add   = binsof(cp_funct3_r.add_sub_mul)  && binsof(cp_funct7_r.base);
      bins f7_sub   = binsof(cp_funct3_r.add_sub_mul)  && binsof(cp_funct7_r.sub);
      bins f7_mul   = binsof(cp_funct3_r.add_sub_mul)  && binsof(cp_funct7_r.mul);
      bins srl_base = binsof(cp_funct3_r.srl_sra)  && binsof(cp_funct7_r.base);
      bins sra_sub  = binsof(cp_funct3_r.srl_sra)  && binsof(cp_funct7_r.sub);

        ignore_bins ign_other_f3 =
            binsof(cp_funct3_r.sll)  ||
            binsof(cp_funct3_r.slt)  ||
            binsof(cp_funct3_r.sltu) ||
            binsof(cp_funct3_r.xor_) ||
            binsof(cp_funct3_r.or_)  ||
            binsof(cp_funct3_r.and_);
    }


  endgroup

  cg_instr cg_instr_i;

  initial begin
    // Create covergroup instance
    cg_instr_i = new();
  end
  endmodule

