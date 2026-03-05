`timescale 1ns / 1ps
`include "riscv_params.vh"
//------------------------------------------------------------------------------
// Module: mux_3_to_1
// Description:
//   Write-back data multiplexer for the CPU datapath.
//------------------------------------------------------------------------------

module mux_3_to_1 (
    input  wire [31:0] data_out_to_pc,
    input  wire [31:0] alu_to_mem_addr,
    input  wire [31:0] data_out_to_mux,
    input  wire [1:0]  sel,
    output reg  [31:0] data_out
);

always @(*) begin
    case (sel)

        ALU_TO_PRF: begin
            data_out = alu_to_mem_addr;     // ALU result write-back
        end

        DATA_OUT_TO_PRF: begin
            data_out = data_out_to_mux;     // Memory read-back
        end

        INSTRUCTION_TO_PRF: begin
            data_out = data_out_to_pc;      // PC-based value
        end

        default: data_out = {32{1'b0}};

    endcase
end

endmodule