`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Module: control_unit
// Description:
//   Combinational control unit for a single-cycle RV32I-style datapath.
//------------------------------------------------------------------------------
`include "riscv_params.vh"

module control_unit(
    input  wire [6:0]  opcode,             // instr[6:0]
    input  wire [2:0]  funct_3,            // instr[14:12]
    input  wire [6:0]  funct_7,            // instr[31:25]
    input  wire        zero,               // 1 when rs1 == rs2 (BEQ condition)

    output reg         prf_wr_en,           // register file write enable
    output reg  [2:0]  cu_imm_sel,          // immediate format select (imm_gen)
    output reg  [1:0]  prf_pc_mux_ctrl,     // ALU operand1 select (rs1 vs PC)
    output reg         prf_imm_mux_ctrl,    // ALU operand2 select (rs2 vs imm)
    output reg  [3:0]  cu_alu_ctrl,         // ALU operation select
    output reg  [1:0]  cu_mem_out_mux_sel,  // write-back mux select (to PRF)
    output reg         cu_data_mem_wr_en,   // data memory write enable (stores)
    output reg         cu_pc_add_sel,       // PC increment select (+4 now; +2 reserved)
    output reg         branch_taken         // PC redirect request (branch/jump)
);

    always @(*) begin
        //-------------------------------------------------------------------------
        // Defaults: I-type ALU-immediate behavior
        //-------------------------------------------------------------------------
        prf_wr_en          = 1'b1;
        cu_data_mem_wr_en  = 1'b0;
        cu_imm_sel         = IMM_I;
        prf_pc_mux_ctrl    = 2'b10;        // operand1 = rs1
        prf_imm_mux_ctrl   = 1'b1;         // operand2 = imm
        cu_pc_add_sel      = 1'b0;         // +4
        cu_mem_out_mux_sel = ALU_TO_PRF;   // write-back = ALU result
        cu_alu_ctrl        = ALU_ADD;
        branch_taken       = 1'b0;

        case (opcode)

            // I-type ALU-immediate ops: rd <- rs1 op imm
            OPCODE_I_TYPE: begin
                case (funct_3)
                    F3_ADD_SUB: cu_alu_ctrl = ALU_ADD;
                    F3_SLL:     cu_alu_ctrl = ALU_SLT;   // (ojo: así lo tenías en SV)
                    F3_SLTU:    cu_alu_ctrl = ALU_SLTU;
                    F3_XOR:     cu_alu_ctrl = ALU_XOR;
                    F3_OR:      cu_alu_ctrl = ALU_OR;
                    F3_AND:     cu_alu_ctrl = ALU_AND;
                    default:    cu_alu_ctrl = ALU_ADD;
                endcase
            end

            // B-type branch
            OPCODE_B_TYPE: begin
                prf_wr_en       = 1'b0;
                cu_imm_sel      = IMM_B;
                prf_pc_mux_ctrl = 2'b01;
                cu_alu_ctrl     = ALU_ADD;
                branch_taken    = zero;

                case (funct_3)
                    F3_BEQ:  ; // tal cual tu SV: no cambias branch_taken aquí
                    F3_BNE:  ;
                    F3_BLT:  ;
                    F3_BGE:  ;
                    F3_BLTU: ;
                    F3_BGEU: ;
                    default: begin
                        cu_alu_ctrl  = ALU_ADD;
                        branch_taken = 1'b0;
                    end
                endcase
            end

            // R-type ALU-register ops
            OPCODE_R_TYPE: begin
                prf_imm_mux_ctrl = 1'b0;

                if (funct_7 == 7'b0000_000) begin
                    case (funct_3)
                        F3_ADD_SUB:  cu_alu_ctrl = ALU_ADD;
                        F3_SLL:      cu_alu_ctrl = ALU_SLL;
                        F3_SLT:      cu_alu_ctrl = ALU_SLT;
                        F3_SLTU:     cu_alu_ctrl = ALU_SLTU;
                        F3_XOR:      cu_alu_ctrl = ALU_XOR;
                        F3_SRL_SRA:  cu_alu_ctrl = ALU_SRL;
                        F3_OR:       cu_alu_ctrl = ALU_OR;
                        F3_AND:      cu_alu_ctrl = ALU_AND;
                        default:     cu_alu_ctrl = ALU_ADD;
                    endcase
                end else if (funct_7 == 7'b0100_000) begin
                    case (funct_3)
                        F3_ADD_SUB:  cu_alu_ctrl = ALU_SUB;
                        F3_SRL_SRA:  cu_alu_ctrl = ALU_SRA;
                        default:     cu_alu_ctrl = ALU_ADD;
                    endcase
                end else begin
                    cu_alu_ctrl = ALU_ADD;
                end
            end

            // JAL
            OPCODE_JAL_TYPE: begin
                cu_imm_sel         = IMM_J;
                prf_pc_mux_ctrl    = 2'b01;
                cu_mem_out_mux_sel = INSTRUCTION_TO_PRF;
                cu_alu_ctrl        = ALU_ADD;
                branch_taken       = 1'b1;
            end

            // LOAD
            OPCODE_L_TYPE: begin
                cu_mem_out_mux_sel = DATA_OUT_TO_PRF;
                case (funct_3)
                    F3_LB:  ;
                    F3_LH:  ;
                    F3_LW:  ;
                    F3_LBU: ;
                    F3_LHU: ;
                    default: prf_wr_en = 1'b1;
                endcase
            end

            // STORE
            OPCODE_S_TYPE: begin
                prf_wr_en          = 1'b0;
                cu_mem_out_mux_sel = ALU_TO_PRF;
                cu_imm_sel         = IMM_S;
                cu_data_mem_wr_en  = 1'b1;
                case (funct_3)
                    F3_SB: ;
                    F3_SH: ;
                    F3_SW: ;
                    default: prf_wr_en = 1'b0;
                endcase
            end

            // LUI
            OPCODE_U_LUI: begin
                prf_pc_mux_ctrl = 2'b00;
                cu_imm_sel      = IMM_U;
            end

            // AUIPC
            OPCODE_U_AUIPC: begin
                prf_pc_mux_ctrl = 2'b01;
                cu_imm_sel      = IMM_U;
            end

            default: begin
                prf_wr_en    = 1'b0;
                cu_alu_ctrl  = ALU_ADD;
                branch_taken = 1'b0;
            end

        endcase
    end

endmodule