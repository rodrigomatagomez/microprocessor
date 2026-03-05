`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Module: mux_operand_1
// Description:
//   3-to-1 multiplexer used to select ALU operand 1.
//
// Inputs:
//   - in1 : zero operand
//   - in2 : PC value
//   - in3 : rs1 register value
//
// Control:
//   sel = 00 -> in1
//   sel = 01 -> in2
//   sel = 10 -> in3
//------------------------------------------------------------------------------

module mux_operand_1 (
    input  wire [31:0] in1,
    input  wire [31:0] in2,
    input  wire [31:0] in3,
    input  wire [1:0]  sel,
    output reg  [31:0] data_out
);

always @(*) begin
    case (sel)
        2'b00: data_out = in1; // zero operand
        2'b01: data_out = in2; // PC
        2'b10: data_out = in3; // rs1
        default: data_out = {32{1'b0}};
    endcase
end

endmodule