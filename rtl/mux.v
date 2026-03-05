`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Module: mux
// Description:
//   Parameterized 2-to-1 combinational multiplexer.
//
// Notes:
//   - sel = 0 -> out = in2
//   - sel = 1 -> out = in1
//------------------------------------------------------------------------------

module mux #(
    parameter WIDTH = 32
)(
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire             sel,
    output wire [WIDTH-1:0] out
);

    assign out = sel ? in1 : in2;

endmodule