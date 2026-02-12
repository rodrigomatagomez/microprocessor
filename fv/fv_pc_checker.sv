//------------------------------------------------------------------------------
// Module: fv_pc_checker
// Description:
//
// Target RTL behavior (program_counter):
//   - When arst_n == 0: pc_out <= RESET_PC
//   - Else: pc_out <= pc_in on each posedge clk
//
// Notes:
//   - Macros disable iff(!arst_n), so properties are inactive during reset.
//   - Reset behavior is validated on the first clock edge after reset deassertion.
//------------------------------------------------------------------------------

//`include "property_defines.svh"

module fv_pc_checker #(
  parameter int DATA_W = 32,
  parameter logic [DATA_W-1:0] RESET_PC = '0
)(
  input  logic              clk,
  input  logic              arst_n,
  input  logic [DATA_W-1:0] pc_in,
  input  logic [DATA_W-1:0] pc_out
);

  // ---------------------------------------------------------------------------
  // 1) Alignment: PC must be word-aligned (RV32 instruction alignment)
  // ---------------------------------------------------------------------------
  `AST (it, pc_aligned,
     (1'b1) |->, (`PC_Q[1:0] == 2'b00)
  )

  `AST(it, next_instr,
    (`OPCODE inside{ OPCODE_R_TYPE, OPCODE_I_TYPE, OPCODE_U_LUI, OPCODE_U_AUIPC, OPCODE_L_TYPE, OPCODE_S_TYPE}) |->,
    (`PC_NEXT == `PC_Q + 3'b100)
  )

  // ---------------------------------------------------------------------------
  // Coverage
  // ---------------------------------------------------------------------------
  `COV(pc, cov_reset_release,
    ($past(arst_n) == 1'b0) |->,
    (`PC_Q == RESET_PC)
  )

  `COV(pc, cov_pc_update,
    ($past(arst_n) == 1'b1) |->,
    (`PC_Q == $past(`PC_NEXT))
  )

endmodule

