module instr_kind_decode_for_waves
(
  microprocessor_if.monitor vif
);

  typedef enum logic [5:0] {
    M_UNKNOWN = 6'd0,
    M_NOP     = 6'd1,

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
    R_AND     = 6'd34,
    R_MUL     = 6'd35
  } opcode_kind_enum;

  // Expose this variable so it shows in waves
  opcode_kind_enum actual_instruction;

  // RV32I opcodes
  localparam logic [6:0] OPCODE_R     = 7'b0110011;
  localparam logic [6:0] OPCODE_I     = 7'b0010011;
  localparam logic [6:0] OPCODE_L     = 7'b0000011;
  localparam logic [6:0] OPCODE_S     = 7'b0100011;
  localparam logic [6:0] OPCODE_B     = 7'b1100011;
  localparam logic [6:0] OPCODE_LUI   = 7'b0110111;
  localparam logic [6:0] OPCODE_AUIPC = 7'b0010111;
  localparam logic [6:0] OPCODE_JAL   = 7'b1101111;

  // funct3 values used
  localparam logic [2:0] F3_ADD_SUB_MUL = 3'b000;
  localparam logic [2:0] F3_SLL     = 3'b001;
  localparam logic [2:0] F3_SLT     = 3'b010;
  localparam logic [2:0] F3_SLTU    = 3'b011;
  localparam logic [2:0] F3_XOR     = 3'b100;
  localparam logic [2:0] F3_SRL_SRA = 3'b101;
  localparam logic [2:0] F3_OR      = 3'b110;
  localparam logic [2:0] F3_AND     = 3'b111;

  localparam logic [2:0] F3_BEQ  = 3'b000;
  localparam logic [2:0] F3_BNE  = 3'b001;
  localparam logic [2:0] F3_BLT  = 3'b100;
  localparam logic [2:0] F3_BGE  = 3'b101;
  localparam logic [2:0] F3_BLTU = 3'b110;
  localparam logic [2:0] F3_BGEU = 3'b111;

  localparam logic [2:0] F3_LB  = 3'b000;
  localparam logic [2:0] F3_LH  = 3'b001;
  localparam logic [2:0] F3_LW  = 3'b010;
  localparam logic [2:0] F3_LBU = 3'b100;
  localparam logic [2:0] F3_LHU = 3'b101;

  localparam logic [2:0] F3_SB  = 3'b000;
  localparam logic [2:0] F3_SH  = 3'b001;
  localparam logic [2:0] F3_SW  = 3'b010;

  always_comb begin
    actual_instruction = M_UNKNOWN;

    // Detect NOP (ADDI x0,x0,0)
    if (vif.instruction == 32'h0000_0013) begin
      actual_instruction = M_NOP;
    end
    else begin
      unique casez (vif.instruction[6:0])

        OPCODE_LUI:   actual_instruction = U_LUI;
        OPCODE_AUIPC: actual_instruction = U_AUIPC;
        OPCODE_JAL:   actual_instruction = J_JAL;

        OPCODE_B: begin
          unique case (vif.instruction[14:12])
            F3_BEQ:  actual_instruction = B_BEQ;
            F3_BNE:  actual_instruction = B_BNE;
            F3_BLT:  actual_instruction = B_BLT;
            F3_BGE:  actual_instruction = B_BGE;
            F3_BLTU: actual_instruction = B_BLTU;
            F3_BGEU: actual_instruction = B_BGEU;
            default: actual_instruction = M_UNKNOWN;
          endcase
        end

        OPCODE_L: begin
          unique case (vif.instruction[14:12])
            F3_LB:  actual_instruction = L_LB;
            F3_LH:  actual_instruction = L_LH;
            F3_LW:  actual_instruction = L_LW;
            F3_LBU: actual_instruction = L_LBU;
            F3_LHU: actual_instruction = L_LHU;
            default: actual_instruction = M_UNKNOWN;
          endcase
        end

        OPCODE_S: begin
          unique case (vif.instruction[14:12])
            F3_SB: actual_instruction = S_SB;
            F3_SH: actual_instruction = S_SH;
            F3_SW: actual_instruction = S_SW;
            default: actual_instruction = M_UNKNOWN;
          endcase
        end

        OPCODE_I: begin
          unique case (vif.instruction[14:12])
            F3_ADD_SUB_MUL: actual_instruction = I_ADDI;
            F3_SLT:         actual_instruction = I_SLTI;
            F3_SLTU:        actual_instruction = I_SLTIU;
            F3_XOR:         actual_instruction = I_XORI;
            F3_OR:          actual_instruction = I_ORI;
            F3_AND:         actual_instruction = I_ANDI;
            default:        actual_instruction = M_UNKNOWN;
          endcase
        end

        OPCODE_R: begin
          unique case (vif.instruction[14:12])
            F3_ADD_SUB_MUL: begin
              if (vif.instruction[31:25] == 7'b0100_000) begin 
                actual_instruction = R_SUB;
              end else if (vif.instruction[31:25] == 7'b0000_001) begin 
                actual_instruction = R_MUL;
              end else begin 
                actual_instruction = R_ADD;
              end
            end
            F3_SLL:  actual_instruction = R_SLL;
            F3_SLT:  actual_instruction = R_SLT;
            F3_SLTU: actual_instruction = R_SLTU;
            F3_XOR:  actual_instruction = R_XOR;
            F3_SRL_SRA: begin
              if (vif.instruction[31:25] == 7'b0100_000) begin 
                actual_instruction = R_SRA;
              end else begin 
                actual_instruction = R_SRL;
              end
            end
            F3_OR:   actual_instruction = R_OR;
            F3_AND:  actual_instruction = R_AND;
            default: actual_instruction = M_UNKNOWN;
          endcase
        end

        default: actual_instruction = M_UNKNOWN;
      endcase
    end
  end

endmodule

