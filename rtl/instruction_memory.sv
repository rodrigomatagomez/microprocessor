`timescale 1ns / 1ps

//------------------------------------------------------------------------------
// Module: instruction_memory
// Description:
//   Read-only instruction memory for a single-cycle RV32I datapath.
//   The memory is word-addressed and indexed using a byte-addressed PC.
//
// Assumptions:
//   - PC is byte-addressed and word-aligned (pc[1:0] = 2'b00).
//   - Instruction width is 32 bits.
//   - DEPTH specifies the number of 32-bit words.
//
// Notes:
//   - The two LSBs of PC are dropped to convert from byte to word addressing.
//   - Out-of-range PC values are not checked here; bounds checking can be
//     enforced via assertions in a later verification stage.
//------------------------------------------------------------------------------
module instruction_memory #(
    parameter int DATA_WIDTH = 32,
    parameter int DEPTH      = 1024
)(
    input  logic [DATA_WIDTH-1:0] pc,
    output logic [DATA_WIDTH-1:0] instr
);

    // Instruction storage (word-addressed)
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Word index derived from byte-addressed PC
    logic [$clog2(DEPTH)-1:0] pc_word_idx;
    assign pc_word_idx = pc[11:2];

    // Initialize instruction memory from hex file
    initial begin
        $readmemh("program.mem", mem);
    end

    // Combinational read
    assign instr = mem[pc_word_idx];

endmodule

