module microprocessor_datapath #(int DATA_W = 32, int DIR_W = 5)(microprocessor_if vif, microprocessor_top dut);

  // IF
  assign vif.PC_Q               = dut.pc_i.pc_out;
  assign vif.PC_NEXT            = dut.pc_i.pc_in;
  assign vif.PC_PLUS_INCREMENT  = dut.upc_next_mux_i.in2;
  assign vif.PC_BRANCH_TAKEN    = dut.upc_next_mux_i.sel;
  assign vif.PC_BRANCH_TARGET   = dut.upc_next_mux_i.in1;

  assign vif.INSTRUCTION        = dut.instruction;

  // Decode 
  assign vif.RS1 = dut.instruction[19:15];
  assign vif.RS2 = dut.instruction[24:20];
  assign vif.RD  = dut.instruction[11:7];

  // ID/WB
  assign vif.PRF_WE   = dut.prf_i.write_en;
  assign vif.REG_1    = dut.prf_i.read_data1;
  assign vif.REG_2    = dut.prf_i.read_data2;
  assign vif.DATA_IN  = dut.prf_i.write_data;
  assign vif.WB_SEL   = dut.wb_mux_i.sel;

  // EX
  assign vif.IMM_TYPE         = dut.imm_gen_i.imm_sel;
  assign vif.IMM_OUT          = dut.imm_gen_i.imm_out;
  assign vif.ALU_OPERAND1_SEL = dut.alu_op1_mux_i.sel;
  assign vif.ALU_OPERAND2_SEL = dut.alu_op2_mux_i.sel;
  assign vif.ALU_SEL          = dut.alu_i.alucontrol;
  assign vif.ALU_OPERAND1     = dut.alu_i.operand1;
  assign vif.ALU_OPERAND2     = dut.alu_i.operand2;
  assign vif.ALU_RESULT       = dut.alu_i.alu_result;

  // MEM
  assign vif.DMEM_WE    = dut.data_mem_i.wr_en;
  assign vif.DMEM_ADDR  = dut.data_mem_i.addr;
  assign vif.DMEM_DATA_IN = dut.data_mem_i.data_in;
  assign vif.DMEM_DATA_OUT = dut.data_mem_i.data_out;

endmodule

