`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Module: instruction_memory
// Description:
//   Read-only instruction memory for a single-cycle RV32I datapath.
//------------------------------------------------------------------------------
module instruction_memory #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH      = 1024
)(
    input  wire [DATA_WIDTH-1:0] pc,
    output wire [DATA_WIDTH-1:0] instr
);

    // -------------------------------------------------------------------------
    // clog2 function (replacement for $clog2 in Verilog)
    // -------------------------------------------------------------------------
    function integer clog2;
        input integer value;
        integer i;
        begin
            value = value - 1;
            for (i = 0; value > 0; i = i + 1)
                value = value >> 1;
            clog2 = i;
        end
    endfunction

    localparam integer ADDR_W = clog2(DEPTH);

    // Instruction storage (word-addressed)
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Word index derived from byte-addressed PC
    wire [ADDR_W-1:0] pc_word_idx;

    // Drop 2 LSBs (byte -> word) and keep only the bits needed for DEPTH
    assign pc_word_idx = pc[ADDR_W+1:2];

    // Initialize instruction memory: default NOP
    integer i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem[i] = 32'h00000013; // NOP (ADDI x0,x0,0)
        end
        // Si luego quieres cargar un archivo:
        // $readmemh("program.mem", mem);
    end

    // Combinational read
    assign instr = mem[pc_word_idx];

endmodule