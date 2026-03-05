// include/riscv_params.vh
`ifndef RISCV_PARAMS_VH
`define RISCV_PARAMS_VH

// -----------------------------
// Datapath sizing
// -----------------------------
`define DIR_WIDTH   5
`define DATA_WIDTH  32
`define DEPTH       1024

// Memory indexing
`define MEM_ADDR_W  10     // log2(DEPTH)
`define BYTE_WIDTH  8

// -----------------------------
// RV32I opcodes
// -----------------------------
`define OPCODE_R_TYPE     7'b0110011
`define OPCODE_I_TYPE     7'b0010011
`define OPCODE_L_TYPE     7'b0000011
`define OPCODE_S_TYPE     7'b0100011
`define OPCODE_B_TYPE     7'b1100011
`define OPCODE_U_LUI      7'b0110111
`define OPCODE_U_AUIPC    7'b0010111
`define OPCODE_JAL_TYPE   7'b1101111

// -----------------------------
// funct3 (grouped)
// -----------------------------
`define F3_ADD_SUB  3'b000
`define F3_SLL      3'b001
`define F3_SLT      3'b010
`define F3_SLTU     3'b011
`define F3_XOR      3'b100
`define F3_SRL_SRA  3'b101
`define F3_OR       3'b110
`define F3_AND      3'b111

`define F3_BEQ      3'b000
`define F3_BNE      3'b001
`define F3_BLT      3'b100
`define F3_BGE      3'b101
`define F3_BLTU     3'b110
`define F3_BGEU     3'b111

`define F3_LB       3'b000
`define F3_LH       3'b001
`define F3_LW       3'b010
`define F3_LBU      3'b100
`define F3_LHU      3'b101

`define F3_SB       3'b000
`define F3_SH       3'b001
`define F3_SW       3'b010

// -----------------------------
// ALU control encodings
// -----------------------------
`define ALU_ADD     4'b0000
`define ALU_SUB     4'b0001
`define ALU_AND     4'b0010
`define ALU_OR      4'b0011
`define ALU_XOR     4'b0100
`define ALU_EQ      4'b0101
`define ALU_SLT     4'b0110
`define ALU_SLTU    4'b0111
`define ALU_SLL     4'b1000
`define ALU_SRL     4'b1001
`define ALU_SRA     4'b1010

// -----------------------------
// Immediate select encodings
// -----------------------------
`define IMM_I       3'b000
`define IMM_S       3'b001
`define IMM_B       3'b010
`define IMM_U       3'b011
`define IMM_J       3'b100

// -----------------------------
// Writeback mux select
// -----------------------------
`define ALU_TO_PRF           2'b00
`define DATA_OUT_TO_PRF      2'b01
`define INSTRUCTION_TO_PRF   2'b10

// -----------------------------
// PC add select (si lo usas luego)
// -----------------------------
`define PC_4        2'b00
`define PC_BRANCH   2'b01
`define PC_JAL      2'b10

`endif