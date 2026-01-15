`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 01:12:18 PM
// Design Name: 
// Module Name: mux_3_to_1


module mux_3_to_1 (
    input logic [31:0] data_out_to_pc,
    input logic [31:0] alu_to_mem_addr,
    input logic [31:0] data_out_to_mux,
    input logic [1:0] sel,
    output logic [31:0] data_out
    );
`include "defines.sv"  
always_comb begin   
    case (sel)
        ALU_TO_PRF: begin 
            data_out = alu_to_mem_addr;
        end
        DATA_OUT_TO_PRF: begin 
            data_out = data_out_to_mux;
        end
        INSTRUCTION_TO_PRF: begin
            data_out = data_out_to_pc;
        end
        default: data_out = '0;
    endcase
end
endmodule
