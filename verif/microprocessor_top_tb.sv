`timescale 1ns/1ps
//`include "defines.svh"
//`include "instr_drive_if.sv"
//`include "microprocessor_if.sv"
//`include "instruction_generator.sv"

module microprocessor_top_tb;

  // ===========================================================================
  // Clock / Reset
  // ===========================================================================
  bit clk;
  bit arst_n;

  initial clk = 1'b0;
  always #5ns clk = ~clk;

  // Reset: hold low for 3 cycles
  initial begin
    arst_n = 1'b0;
    repeat (3) @(posedge clk);
    arst_n = 1'b1;
  end

  // ===========================================================================
  // Interfaces
  // ===========================================================================
  // Injection interface: drives instr_en/driven_instr
  instr_drive_if #(DATA_WIDTH) drive_if (clk);

  // Monitor interface: observes DUT internal/outputs via probe bridge
  microprocessor_if #(DATA_WIDTH, DIR_WIDTH) vif (clk);
  
  riscv32_rand_instruction tr;

  // ===========================================================================
  // DUT
  // ===========================================================================
  microprocessor_top dut (
    .clk          (clk),
    .arst_n       (arst_n),
    .instr_en     (drive_if.instr_en),
    .driven_instr (drive_if.driven_instr)
  );

  //bind microprocessor_top fv_microprocessor_top .(*) fv_microprocessor_top_i

  // ===========================================================================
  // DUT -> VIF "probe bridge"
  // ===========================================================================
  // IF
  assign vif.pc_q        = `PC_Q;
  assign vif.pc_next     = `PC_NEXT;
  assign vif.pc_plus_inc = `PC_PLUS_INC;
  assign vif.branch_taken  = `BR_TAKEN;
  assign vif.branch_target = `BR_TARGET;

  assign vif.opcode        = `OPCODE;
  assign vif.funct_3       = `FUNCT3;
  assign vif.funct_7       = `FUNCT7;
  assign vif.instruction   = `INSTR_WORD;
  
  assign vif.instruction_sel = `INSTR_SEL;

  // ID/WB
  assign vif.rf_we     = `RF_WE;
  assign vif.x0        = `X0;
  assign vif.rs1       = `RS1;
  assign vif.rs2       = `RS2;
  assign vif.rd        = `RD;
  assign vif.rs1_data  = `RS1_DATA;
  assign vif.rs2_data  = `RS2_DATA;
  assign vif.wb_data   = `WB_DATA;
  assign vif.wb_sel    = `WB_SEL;

  // IMM/EX
  assign vif.imm_sel     = `IMM_SEL;
  assign vif.imm         = `IMM;
  assign vif.op1_sel_pc  = `OP1_SEL_PC;
  assign vif.op2_sel_imm = `OP2_SEL_IMM;
  assign vif.alu_ctrl    = `ALU_CTRL;
  assign vif.alu_op1     = `ALU_OP1;
  assign vif.alu_op2     = `ALU_OP2;
  assign vif.alu_result  = `ALU_RES;
  assign vif.b_condition_rs1_rs2 = `BCOND;

  // MEM
  assign vif.dmem_we     = `DMEM_WE;
  assign vif.dmem_addr   = `DMEM_ADDR;
  assign vif.dmem_wdata  = `DMEM_WDATA;
  assign vif.dmem_rdata  = `DMEM_RDATA;

  // ===========================================================================
  // Initialize 
  // ===========================================================================
  initial begin : init_state
    for (int i = 1; i < 32; i++) begin
      dut.prf_i.prf[i] = '0;
    end

    for (int j = 0; j < DEPTH; j++) begin
      dut.data_mem_i.mem[j] = '0;
    end
  end

  // ===========================================================================
  // TEST_PROGRAM
  // ===========================================================================
  initial begin
    
    tr = new();
    // Wait reset release

      // Fully random among allowed kinds
      repeat (100_000_000) begin
        if (!tr.randomize()) $fatal("Randomize failed");
        //$display("[TB] %s", tr.s_print());
        drive_if.drive_item(tr);
      end
        
        // Run for enough cycles to complete the program
        @(posedge clk);
        $finish;
      end

    /*initial begin // Initial block to open shared memory and probe signals
		$shm_open("shm_db");
		$shm_probe("AS");
	end*/


//  =============================================================================================================
//  PC AND PRF
`AST (it, pc_aligned,
     1'b1 |->, (`PC_Q[1:0] == 2'b00)
)

`AST(it, next_instr,
    (`OPCODE inside{ OPCODE_R_TYPE, OPCODE_I_TYPE, OPCODE_U_LUI, OPCODE_U_AUIPC, OPCODE_L_TYPE, OPCODE_S_TYPE}) |->,
    (`PC_NEXT == `PC_Q + 3'b100)
)

`AST (it, x0_always_zero,
     1'b1 |->, (`X0 == '0)
) 
//  ===========================================================================================================
//  TYPE_I INSTRUCTIONS 
`AST (it, imm_I_type, 
     (`OPCODE == OPCODE_I_TYPE) |->, (`IMM_SEL == IMM_I)
)
                    
`AST(it, prf_we,
    (`OPCODE == OPCODE_I_TYPE) |->, (`RF_WE == 1'b1)
)
                    
`AST(it, pc_4,
    (`OPCODE == OPCODE_I_TYPE) |->, (`PC_NEXT == `PC_Q + 3'b100)
)                  
// =========================================================
// I-type: ADDI, SLTI, SLTIU, XORI, ORI, ANDI
// =========================================================

// ADDI: wb_data = op1 + op2
`AST(it, addi_result,
  ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == ADDI)) |->,
  (`WB_DATA == (`ALU_OP1 + `ALU_OP2))
)

// SLTI: wb_data = (signed(op1) < signed(op2)) ? 1 : 0
`AST(it, slti_result,
  ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == SLTI)) |->,
  (`WB_DATA == (($signed(`ALU_OP1) < $signed(`ALU_OP2)) ? 32'd1 : 32'd0))
)

// SLTIU: wb_data = (unsigned(op1) < unsigned(op2)) ? 1 : 0
`AST(it, sltiu_result,
  ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == SLTIU)) |->,
  (`WB_DATA == ((`ALU_OP1 < `ALU_OP2) ? 32'd1 : 32'd0))
)

// XORI: wb_data = op1 ^ op2
`AST(it, xori_result,
  ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == XORI)) |->,
  (`WB_DATA == (`ALU_OP1 ^ `ALU_OP2))
)

// ORI: wb_data = op1 | op2
`AST(it, ori_result,
  ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == ORI)) |->,
  (`WB_DATA == (`ALU_OP1 | `ALU_OP2))
)

// ANDI: wb_data = op1 & op2
`AST(it, andi_result,
  ((`OPCODE == OPCODE_I_TYPE) && (`FUNCT3 == ANDI)) |->,
  (`WB_DATA == (`ALU_OP1 & `ALU_OP2))
)
//  ===========================================================
//  R-type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
//  ==========================================================

//  SUB: wb_data = rs1 - rs2 
`AST(it, sub,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == SUB) && (`FUNCT7 == 7'b0100_000)) |->,
    (`WB_DATA == (`RS1_DATA - `RS2_DATA))
)

//  ADD: wb_data = rs1 + rs2 
`AST(it, add,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == SUB) && (`FUNCT7 == 7'b0100_000)) |->,
    (`WB_DATA == (`RS1_DATA - `RS2_DATA))
)

// SLL: wb_data = rs1 << rs2[4:0]
`AST(it, sll,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == SLL) && (`FUNCT7 == 7'b0000_000)) |->,
    (`WB_DATA == (`RS1_DATA << `RS2_DATA[4:0]))
)

// SLT: wb_data = rs1 < rs2
`AST(it, slt,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == SLT) && (`FUNCT7 == 7'b0000_000)) |->,
    ((`WB_DATA) == ($signed(`RS1_DATA) < $signed(`RS2_DATA) ? 32'd1 : 32'd0))
)

// SLTU: wb_data = rs1 < rs2 
`AST(it, sltu,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == SLTU) && (`FUNCT7 == 7'b0000_000)) |->,
    (`WB_DATA == (`RS1_DATA < `RS2_DATA ? 32'd1 : 32'd0) )
)

// XOR: wb_data = rs1 ^ rs2 
`AST(it, xor_,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == XOR_) && (`FUNCT7 == 7'b0000_000)) |->,
    (`WB_DATA == (`RS1_DATA ^ `RS2_DATA))
)

// SRL: wb_data = rs1 >> rs2[4:0]
`AST(it, srl,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == SRL) && (`FUNCT7 == 7'b0000_000)) |->,
    (`WB_DATA == (`RS1_DATA >> `RS2_DATA[4:0]))
)

// SRA: wb_data =  rs1 >>> rs2[4:0]
`AST(it, sra,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == SRA) && (`FUNCT7 == 7'b0100_000)) |->,
    ($signed(`WB_DATA) == ($signed(`RS1_DATA) >>> `RS2_DATA[4:0]) )
)

// OR: rs1 | rs2 
`AST(it, or_,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == OR_) && (`FUNCT7 == 7'b0000_000)) |->,
    (`WB_DATA == (`RS1_DATA | `RS2_DATA))
)

// AND: rs1 & rs2 
`AST(it, and_,
    ((`OPCODE == OPCODE_R_TYPE) && (`FUNCT3 == AND_) && (`FUNCT7 == 7'b0000_000)) |->,
    (`WB_DATA == (`RS1_DATA & `RS2_DATA))
)

//  ==============================================================================================
//  JAL (JUMP AND LINK) INSTRUCTION 
//  =============================================================================================
`AST(it, jal,
    (`OPCODE == OPCODE_JAL_TYPE) |->,
    (`PC_NEXT == (`PC_Q + `ALU_OP2))
)

// ===============================================================================================
// LUI INSTRUCTION 
// ==============================================================================================
`AST (it, lui,
     (`OPCODE == OPCODE_U_LUI) |->, 
     (`WB_DATA == (32'd0 + `IMM))
)

//  =============================================================================================
//  AUIPC INSTRUCTION 
//  ============================================================================================
`AST (it, auipc,
     (`OPCODE == OPCODE_U_AUIPC) |->,
     (`WB_DATA == (`PC_Q + `IMM))
)

//  =============================================================================================
//  TYPE B INSTRUCTIONS 
//  ============================================================================================

//  all types b
`AST(it, b_instr,
    (`OPCODE == OPCODE_B_TYPE) |->,
    ((`BR_TAKEN) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
)

//  BEQ
`AST(it, beq,
    ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == BEQ) ) |->,
    ((`RS1_DATA == `RS2_DATA) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
)

//  BNE
`AST(it, bne,
    ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == BNE) ) |->,
    ((`RS1_DATA != `RS2_DATA) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
)

//  BLT
`AST(it, blt,
    ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == BLT) ) |->,
    (($signed(`RS1_DATA) < $signed(`RS2_DATA)) ?  (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
)

//  GBE
`AST(it, bge,
    ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == BGE) ) |->,
    (($signed(`RS1_DATA) >= $signed(`RS2_DATA)) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
)

//  BLTU
`AST(it, bltu,
    ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == BLTU) ) |->,
    ((`RS1_DATA < `RS2_DATA) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
)

//  BGEU
`AST(it, bgeu,
    ((`OPCODE == OPCODE_B_TYPE) && (`FUNCT3 == BGEU) ) |->,
    ((`RS1_DATA >= `RS2_DATA) ? (`PC_NEXT == `PC_Q + `IMM): (`PC_NEXT == `PC_Q + 3'b100))
)

//  ================================================================================================================
//  TYPE S INSTRUCCIONS 
//  ================================================================================================================
// dmem: write_en active
`AST(it,dmem_we,
    (`OPCODE == OPCODE_S_TYPE) |->,
    (`DMEM_WE == 1'b1)
)

// ALL S TYPES 
`AST(it, s_type,
    (`OPCODE == OPCODE_S_TYPE) |->,
    ((`DMEM_ADDR == `RS1_DATA + `IMM) && (`DMEM_WDATA == `RS2_DATA))
)

//  TYPE L INSTRUCCIONS 
//  ================================================================================================================
// dmem: write_en disable and prf_we active 
`AST(it,write_back_from_dmem,
    (`OPCODE == OPCODE_L_TYPE) |->,
    ((`DMEM_WE == 1'b0) && (`RF_WE == 1'b1))
)

`AST(it, data_to_prf,
    (`OPCODE == OPCODE_L_TYPE) |->,
    (`DMEM_ADDR == `RS1_DATA + `IMM )
)
endmodule
