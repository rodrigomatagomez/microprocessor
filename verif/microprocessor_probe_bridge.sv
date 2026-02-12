//------------------------------------------------------------------------------
// Module: microprocessor_probe_bridge
// Description:
//   Bridges DUT hierarchical signals into microprocessor_if via the probe modport.
//   This keeps the TB clean and centralizes all path wiring in one place.
//------------------------------------------------------------------------------

module microprocessor_probe_bridge (
  microprocessor_if.probe vif
);

  // IF
  assign vif.pc_q          = `PC_Q;
  assign vif.pc_next       = `PC_NEXT;
  assign vif.pc_plus_inc   = `PC_PLUS_INC;
  assign vif.branch_taken  = `BR_TAKEN;
  assign vif.branch_target = `BR_TARGET;

  assign vif.instruction_sel = `INSTR_SEL;
  assign vif.instruction     = `INSTR_WORD;

  // CU fields
  assign vif.opcode   = `OPCODE;
  assign vif.funct_3  = `FUNCT3;
  assign vif.funct_7  = `FUNCT7;

  // ID/WB
  assign vif.rf_we    = `RF_WE;
  assign vif.x0       = `X0;
  assign vif.rs1      = `RS1;
  assign vif.rs2      = `RS2;
  assign vif.rd       = `RD;
  assign vif.rs1_data = `RS1_DATA;
  assign vif.rs2_data = `RS2_DATA;
  assign vif.wb_data  = `WB_DATA;
  assign vif.wb_sel   = `WB_SEL;

  // IMM/EX
  assign vif.imm_sel        = `IMM_SEL;
  assign vif.imm            = `IMM;
  assign vif.op1_sel_pc     = `OP1_SEL_PC;
  assign vif.op2_sel_imm    = `OP2_SEL_IMM;
  assign vif.alu_ctrl       = `ALU_CTRL;
  assign vif.alu_op1        = `ALU_OP1;
  assign vif.alu_op2        = `ALU_OP2;
  assign vif.alu_result     = `ALU_RES;
  assign vif.b_condition_rs1_rs2 = `BCOND;

  // MEM
  assign vif.dmem_we     = `DMEM_WE;
  assign vif.dmem_addr   = `DMEM_ADDR;
  assign vif.dmem_wdata  = `DMEM_WDATA;
  assign vif.dmem_rdata  = `DMEM_RDATA;

endmodule

