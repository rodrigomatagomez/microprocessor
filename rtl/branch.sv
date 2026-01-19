`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Module: branch
// Description:
//   Branch decision logic for equality-based branch instructions.
//   Determines whether a branch should be taken based on register comparison.
//
// Assumptions:
//   - rs_1 and rs_2 are valid register operands provided by the register file.
//   - This module currently supports equality comparison only (BEQ).
//
// Notes:
//   - Branch type decoding (BEQ/BNE/BLT/etc.) is expected to be handled
//     by the control unit or extended logic.
//   - This block performs comparison only; branch target calculation
//     is handled elsewhere.
//------------------------------------------------------------------------------

module branch #(parameter DATA_WIDTH = 32)(
    input logic [DATA_WIDTH - 1: 0]	rs_1,
    input logic [DATA_WIDTH - 1: 0]	rs_2,
    output logic			branch_taken
    );
    
    assign branch_taken = (rs_1 == rs_2);
    
endmodule
