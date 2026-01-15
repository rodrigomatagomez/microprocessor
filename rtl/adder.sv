`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2025 11:30:19 AM
// Design Name: 
// Module Name: adder
module adder # (parameter DATA_WIDTH = 32)(
    input logic [2:0] constant_operand,
    input logic [DATA_WIDTH - 1:0] instruction_addr,
    output logic [DATA_WIDTH - 1:0] next_instruction 
    );
    
    assign next_instruction = constant_operand + instruction_addr;
endmodule
