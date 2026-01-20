`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Module: mux_3_to_1
// Description:
//   Write-back data multiplexer for the CPU datapath. Selects the value
//   to be written into the register file based on control logic.
//
// Inputs:
//   - data_out_to_pc     : PC-related value.
//   - alu_to_mem_addr   : ALU computation result or address.
//   - data_out_to_mux   : Data read from memory or auxiliary datapath.
//
// Control:
//   - sel is driven by the control unit and encoded in defines.svh.
//
// Notes:
//   - Selection logic only; no arithmetic is performed.
//   - sel encodings are expected to be mutually exclusive.
//------------------------------------------------------------------------------
module mux_3_to_1 (
    input logic [31:0]	data_out_to_pc,
    input logic [31:0]	alu_to_mem_addr,
    input logic [31:0]	data_out_to_mux,
    input logic [1:0]	sel,
    output logic [31:0]	data_out
    );
//`include "defines.svh"  
always_comb begin   
    unique case (sel)
        ALU_TO_PRF: begin	
            data_out = alu_to_mem_addr;	//ALU result write-back
        end
        DATA_OUT_TO_PRF: begin 
            data_out = data_out_to_mux;	//Memory or datapath read-back
        end
        INSTRUCTION_TO_PRF: begin
            data_out = data_out_to_pc;	// PC-based value
        end
        default: data_out = '0;
    endcase
end
endmodule
