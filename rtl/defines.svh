`ifndef DEFINES_SVH
`define DEFINES_SVH
// =========================================================
// Raíz jerárquica del DUT
// =========================================================
`define DUT dut
// =========================================================
// IF
// =========================================================
`define PC_Q          `DUT.pc_i.pc_out
`define PC_NEXT       `DUT.pc_i.pc_in
`define PC_PLUS_INC   `DUT.pc_adder_i.next_instruction
`define BR_TAKEN      `DUT.cu_i.branch_taken
`define BR_TARGET     `DUT.upc_next_mux_i.sel

`define OPCODE        `DUT.cu_i.opcode
`define FUNCT3        `DUT.cu_i.funct_3
`define FUNCT7        `DUT.cu_i.funct_7
`define INSTR_WORD    `DUT.instruction
`define INSTR_SEL      drive_if.instr_en

// =========================================================
// ID/WB
// =========================================================
`define RF_WE         `DUT.prf_i.write_en
`define X0            `DUT.prf_i.prf[0]
`define RS1           `DUT.prf_i.read_dir1
`define RS2           `DUT.prf_i.read_dir2
`define RD            `DUT.prf_i.write_dir
`define RS1_DATA      `DUT.prf_i.read_data1
`define RS2_DATA      `DUT.prf_i.read_data2
`define WB_DATA       `DUT.prf_i.write_data
`define WB_SEL        `DUT.wb_mux_i.sel

// =========================================================
// IMM/EX
// =========================================================
`define IMM_SEL       `DUT.imm_gen_i.imm_sel
`define IMM           `DUT.imm_gen_i.imm_out

`define OP1_SEL_PC    `DUT.alu_op1_mux_i.sel
`define OP2_SEL_IMM   `DUT.alu_op2_mux_i.sel

`define ALU_CTRL      `DUT.alu_i.alucontrol
`define ALU_OP1       `DUT.alu_i.operand1
`define ALU_OP2       `DUT.alu_i.operand2
`define ALU_RES       `DUT.alu_i.alu_result

`define BCOND         `DUT.branch_cmp_i.branch_taken

// =========================================================
// MEM
// =========================================================
`define DMEM_WE       `DUT.data_mem_i.wr_en
`define DMEM_ADDR     `DUT.data_mem_i.addr
`define DMEM_WDATA    `DUT.data_mem_i.data_in
`define DMEM_RDATA    `DUT.data_mem_i.data_out

//////prf
localparam DIR_WIDTH = 5;
/////instruction memory
localparam DATA_WIDTH = 32;      // Ancho de instruccion (La instrucción completa mide 32 bits)
localparam ADDR_WIDTH = 10;      // Ancho de dirección del PC (El PC maneja direcciones de 32 bits)
localparam BYTE_WIDTH = 8;      // Ancho de cajón de la memoria (1 Byte)
localparam DEPTH  = 1024;      // Numero de renglones de memoria
///////////////////TYPE_R_INSTRUCTIONS////////////////////// 
localparam OPCODE_R_TYPE = 7'b011_0011;	//Type R-Instruction  ---
//TYPES OF OPERATIONS
localparam ADD   = 3'b000;
localparam SLL   = 3'b001;
localparam SLT   = 3'b010;
localparam SLTU  = 3'b011;
localparam XOR_  = 3'b100;
localparam SRL   = 3'b101;
localparam OR_   = 3'b110;
localparam AND_  = 3'b111;
localparam SRA   = 3'b101;
localparam SUB   = 3'b000;
////////////////////////////////////////////////////////////
///////////////////TYPE_I_INSTRUCTIONS////////////////////// 
localparam OPCODE_I_TYPE = 7'b001_0011;	//Type I-Instruction
//TYPES OF OPERATION
localparam ADDI  = 3'b000; //rd = rs1 + imm
localparam SLTI  = 3'b010; //rd = (rs1 < imm) signed
localparam SLTIU = 3'b011; //rd = (rs1 < imm) unsigned
localparam XORI  = 3'b100; //rd = rs1 XOR imm
localparam ORI   = 3'b110; //rd = rs1 OR imm
localparam ANDI  = 3'b111; //rd = rs1 AND imm
////////////////////////////////////////////////////////////
///////////////////TYPE_B_INSTRUCTIONS////////////////////// 
localparam OPCODE_B_TYPE = 7'b110_0011;	//Type B-Instruction  
//TYPES OF OPERATION
localparam BEQ = 3'b000;
localparam BNE = 3'b001;
localparam BLT = 3'b100;
localparam BGE = 3'b101;
localparam BLTU = 3'b110;
localparam BGEU = 3'b111;
////////////////////////////////////////////////////////////
///////////////////TYPE_I_INSTRUCTIONS//////////////////////
localparam OPCODE_JAL_TYPE = 7'b110_1111;	//Type JAL-Instruction
////////////////////////////////////////////////////////////
///////////////////TYPE_L_INSTRUCTIONS//////////////////////
localparam OPCODE_L_TYPE = 7'b000_0011;	//Type J-Instruction
//TYPES OF OPERATION
localparam LB   = 3'b000;
localparam LH   = 3'b001;
localparam LW   = 3'b010;
localparam LBU  = 3'b100;
localparam LHU  = 3'b101;
////////////////////////////////////////////////////////////
///////////////////TYPE_S_INSTRUCTIONS//////////////////////
localparam OPCODE_S_TYPE = 7'b010_0011;	//Type S-Instruction
//TYPES OF OPERATION
localparam SB   = 3'b000;
localparam SH   = 3'b001;
localparam SW   = 3'b010;
////////////////////////////////////////////////////////////
///////////////////TYPE_U_INSTRUCTIONS//////////////////////
localparam OPCODE_U_LUI = 7'b011_0111;	//Type I-Instruction
localparam OPCODE_U_AUIPC = 7'b001_0111;	//Type J-Instruction
//Define the intructions for ALU
localparam ALU_ADD =  4'b0000;	//ALU add operation
localparam ALU_SUB =  4'b0001;	//ALU sub operation
localparam ALU_AND =  4'b0010;	//ALU add operation
localparam ALU_OR =   4'b0011;	//ALU sub operation
localparam ALU_XOR =  4'b0100;	//ALU add operation
localparam ALU_EQ =   4'b0101;	//ALU add operation
localparam ALU_SLT =  4'b0110;	//ALU sub operation
localparam ALU_SLTU = 4'b0111;	//ALU add operation
localparam ALU_SLL =  4'b1000;	//ALU sub operation
localparam ALU_SRL =  4'b1001;	//ALU add operation
localparam ALU_SRA =  4'b1010;	//ALU sub operation
//define the imm instructions 
localparam IMM_I = 3'b000;   // Type I  (ADDI, LW, JALR, etc.)
localparam IMM_S = 3'b001;   // Type S  (SW, SH, SB)
localparam IMM_B = 3'b010;   // Type B  (BEQ, BNE, etc.)
localparam IMM_U = 3'b011;   // Type U  (LUI, AUIPC)
localparam IMM_J = 3'b100;   // Type J  (JAL) 
//define the directions of the mux for data memory
localparam ALU_TO_PRF = 2'b00;
localparam DATA_OUT_TO_PRF = 2'b01;
localparam INSTRUCTION_TO_PRF = 2'b10;

//define the PC count logic instructions 
localparam PC_4 = 2'b00;	//Add pc + 4
localparam PC_BRANCH = 2'b01; 	//Add pc + imm(value)
localparam PC_JAL = 2'b10;

`define AST(block=rca, name=no_name, precond=1'b1 |->, consq=1'b0) \
``block``_ast_``name``: assert property (@(posedge clk) disable iff(!arst_n) ``precond`` ``consq``);

`define ASM(block=rca, name=no_name, precond=1'b1 |->, consq=1'b0) \
``block``_ast_``name``: assume property (@(posedge clk) disable iff(!arst_n) ``precond`` ``consq``);

`define COV(block=rca, name=no_name, precond=1'b1 |->, consq=1'b0) \
``block``_ast_``name``: cover property (@(posedge clk) disable iff(!arst_n) ``precond`` ``consq``);

`endif // DEFINES_SVH
