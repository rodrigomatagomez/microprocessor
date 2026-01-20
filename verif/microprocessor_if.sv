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
task automatic drive_addi(
	logic [4:0]	rd,
	logic [4:0]	rs1,
	logic [11:0]	imm
);	
	@(posedge clk);
	intruction <= {imm, rs1, FUNCT3_ADDI, rd, OPCODE_OPIMM};
endtask

endinterface 
