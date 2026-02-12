// verif/microprocessor_top_tb.sv
`timescale 1ns/1ps

import riscv_params_pkg::*;

module microprocessor_top_tb;

  // ---------------------------------------------------------------------------
  // Clock / Reset
  // ---------------------------------------------------------------------------
  bit clk;
  bit arst_n;

  initial clk = 1'b0;
  always #5ns clk = ~clk;

  initial begin
    arst_n = 1'b0;
    repeat (3) @(posedge clk);
    arst_n = 1'b1;
  end

  // ---------------------------------------------------------------------------
  // Interfaces
  // ---------------------------------------------------------------------------
  instr_drive_if #(DATA_WIDTH) drive_if (clk);
  microprocessor_if #(DATA_WIDTH, DIR_WIDTH) vif (clk);
  microprocessor_probe_bridge u_probe_bridge (.vif(vif));
  riscv32_rand_instruction tr;
  
  instr_kind_decode_for_waves u_kind_decode (.vif(vif));
  

  // ---------------------------------------------------------------------------
  // DUT
  // ---------------------------------------------------------------------------
  microprocessor_top dut (
    .clk          (clk),
    .arst_n       (arst_n),
    .instr_en     (drive_if.instr_en),
    .driven_instr (drive_if.driven_instr)
  );

  //-----------------------------------------------------------------------------
  // CHECKER 
  // ---------------------------------------------------------------------------

   fv_microprocessor_top #(
      .DATA_W(DATA_WIDTH),
      .DIR_W(DIR_WIDTH)
   ) fv_microprocessor_top_i (
      .clk   (clk),
      .arst_n(arst_n),
      .vif   (vif)
);
  
  

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

    repeat (1000) begin
      if (!tr.randomize()) $fatal("Randomize failed");
      drive_if.drive_item(tr);
    end

    @(posedge clk);
    $finish;
  end

endmodule

