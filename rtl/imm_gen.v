`timescale 1ns / 1ps

`include "riscv_params.vh"

//------------------------------------------------------------------------------
// Module: imm_gen
// Description:
//   RISC-V RV32I immediate generator.
//------------------------------------------------------------------------------
module imm_gen(
    input  wire [31:0] instr,
    input  wire [2:0]  imm_sel,
    output reg  [31:0] imm_out
);

    always @(*) begin
        imm_out = {32{1'b0}}; // default

        case (imm_sel)

            // I-type immediate: imm[11:0] = instr[31:20], sign-extended
            IMM_I: imm_out = {{20{instr[31]}}, instr[31:20]};

            // S-type immediate: imm[11:5]=instr[31:25], imm[4:0]=instr[11:7], sign-extended
            IMM_S: imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};

            // B-type immediate (branch offset)
            // imm[12]=instr[31], imm[11]=instr[7], imm[10:5]=instr[30:25], imm[4:1]=instr[11:8], imm[0]=0
            IMM_B: imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};

            // U-type immediate: upper 20 bits, low 12 bits zero
            IMM_U: imm_out = {instr[31:12], 12'b0};

            // J-type immediate (jump offset)
            // imm[20]=instr[31], imm[19:12]=instr[19:12], imm[11]=instr[20], imm[10:1]=instr[30:21], imm[0]=0
            IMM_J: imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};

            default: imm_out = {32{1'b0}};

        endcase
    end

endmodule