`timescale 1ns / 1ps
//-------------------------------------------------------------------------------
// Module: adder
// Description:
//   Computes the next instruction address by adding +4 or +2 to the
//   current instruction address.
//
// Assumptions:
//   - constant_operand represents a small unsigned increment +4 or +2
//   - constant_operand is zero-extended to DATA_WIDTH before addition
//-------------------------------------------------------------------------------
module adder #(parameter DATA_WIDTH = 32)(
    input  wire [2:0] constant_operand,
    input  wire [DATA_WIDTH-1:0] instruction_addr,
    output wire [DATA_WIDTH-1:0] next_instruction
);

// Zero extension of constant_operand
wire [DATA_WIDTH-1:0] const_ext;
assign const_ext = {{(DATA_WIDTH-3){1'b0}}, constant_operand};

assign next_instruction = instruction_addr + const_ext;

endmodule