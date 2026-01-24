//////prf
parameter DIR_WIDTH = 5;
/////instruction memory
parameter DATA_WIDTH = 32;      // Ancho de instruccion (La instrucción completa mide 32 bits)
parameter ADDR_WIDTH = 10;      // Ancho de dirección del PC (El PC maneja direcciones de 32 bits)
parameter BYTE_WIDTH = 8;      // Ancho de cajón de la memoria (1 Byte)
parameter DEPTH  = 1024;      // Numero de renglones de memoria
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
localparam ANDI  = 3'b111; //rd = rs1 AND imm`
////////////////////////////////////////////////////////////
///////////////////TYPE_B_INSTRUCTIONS////////////////////// 
localparam OPCODE_B_TYPE = 7'b110_0011;	//Type B-Instruction  
//TYPES OF OPERATION
localparam BEQ = 3'b000;
////////////////////////////////////////////////////////////
///////////////////TYPE_I_INSTRUCTIONS//////////////////////
localparam OPCODE_J_TYPE = 7'b110_1111;	//Type J-Instruction
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
localparam OPCODE_S_TYPE = 7'b010_0011;	//Type J-Instruction
//TYPES OF OPERATION
localparam SB   = 3'b000;
localparam SH   = 3'b001;
localparam SW   = 3'b010;
////////////////////////////////////////////////////////////
///////////////////TYPE_U_INSTRUCTIONS//////////////////////
localparam OPCODE_U_LUI = 7'b011_0111;	//Type J-Instruction
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

//just a prove to see if everything is well done in push

//another test
