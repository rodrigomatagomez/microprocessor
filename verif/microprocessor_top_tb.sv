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
  
  riscv32_rand_instruction tr;

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
  assign vif.pc_next       = dut.pc_i.pc_in;
  assign vif.pc_plus_inc   = dut.pc_adder_i.next_instruction;
  assign vif.branch_taken  = dut.cu_i.branch_taken;
  assign vif.branch_target = dut.upc_next_mux_i.sel;

  assign vif.instruction     = dut.instruction;

  // IMPORTANT:
  // Use the injected control as the selection indicator for the monitor,
  // to avoid relying on an internal hierarchical name that might not exist.
  assign vif.instruction_sel = drive_if.instr_en;

  // ID/WB
  assign vif.rf_we     = dut.prf_i.write_en;
  assign vif.x0        = dut.prf_i.prf[0];
  assign vif.rs1       = dut.prf_i.read_dir1;
  assign vif.rs2       = dut.prf_i.read_dir2;
  assign vif.rd        = dut.prf_i.write_dir;
  assign vif.rs1_data  = dut.prf_i.read_data1;
  assign vif.rs2_data  = dut.prf_i.read_data2;
  assign vif.wb_data   = dut.prf_i.write_data;
  assign vif.wb_sel    = dut.wb_mux_i.sel;

  // IMM/EX
  assign vif.imm_sel     = dut.imm_gen_i.imm_sel;
  assign vif.imm         = dut.imm_gen_i.imm_out;
  assign vif.op1_sel_pc  = dut.alu_op1_mux_i.sel;
  assign vif.op2_sel_imm = dut.alu_op2_mux_i.sel;
  assign vif.alu_ctrl    = dut.alu_i.alucontrol;
  assign vif.alu_op1     = dut.alu_i.operand1;
  assign vif.alu_op2     = dut.alu_i.operand2;
  assign vif.alu_result  = dut.alu_i.alu_result;
  assign vif.b_condition_rs1_rs2 = dut.branch_cmp_i.branch_taken;

  // MEM
  assign vif.dmem_we     = dut.data_mem_i.wr_en;
  assign vif.dmem_addr   = dut.data_mem_i.addr;
  assign vif.dmem_wdata  = dut.data_mem_i.data_in;
  assign vif.dmem_rdata  = dut.data_mem_i.data_out;

  // ===========================================================================
  // Initialize 
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
  initial begin
    
    tr = new();
    // Wait reset release

      // Example 2: fully random among allowed kinds
      repeat (100_000) begin
        if (!tr.randomize()) $fatal("Randomize failed");
        $display("[TB] %s", tr.s_print());
        drive_if.drive_item(tr);
      end
        
        // Run for enough cycles to complete the program
        @(posedge clk);
        $finish;
      end

PC_ALIGNED: assert property (@(posedge clk) disable iff (!arst_n)
            (vif.pc_q[1:0] == 2'b00)
            ) else begin
                $error("[SVA] PC misaligned. pc_q=0x%08h time=%0t", $sampled(vif.pc_q), $time);
            end

X0_ALWAYS_ZERO: assert property (@(posedge clk) disable iff (!arst_n)
                (vif.x0 == '0)
                ) else begin
                    $error("[SVA] x0 changed! x0=0x%08h instr=0x%08h time=%0t", vif.x0, vif.instruction, $time);
                end

endmodule
