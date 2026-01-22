`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    microprocessor_if
// Description:
//   Verification interface for a single-cycle RV32I microprocessor.
//////////////////////////////////////////////////////////////////////////////////

interface microprocessor_if (input logic clk, input logic arst_n);

//INSTRUCTION parameters
parameter DATA_WIDTH    =   32;
parameter ADDI_OPCODE   =   7'b0010011;
parameter FUNCT3_ADDI   =   3'b000; 

//Declaration of signals used by testbench only (can only be accessed by interface tasks/functions)

//-------INSTRUCTIONS---------------
logic [DATA_WIDTH-1:0]  instruction; 
logic [11:0]            imm_addi; 
logic [4:0]             rs1;
logic [4:0]             rs2;
logic [4:0]             rd;
//--------PRF-----------------------
logic prf_we;


//This modport is to connect with the logic 
/*modport microprocessor_modport(
	input instruction
);*/

//------------------------------------------------------------------------------
// Task: drive an ADDI instruction (I-type)
// I-type layout:
//	[31:20]	imm[11:0]
//	[19:15]	rs1
//	[14:12]	func3
//	[11:7]	rd
//	[6:0]	opcode
//-----------------------------------------------------------------------------
task automatic build_addi_random();
    @(posedge clk);
    std::randomize (rd, rs1, imm_addi) with {
      rd  inside  {[1:31]};
      rs1 inside  {[0:31]};
      imm_addi  inside  {[0:4095]};
    };
    instruction <= {imm_addi, rs1, FUNCT3_ADDI, rd, OPCODE_OPIMM};
endtask
//--------------------------------------------------------------------------
//Task: fill the prf to avoid X in results
// Fill x1..x31 with non-zero deterministic values using ADDI xN, x0, imm
// x0 is hardwired to 0 by ISA, so we avoid writing x0.
// ------------------------------------------------------------------------
task automatic init_prf();
	prf_we = 1'b1;
	for( int r = 1; r < 32; r++) begin 
        	@(posedge clk);
       		instruction <= {12'd0, 5'd0, FUNCT3_ADDI, r, OPCODE_OPIMM};
	end
endtask
    //--------------------------------------------------------------------------------
    //function: check if the instrucction is Type-I (addi)
    //-------------------------------------------------------------------------------
    function automatic check_addi (logic [31:0] addi_instr);
        return (addi_instr[6:0] == OPCODE_OPIMM) && (addi_instr[14:12] == FUNCT3_ADDI);
    endfunction
    
endinterface 
