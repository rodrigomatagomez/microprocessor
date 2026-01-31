`timescale 1ns/1ps
`include "defines.svh"
`include "instr_drive_if.sv"
`include "microprocessor_if.sv"
//`include "instruction_generator.sv"

module microprocessor_top_tb;

  // ===========================================================================
  // Clock / Reset
  // ===========================================================================
  bit clk;
  bit arst_n;

  initial clk = 1'b0;
  always #5ns clk = ~clk;

  // Reset: hold low for 3 cycles
  initial begin
    arst_n = 1'b0;
    repeat (3) @(posedge clk);
    arst_n = 1'b1;
  end

  // ===========================================================================
  // Interfaces
  // ===========================================================================
  // Injection interface: drives instr_en/driven_instr
  instr_drive_if #(DATA_WIDTH) drive_if (clk);

  // Monitor interface: observes DUT internal/outputs via probe bridge
  microprocessor_if #(DATA_WIDTH, DIR_WIDTH) vif (clk);

  // ===========================================================================
  // DUT
  // ===========================================================================
  microprocessor_top dut (
    .clk          (clk),
    .arst_n       (arst_n),
    .instr_en     (drive_if.instr_en),
    .driven_instr (drive_if.driven_instr)
  );

  // ===========================================================================
  // DUT -> VIF "probe bridge"
  // ===========================================================================
  // IF
  assign vif.pc_q          = dut.pc_i.pc_out;
  assign vif.pc_next       = dut.pc_next;
  assign vif.pc_plus_inc   = dut.pc_plus_inc;
  assign vif.branch_taken  = dut.branch_taken;
  assign vif.branch_target = dut.branch_target;

  assign vif.instruction     = dut.instruction;

  // IMPORTANT:
  // Use the injected control as the selection indicator for the monitor,
  // to avoid relying on an internal hierarchical name that might not exist.
  assign vif.instruction_sel = drive_if.instr_en;

  // ID/WB
  assign vif.rf_we     = dut.rf_we;
  assign vif.rs1       = dut.instruction[19:15];
  assign vif.rs2       = dut.instruction[24:20];
  assign vif.rd        = dut.instruction[11:7];
  assign vif.rs1_data  = dut.rs1_data;
  assign vif.rs2_data  = dut.rs2_data;
  assign vif.wb_data   = dut.wb_data;
  assign vif.wb_sel    = dut.wb_sel;

  // IMM/EX
  assign vif.imm_sel     = dut.imm_sel;
  assign vif.imm         = dut.imm;
  assign vif.op1_sel_pc  = dut.op1_sel_pc;
  assign vif.op2_sel_imm = dut.op2_sel_imm;
  assign vif.alu_ctrl    = dut.alu_ctrl;
  assign vif.alu_op1     = dut.alu_op1;
  assign vif.alu_op2     = dut.alu_op2;
  assign vif.alu_result  = dut.alu_result;
  assign vif.b_condition_rs1_rs2 = dut.b_condition_rs1_rs2;

  // MEM
  assign vif.dmem_we     = dut.dmem_we;
  assign vif.dmem_addr   = dut.alu_result;
  assign vif.dmem_wdata  = dut.rs2_data;
  assign vif.dmem_rdata  = dut.dmem_rdata;

  // ===========================================================================
  // Optional: Initialize internal state (only if acceptable in your flow)
  // ===========================================================================
  initial begin : init_state
    for (int i = 1; i < 32; i++) begin
      dut.prf_i.prf[i] = '0;
    end

    for (int j = 0; j < DEPTH; j++) begin
      dut.data_mem_i.mem[j] = '0;
    end
  end

  // ===========================================================================
  // TEST_PROGRAM
  // ===========================================================================
  initial begin : tb_main
    // Wait reset release
    @(posedge arst_n);
    // Default injection
    drive_if.cb.instr_en     <= 1'b1;
    drive_if.cb.driven_instr <= 32'h0000_0037; // lui
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_0017; // auipc
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_006f; // jal
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_0063; // beq
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_1063; // bne
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_4063; // blt
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_5063; // bge
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_6063; // bltu
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_7063; // bgeu
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_0003; // lb
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_1003; // lh
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_2003; // lw
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_4003; // lbu
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_5003; // lhu
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_0023; // sb
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_1023; // sh
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_2023; // sw
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_0013; // addi
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_2013; // slti
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_3013; // sltiu
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_4013; // xori
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_6013; // ori
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_7013; // andi
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_0033; // add
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h4000_0033; // sub
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_1033; // sll
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_2033; // slt
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_3033; // sltu
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_4033; // xor
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_5033; // srl
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h4000_5033; // sra
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_6033; // or
    @(posedge clk)
    drive_if.cb.driven_instr <= 32'h0000_7033; // and
    @(posedge clk)
    
    // Run for enough cycles to complete the program
    @(posedge clk);
    $finish;
  end

endmodule
