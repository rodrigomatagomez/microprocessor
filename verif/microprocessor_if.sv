//`include "defines.svh"
interface microprocessor_if #(int DATA_W = 32, int DIR_W = 5) (input logic clk);

typedef enum logic [5:0] {
    M_UNKNOWN = 6'd1,

    // Immediate / control
    I_ADDI    = 6'd2,
    U_LUI     = 6'd3,
    U_AUIPC   = 6'd4,
    J_JAL     = 6'd5,

    // Branches
    B_BEQ     = 6'd6,
    B_BNE     = 6'd7,
    B_BLT     = 6'd8,
    B_BGE     = 6'd9,
    B_BLTU    = 6'd10,
    B_BGEU    = 6'd11,

    // Loads
    L_LB      = 6'd12,
    L_LH      = 6'd13,
    L_LW      = 6'd14,
    L_LBU     = 6'd15,
    L_LHU     = 6'd16,

    // Stores
    S_SB      = 6'd17,
    S_SH      = 6'd18,
    S_SW      = 6'd19,

    // I-type ALU
    I_SLTI    = 6'd20,
    I_SLTIU   = 6'd21,
    I_XORI    = 6'd22,
    I_ORI     = 6'd23,
    I_ANDI    = 6'd24,

    // R-type ALU
    R_ADD     = 6'd25,
    R_SUB     = 6'd26,
    R_SLL     = 6'd27,
    R_SLT     = 6'd28,
    R_SLTU    = 6'd29,
    R_XOR     = 6'd30,
    R_SRL     = 6'd31,
    R_SRA     = 6'd32,
    R_OR      = 6'd33,
    R_AND     = 6'd34
} opcode_kind_enum;

  
opcode_kind_enum actual_instruction;
  
  //  ===============================================
  //  SIGNALS 
  //  ===============================================

  //  =============================================== 
  //  IF (Instruction Fetch)
  logic [DATA_W-1:0]  pc_q;
  logic [DATA_W-1:0]  pc_next;
  logic [DATA_W-1:0]  pc_plus_inc;
  logic               branch_taken;
  logic [DATA_W-1:0]  branch_target;
  logic 	          instruction_sel;
  logic [DATA_W-1:0]  instruction;
  
  //    =============================================
  //    Control Unit 
  logic [6:0]         opcode;
  logic [2:0]         funct_3;
  logic [6:0]         funct_7;  
  //  ==============================================
  //  ID/WB (Instruction Decode/Write Back)
  logic                   rf_we;
  logic [DATA_W:0]        x0;
  logic [DIR_W-1:0]       rs1, rs2, rd;
  logic [DATA_W-1:0]      rs1_data, rs2_data;
  logic [DATA_W-1:0]      wb_data;
  logic [1:0]             wb_sel;
  
  //  ===============================================
  //  IMM/EX (Immediate/Execute)
  logic [2:0]         imm_sel;
  logic [DATA_W-1:0]  imm;
  logic [1:0]         op1_sel_pc;
  logic               op2_sel_imm;
  logic [3:0]         alu_ctrl;
  logic [DATA_W-1:0]  alu_op1, alu_op2, alu_result;
  logic               b_condition_rs1_rs2;

  //  ==============================================
  // MEM  (Data Memory)
  logic               dmem_we;
  logic [DATA_W-1:0]  dmem_addr;
  logic [DATA_W-1:0]  dmem_wdata;
  logic [DATA_W-1:0]  dmem_rdata;
  //==============================================
//==============================================
// Decode opcode -> enum for waveform visibility
always_comb begin
    actual_instruction = M_UNKNOWN;
  priority casez ({instruction[31:25], instruction[14:12], instruction[6:0]})

    // U / J
    {7'b???_????, 3'b???, OPCODE_U_LUI}   : actual_instruction = U_LUI;
    {7'b???_????, 3'b???, OPCODE_U_AUIPC}: actual_instruction =  U_AUIPC;
    {7'b???_????, 3'b???, OPCODE_JAL_TYPE}: actual_instruction = J_JAL;

    // Branches
    {7'b???_????, BEQ,  OPCODE_B_TYPE}: actual_instruction = B_BEQ;
    {7'b???_????, BNE,  OPCODE_B_TYPE}: actual_instruction = B_BNE;
    {7'b???_????, BLT,  OPCODE_B_TYPE}: actual_instruction = B_BLT;
    {7'b???_????, BGE,  OPCODE_B_TYPE}: actual_instruction = B_BGE;
    {7'b???_????, BLTU, OPCODE_B_TYPE}: actual_instruction = B_BLTU;
    {7'b???_????, BGEU, OPCODE_B_TYPE}: actual_instruction = B_BGEU;

    // Loads
    {7'b???_????, LB,  OPCODE_L_TYPE}: actual_instruction = L_LB;
    {7'b???_????, LH,  OPCODE_L_TYPE}: actual_instruction = L_LH;
    {7'b???_????, LW,  OPCODE_L_TYPE}: actual_instruction = L_LW;
    {7'b???_????, LBU, OPCODE_L_TYPE}: actual_instruction = L_LBU;
    {7'b???_????, LHU, OPCODE_L_TYPE}: actual_instruction = L_LHU;

    // Stores
    {7'b???_????, SB, OPCODE_S_TYPE}: actual_instruction = S_SB;
    {7'b???_????, SH, OPCODE_S_TYPE}: actual_instruction = S_SH;
    {7'b???_????, SW, OPCODE_S_TYPE}: actual_instruction = S_SW;
    
    // I-type ALU
    {7'b???_????, ADDI,  OPCODE_I_TYPE}: actual_instruction = I_ADDI;
    {7'b???_????, SLTI,  OPCODE_I_TYPE}: actual_instruction = I_SLTI;
    {7'b???_????, SLTIU, OPCODE_I_TYPE}: actual_instruction = I_SLTIU;
    {7'b???_????, XORI,  OPCODE_I_TYPE}: actual_instruction = I_XORI;
    {7'b???_????, ORI,   OPCODE_I_TYPE}: actual_instruction = I_ORI;
    {7'b???_????, ANDI,  OPCODE_I_TYPE}: actual_instruction = I_ANDI;

    // R-type ALU
    {7'b0000_000, ADD,   OPCODE_R_TYPE}: actual_instruction = R_ADD;
    {7'b0100_000, SUB,   OPCODE_R_TYPE}: actual_instruction = R_SUB;
    {7'b0000_000, SLL,   OPCODE_R_TYPE}: actual_instruction = R_SLL;
    {7'b0000_000, SLT,   OPCODE_R_TYPE}: actual_instruction = R_SLT;
    {7'b0000_000, SLTU,  OPCODE_R_TYPE}: actual_instruction = R_SLTU;
    {7'b0000_000, XOR_,  OPCODE_R_TYPE}: actual_instruction = R_XOR;
    {7'b0000_000, SRL,   OPCODE_R_TYPE}: actual_instruction = R_SRL;
    {7'b0100_000, SRA,   OPCODE_R_TYPE}: actual_instruction = R_SRA;
    {7'b0000_000, OR_,   OPCODE_R_TYPE}: actual_instruction = R_OR;
    {7'b0000_000, AND_,  OPCODE_R_TYPE}: actual_instruction = R_AND;

    default: actual_instruction = M_UNKNOWN;

  endcase
end

  //  ==============================================
  //  Clocking for instructions
  clocking cb @(posedge clk);
    default input #1step output #1step;
    input actual_instruction;
    input pc_q, pc_next, pc_plus_inc;
    input branch_taken, branch_target, instruction, instruction_sel; 
    
    input funct_3, opcode, funct_7;  //Control Unit 

    input rf_we, rs1, rs2, rd, x0;
    input rs1_data, rs2_data, wb_data, wb_sel;

    input imm_sel, imm;
    input op1_sel_pc, op2_sel_imm;
    input alu_ctrl, alu_op1, alu_op2, alu_result;
    input b_condition_rs1_rs2;

    input dmem_we, dmem_addr, dmem_wdata, dmem_rdata;
  endclocking

  modport monitor (clocking cb);


endinterface 
 
