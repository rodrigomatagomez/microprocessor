typedef enum logic [5:0] {
  M_UNKNOWN  = 6'd0,
  M_NOP      = 6'd1,

  // Immediate / control
  M_ADDI     = 6'd2,
  M_LUI      = 6'd3,
  M_AUIPC    = 6'd4,
  M_JAL      = 6'd5,

  // Branches
  M_BEQ      = 6'd6,
  M_BNE      = 6'd7,
  M_BLT      = 6'd8,
  M_BGE      = 6'd9,
  M_BLTU     = 6'd10,
  M_BGEU     = 6'd11,

  // Loads
  M_LB       = 6'd12,
  M_LH       = 6'd13,
  M_LW       = 6'd14,
  M_LBU      = 6'd15,
  M_LHU      = 6'd16,

  // Stores
  M_SB       = 6'd17,
  M_SH       = 6'd18,
  M_SW       = 6'd19,

  // I-type ALU
  M_SLTI     = 6'd20,
  M_SLTIU    = 6'd21,
  M_XORI     = 6'd22,
  M_ORI      = 6'd23,
  M_ANDI     = 6'd24,

  // R-type ALU
  M_ADD      = 6'd25,
  M_SUB      = 6'd26,
  M_SLL      = 6'd27,
  M_SLT      = 6'd28,
  M_SLTU     = 6'd29,
  M_XOR      = 6'd30,
  M_SRL      = 6'd31,
  M_SRA      = 6'd32,
  M_OR       = 6'd33,
  M_AND      = 6'd34
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
    (kind inside {M_SB, M_SH, M_SW}) -> (rd == '0);

    // Branches: rd is not used
    (kind inside {M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU}) -> (rd == '0 && imm_b % 4 == 0);

    // LUI/AUIPC: rs1/rs2 not used
    (kind inside {M_LUI, M_AUIPC}) -> (rs1 == '0 && rs2 == '0);

    // JAL: rs1/rs2 not used
    (kind == M_JAL) -> (rs1 == '0 && rs2 == '0 && imm_j % 4 == 0);

    // NOP: keep everything clean
    (kind == M_NOP) -> (rd == '0 && rs1 == '0 && rs2 == '0 &&
                        imm_i == '0 && imm_s == '0 && imm_b == '0 &&
                        imm_u == '0 && imm_j == '0);
  }


  function string s_print();
    return $sformatf("kind=%0d rs1=%0d rs2=%0d rd=%0d", kind, rs1, rs2, rd);
  endfunction
  
endclass
