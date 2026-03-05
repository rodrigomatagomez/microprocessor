`timescale 1ns / 1ps

// En Verilog no hay "package/import". Aquí se asume que tus códigos ALU_*
// viven en un header con `define o localparam.
`include "riscv_params.vh"
// o: `include "defines.vh"

module alu #(
    parameter OPERAND_WIDTH = 32
)(
    input  wire [OPERAND_WIDTH-1:0] operand1,
    input  wire [OPERAND_WIDTH-1:0] operand2,
    input  wire [3:0]               alucontrol,
    output reg  [OPERAND_WIDTH-1:0] alu_result
);

    // Comparaciones (1 bit) para luego extenderlas a OPERAND_WIDTH
    wire eq_bit;
    wire slt_bit;
    wire sltu_bit;

    assign eq_bit   = (operand1 == operand2);
    assign slt_bit  = ($signed(operand1) < $signed(operand2));
    assign sltu_bit = (operand1 < operand2);

    always @(*) begin
        case (alucontrol)
            ALU_ADD:  alu_result = operand1 + operand2;
            ALU_SUB:  alu_result = operand1 - operand2;
            ALU_AND:  alu_result = operand1 & operand2;
            ALU_OR:   alu_result = operand1 | operand2;
            ALU_XOR:  alu_result = operand1 ^ operand2;

            // ------------------------------------------------------------
            // Resultados tipo "set": cero-extendidos (solo LSB = 1)
            // ------------------------------------------------------------
            ALU_EQ:   alu_result = {{(OPERAND_WIDTH-1){1'b0}}, eq_bit};
            ALU_SLT:  alu_result = {{(OPERAND_WIDTH-1){1'b0}}, slt_bit};
            ALU_SLTU: alu_result = {{(OPERAND_WIDTH-1){1'b0}}, sltu_bit};

            ALU_SLL:  alu_result = operand1 << operand2[4:0];
            ALU_SRL:  alu_result = operand1 >> operand2[4:0];
            ALU_SRA:  alu_result = $signed(operand1) >>> operand2[4:0];

            default:  alu_result = {OPERAND_WIDTH{1'b0}};
        endcase
    end

endmodule