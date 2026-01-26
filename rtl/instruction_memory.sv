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
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 1024,
    parameter string MEMFILE = "test1.mem" 
)(
    input  logic [DATA_WIDTH-1:0] pc,
    output logic [DATA_WIDTH-1:0] instr
);

    // Instruction storage (word-addressed)
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Word index derived from byte-addressed PC
    localparam int ADDR_W = $clog2(DEPTH);
    logic [ADDR_W-1:0] pc_word_idx;

    // Drop 2 LSBs (byte -> word) and keep only the bits needed for DEPTH
    assign pc_word_idx = pc[ADDR_W+1:2];

    // Initialize instruction memory: default NOP, then overwrite with program.mem
    initial begin
        for (int i = 0; i < DEPTH; i++) begin
            mem[i] = 32'h00000013; // NOP
        end
        $readmemh(MEMFILE, mem);
    end
    // Combinational read (single-cycle IMEM)
    assign instr = mem[pc_word_idx];

endmodule

