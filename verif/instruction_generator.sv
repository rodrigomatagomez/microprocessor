typedef enum logic [5:0] {
  M_UNKNOWN  = 6'd0,
  M_NOP      = 6'd1,

  // Immediate / control
  I_ADDI     = 6'd2,
  U_LUI      = 6'd3,
  U_AUIPC    = 6'd4,
  J_JAL      = 6'd5,

  // Branches
  B_BEQ      = 6'd6,
  B_BNE      = 6'd7,
  B_BLT      = 6'd8,
  B_BGE      = 6'd9,
  B_BLTU     = 6'd10,
  B_BGEU     = 6'd11,

  // Loads
  L_LB       = 6'd12,
  L_LH       = 6'd13,
  L_LW       = 6'd14,
  L_LBU      = 6'd15,
  L_LHU      = 6'd16,

  // Stores
  S_SB       = 6'd17,
  S_SH       = 6'd18,
  S_SW       = 6'd19,

  // I-type ALU
  I_SLTI     = 6'd20,
  I_SLTIU    = 6'd21,
  I_XORI     = 6'd22,
  I_ORI      = 6'd23,
  I_ANDI     = 6'd24,

  // R-type ALU
  R_ADD      = 6'd25,
  R_SUB      = 6'd26,
  R_SLL      = 6'd27,
  R_SLT      = 6'd28,
  R_SLTU     = 6'd29,
  R_XOR      = 6'd30,
  R_SRL      = 6'd31,
  R_SRA      = 6'd32,
  R_OR       = 6'd33,
  R_AND      = 6'd34,
  R_MUL      = 6'd35,
  R_MULH     = 6'd36
}riscv32_kind_enum;

class riscv32_rand_instruction; 

  rand riscv32_kind_enum kind;
  rand logic [4:0] rs1, rs2, rd;
  rand logic signed [11:0] imm_i;
  rand logic signed [11:0] imm_s;
  rand logic signed [12:0] imm_b;
  rand logic        [19:0] imm_u;
  rand logic signed [20:0] imm_j;
 
  //  ===========================
  //  BASE CONSTRAINTS
  //  ===========================
  
  // limit prf registers directions
  constraint c_regs {
    rs1 inside {[0:31]};
    rs2 inside {[0:31]};
    rd  inside {[0:31]};
  }

  // limit immediate ranges 
  constraint c_imm_range {
    imm_i inside {[-2048:2047]};
    imm_s inside {[-2048:2047]};
    imm_b inside {[-4096:4095]};
    imm_j inside {[-1048576:1048575]};
  }

  // Clean fields that are not used in some instructions 
  constraint c_format_clean {

    // Stores: rd is not used
    (kind inside {S_SB, S_SH, S_SW}) -> (rd == '0);

    // Branches: rd is not used
    (kind inside {B_BEQ, B_BNE, B_BLT, B_BGE, B_BLTU, B_BGEU}) -> (rd == '0 && imm_b % 4 == 0);

    // LUI/AUIPC: rs1/rs2 not used
    (kind inside {U_LUI, U_AUIPC}) -> (rs1 == '0 && rs2 == '0);

    // JAL: rs1/rs2 not used
    (kind == J_JAL) -> (rs1 == '0 && rs2 == '0 && imm_j % 4 == 0);

    // NOP: keep everything clean
    (kind == M_NOP) -> (rd == '0 && rs1 == '0 && rs2 == '0 &&
                        imm_i == '0 && imm_s == '0 && imm_b == '0 &&
                        imm_u == '0 && imm_j == '0);
  }
  // Create a directed item for a given kind
  function automatic void set_kind_directed(input riscv32_kind_enum k);
    kind = k;

    // Simple defaults
    rs1   = 5'd1;
    rs2   = 5'd2;
    rd    = 5'd3;

    imm_i = 12'sd4;
    imm_s = 12'sd8;
    imm_b = 13'sd4;      // multiple of 4
    imm_u = 20'h00010;
    imm_j = 21'sd4;      // multiple of 4
  endfunction



  function string s_print();
    return $sformatf("kind=%0d rs1=%0d rs2=%0d rd=%0d", kind, rs1, rs2, rd);
  endfunction
  
endclass
