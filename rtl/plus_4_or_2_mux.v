`timescale 1ns / 1ps
//------------------------------------------------------------------------------------------
// Module: plus_4_or_2_mux
// Description:
//   Selects the instruction address increment value based on control logic.
//
//   sel = 0 -> +4
//   sel = 1 -> +2
//------------------------------------------------------------------------------------------

module plus_4_or_2_mux(
    input  wire       sel,
    output reg  [2:0] instruction_add
);

always @(*) begin
    case (sel)
        1'b0: instruction_add = 3'b100; // +4 increment
        1'b1: instruction_add = 3'b010; // +2 increment
        default: instruction_add = 3'b000;
    endcase
end

endmodule