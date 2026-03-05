// include/riscv_params_lp.vh
// Uso: incluir DENTRO de un module, después del encabezado de puertos.
`ifndef RISCV_PARAMS_VH
`define RISCV_PARAMS_VH

localparam DIR_WIDTH  = 5;
localparam DATA_WIDTH = 32;
localparam DEPTH      = 1024;

localparam MEM_ADDR_W = 10;
localparam BYTE_WIDTH = 8;

// -----------------------------
// RV32I opcodes
// -----------------------------
localparam [6:0] OPCODE_R_TYPE   = 7'b0110011;
localparam [6:0] OPCODE_I_TYPE   = 7'b0010011;
localparam [6:0] OPCODE_L_TYPE   = 7'b0000011;
localparam [6:0] OPCODE_S_TYPE   = 7'b0100011;
localparam [6:0] OPCODE_B_TYPE   = 7'b1100011;
localparam [6:0] OPCODE_U_LUI    = 7'b0110111;
localparam [6:0] OPCODE_U_AUIPC  = 7'b0010111;
localparam [6:0] OPCODE_JAL_TYPE = 7'b1101111;

// -----------------------------
// funct3
// -----------------------------
localparam [2:0] F3_ADD_SUB = 3'b000;
localparam [2:0] F3_SLL     = 3'b001;
localparam [2:0] F3_SLT     = 3'b010;
localparam [2:0] F3_SLTU    = 3'b011;
localparam [2:0] F3_XOR     = 3'b100;
localparam [2:0] F3_SRL_SRA = 3'b101;
localparam [2:0] F3_OR      = 3'b110;
localparam [2:0] F3_AND     = 3'b111;

// Branch
localparam [2:0] F3_BEQ  = 3'b000;
localparam [2:0] F3_BNE  = 3'b001;
localparam [2:0] F3_BLT  = 3'b100;
localparam [2:0] F3_BGE  = 3'b101;
localparam [2:0] F3_BLTU = 3'b110;
localparam [2:0] F3_BGEU = 3'b111;

// Load
localparam [2:0] F3_LB  = 3'b000;
localparam [2:0] F3_LH  = 3'b001;
localparam [2:0] F3_LW  = 3'b010;
localparam [2:0] F3_LBU = 3'b100;
localparam [2:0] F3_LHU = 3'b101;

// Store
localparam [2:0] F3_SB = 3'b000;
localparam [2:0] F3_SH = 3'b001;
localparam [2:0] F3_SW = 3'b010;

// -----------------------------
// ALU control
// -----------------------------
localparam [3:0] ALU_ADD  = 4'b0000;
localparam [3:0] ALU_SUB  = 4'b0001;
localparam [3:0] ALU_AND  = 4'b0010;
localparam [3:0] ALU_OR   = 4'b0011;
localparam [3:0] ALU_XOR  = 4'b0100;
localparam [3:0] ALU_EQ   = 4'b0101;
localparam [3:0] ALU_SLT  = 4'b0110;
localparam [3:0] ALU_SLTU = 4'b0111;
localparam [3:0] ALU_SLL  = 4'b1000;
localparam [3:0] ALU_SRL  = 4'b1001;
localparam [3:0] ALU_SRA  = 4'b1010;

// -----------------------------
// Immediate select
// -----------------------------
localparam [2:0] IMM_I = 3'b000;
localparam [2:0] IMM_S = 3'b001;
localparam [2:0] IMM_B = 3'b010;
localparam [2:0] IMM_U = 3'b011;
localparam [2:0] IMM_J = 3'b100;

// -----------------------------
// Writeback mux select
// -----------------------------
localparam [1:0] ALU_TO_PRF         = 2'b00;
localparam [1:0] DATA_OUT_TO_PRF    = 2'b01;
localparam [1:0] INSTRUCTION_TO_PRF = 2'b10;

// -----------------------------
// PC select (si lo usas luego)
// -----------------------------
localparam [1:0] PC_4      = 2'b00;
localparam [1:0] PC_BRANCH = 2'b01;
localparam [1:0] PC_JAL    = 2'b10;

`endif