`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    microprocessor_if
// Description:
//   Verification interface for a single-cycle RV32I microprocessor.
//////////////////////////////////////////////////////////////////////////////////

import riscv_enc_pkg::*;

interface microprocessor_if (input logic clk, input logic arst_n);
    //------------------------------------------------------------------------------
    // Task: drive an ADDI instruction (I-type)
    // I-type layout:
    //	[31:20]	imm[11:0]
    //	[19:15]	rs1
    //	[14:12]	func3
    //	[11:7]	rd
    //	[6:0]	opcode
    //-----------------------------------------------------------------------------
    instr_t instruction;

    localparam logic [6:0] OPCODE_OPIMM = 7'b0010011; // op-imm
    localparam logic [2:0] FUNCT3_ADDI = 3'b000; //addi 

    task automatic drive_addi(
        logic [4:0]    rd,
        logic [4:0]   rs1,
        logic [11:0]  imm
        );
        @(posedge clk);
        instruction <= {imm, rs1, FUNCT3_ADDI, rd, OPCODE_OPIMM};
    endtask
    //--------------------------------------------------------------------------
    //Task: fill the prf to avoid X in results
    // Fill x1..x31 with non-zero deterministic values using ADDI xN, x0, imm
    // x0 is hardwired to 0 by ISA, so we avoid writing x0.
    // ------------------------------------------------------------------------
    task automatic init_prf();
        for( int r = 1; r < 32; r++) begin 
            drive_addi((r[4:0]), 5'd0, (r[11:0]));
            //@(posedge clk);
        end
    endtask
endinterface 
