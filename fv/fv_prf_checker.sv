// fv/fv_prf_checker.sv
`timescale 1ns/1ps
`include "property_defines.svh"

//------------------------------------------------------------------------------
// Module: fv_prf_checker
// Description:
//   SVA checker for physical_register_file.
//   - Verifies x0 behavior and basic write/read coherency.
//   - Keeps a small mirrored model updated on writes.
// Notes:
//   - Uses macros with disable iff(!arst_n), so checks run only when arst_n==1.
//------------------------------------------------------------------------------

module fv_prf_checker #(
  parameter int DIR_W  = 5,
  parameter int DATA_W = 32
)(
  input  logic                 clk,
  input  logic                 arst_n,

  input  logic                 write_en,
  input  logic [DIR_W-1:0]     read_dir1,
  input  logic [DIR_W-1:0]     read_dir2,
  input  logic [DIR_W-1:0]     write_dir,
  input  logic [DATA_W-1:0]    write_data,
  input  logic [DATA_W-1:0]    read_data1,
  input  logic [DATA_W-1:0]    read_data2
);

  // ---------------------------------------------------------------------------
  // Simple mirrored model (scoreboard) of the register file
  // ---------------------------------------------------------------------------
  logic [DATA_W-1:0] rf_model [0:(1<<DIR_W)-1];

  // Initialize model on reset release (macro disables during reset anyway)
  // Keep x0 forced to zero.
  always_ff @(posedge clk) begin
    if (!arst_n) begin
      for (int i = 0; i < (1<<DIR_W); i++) begin
        rf_model[i] <= '0;
      end
    end else begin
      rf_model[0] <= '0;
      if (write_en && (write_dir != '0)) begin
        rf_model[write_dir] <= write_data;
      end
    end
  end

  // ---------------------------------------------------------------------------
  // x0 read must always return zero
  // ---------------------------------------------------------------------------
  `AST (it, x0_always_zero,
     1'b1 |->, (`X0 == '0)
  )  

  // ---------------------------------------------------------------------------
  // Coverage
  // ---------------------------------------------------------------------------
  `COV(prf, cov_write_nonzero,
    (write_en && (write_dir != '0)) |->,
    1'b1
  )

  `COV(prf, cov_write_x0,
    (write_en && (write_dir == '0)) |->,
    1'b1
  )

  `COV(prf, cov_read_x0_port1,
    (read_dir1 == '0) |->,
    1'b1
  )

  `COV(prf, cov_read_x0_port2,
    (read_dir2 == '0) |->,
    1'b1
  )

endmodule

