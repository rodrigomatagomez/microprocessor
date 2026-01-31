interface instr_drive_if #(int DATA_W = 32) (input logic clk);

  logic              instr_en;
  logic [DATA_W-1:0] driven_instr;

  // Drive on posedge using clocking to avoid races
  clocking cb @(posedge clk);
    default input #1step output #1step;
    output instr_en;
    output driven_instr;
  endclocking

  modport driver (clocking cb, input clk);

endinterface

