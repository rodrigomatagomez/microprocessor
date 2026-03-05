`timescale 1ns / 1ps

// En Verilog no existen packages, por lo que se usa include
`include "riscv_params.vh"

//------------------------------------------------------------------------------
// Module: branch
// Description:
//   Branch decision logic for equality-based branch instructions.
//   Determines whether a branch should be taken based on register comparison.
//------------------------------------------------------------------------------

module branch #(parameter DATA_WIDTH_BRANCH = 32)(
    input  wire [DATA_WIDTH_BRANCH-1:0] rs_1,
    input  wire [DATA_WIDTH_BRANCH-1:0] rs_2,
    input  wire [6:0] opcode,
    input  wire [2:0] funct_3,
    output reg  branch_taken
);

always @(*) begin
    branch_taken = 1'b0;

    if (opcode == OPCODE_B_TYPE) begin
        case (funct_3)

            F3_BEQ:  branch_taken = (rs_1 == rs_2);

            F3_BNE:  branch_taken = (rs_1 != rs_2);

            F3_BLT:  branch_taken = ($signed(rs_1) < $signed(rs_2));

            F3_BGE:  branch_taken = ($signed(rs_1) >= $signed(rs_2));

            F3_BLTU: branch_taken = (rs_1 < rs_2);

            F3_BGEU: branch_taken = (rs_1 >= rs_2);

            default: branch_taken = 1'b0;

        endcase
    end
end

endmodule