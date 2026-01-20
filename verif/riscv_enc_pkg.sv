//////////////////////////////////////////////////////////////////////////////////
// Description:
//   Package that defines common RISC-V RV32I instruction encodings used
//   for verification purposes. This package provides:
//
//     - Enumerated types to clearly identify RISC-V instruction formats
//       (R, I, S, B, U, J).
//     - Canonical typedefs for a 32-bit instruction word.
//     - Optional instruction descriptor structures that bundle the
//       instruction format together with its encoded word.
//
//   The intent is to:
//     - Make instruction generation readable and self-documenting.
//     - Avoid hard-coded magic numbers scattered across the testbench.
//     - Serve as a single source of truth for instruction format metadata.
//
// Notes:
//   - This package is verification-oriented (not synthesizable).
//   - Encoding follows the RISC-V Unprivileged ISA (RV32I).
//   - Actual opcode/funct3/funct7 values may be extended in this package
//     as instruction coverage grows.
//////////////////////////////////////////////////////////////////////////////////

package riscv_enc_pkg;

  // ------------------------------------------------------------
  // RISC-V RV32I instruction formats
  // ------------------------------------------------------------
  // These formats describe how the 32-bit instruction word
  // is partitioned into opcode, registers, immediates, etc.
  typedef enum logic [2:0] {
    FMT_R = 3'd0,   // R-type: register-register ALU operations
    FMT_I = 3'd1,   // I-type: ALU immediate, loads, JALR, system
    FMT_S = 3'd2,   // S-type: store instructions
    FMT_B = 3'd3,   // B-type: conditional branches
    FMT_U = 3'd4,   // U-type: LUI / AUIPC
    FMT_J = 3'd5    // J-type: JAL
  } instr_format_e;

  // ------------------------------------------------------------
  // RV32 instruction word
  // ------------------------------------------------------------
  typedef logic [31:0] instr_t;

  typedef struct packed {
    instr_format_e fmt;   // Instruction format (R/I/S/B/U/J)
    instr_t        word;  // Encoded 32-bit instruction
  } instr_desc_t;

endpackage

