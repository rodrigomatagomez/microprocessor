// verif/microprocessor_vif_bridge.sv
//------------------------------------------------------------------------------
// Module: microprocessor_vif_bridge
// Description:
//   Connects DUT internal signals to the microprocessor_if (vif) for monitoring.
//   Intended to be attached via bind to microprocessor_top.
//------------------------------------------------------------------------------

module microprocessor_vif_bridge (
  microprocessor_if.monitor vif
);

  // NOTE:
  // This module expects to be bound inside microprocessor_top scope.
  // Therefore it can reference internal signals directly by name.

  // IF
  assign vif.pc_q          = pc_q;
  assign vif.pc_next       = pc_next;
  assign vif.pc_plus_inc   = pc_plus_inc;
  assign vif.branch_taken  = branch_taken;
  assign vif.branch_target = branch_target;

  assign vif.instruction   = instruction;

  // Control Unit fields (these exist as signals in microprocessor_if)
  // In your top, opcode/funct fields are derived from instruction slices.
  assign vif.opcode        = instruction[6:0];
  assign vif.funct_3       = instruction[14:12];
  assign vif.funct_7       = instruction[31:25];

  // ID/WB
  assign vif.rf_we         = rf_we;
  assign vif.rs1           = instruction[19:15];
  assign vif.rs2           = instruction[24:20];
  assign vif.rd            = instruction[11:7];
  assign vif.rs1_data      = rs1_data;
  assign vif.rs2_data      = rs2_data;
  assign vif.wb_data       = wb_data;
  assign vif.wb_sel        = wb_sel;
  assign vif.x0            = prf_i.prf[0];

  // IMM/EX
  assign vif.imm_sel       = imm_sel;
  assign vif.imm           = imm;
  assign vif.op1_sel_pc    = op1_sel_pc;
  assign vif.op2_sel_imm   = op2_sel_imm;
  assign vif.alu_ctrl      = alu_ctrl;
  assign vif.alu_op1       = alu_op1;
  assign vif.alu_op2       = alu_op2;
  assign vif.alu_result    = alu_result;
  assign vif.b_condition_rs1_rs2 = b_condition_rs1_rs2;

  // MEM
  assign vif.dmem_we       = dmem_we;
  assign vif.dmem_addr     = alu_result;
  assign vif.dmem_wdata    = rs2_data;
  assign vif.dmem_rdata    = dmem_rdata;
  
  assign vif.instruction_sel = drive_if.instr_en;
endmodule

