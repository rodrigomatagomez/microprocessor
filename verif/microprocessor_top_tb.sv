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

  // ===========================================================================
  // DUT -> VIF "probe bridge"
  // ===========================================================================
  // IF
  assign vif.pc_q          = dut.pc_i.pc_out;
  assign vif.pc_next       = dut.pc_i.pc_in;
  assign vif.pc_plus_inc   = dut.pc_adder_i.next_instruction;
  assign vif.branch_taken  = dut.cu_i.branch_taken;
  assign vif.branch_target = dut.upc_next_mux_i.sel;
  
  assign vif.opcode        = dut.cu_i.opcode;
  assign vif.funct_3       = dut.cu_i.funct_3;
  assign vif.funct_7       = dut.cu_i.funct_7;
  assign vif.instruction   = dut.instruction;
  
  assign vif.instruction_sel = drive_if.instr_en;

  // ID/WB
  assign vif.rf_we     = dut.prf_i.write_en;
  assign vif.x0        = dut.prf_i.prf[0];
  assign vif.rs1       = dut.prf_i.read_dir1;
  assign vif.rs2       = dut.prf_i.read_dir2;
  assign vif.rd        = dut.prf_i.write_dir;
  assign vif.rs1_data  = dut.prf_i.read_data1;
  assign vif.rs2_data  = dut.prf_i.read_data2;
  assign vif.wb_data   = dut.prf_i.write_data;
  assign vif.wb_sel    = dut.wb_mux_i.sel;

  // IMM/EX
  assign vif.imm_sel     = dut.imm_gen_i.imm_sel;
  assign vif.imm         = dut.imm_gen_i.imm_out;
  assign vif.op1_sel_pc  = dut.alu_op1_mux_i.sel;
  assign vif.op2_sel_imm = dut.alu_op2_mux_i.sel;
  assign vif.alu_ctrl    = dut.alu_i.alucontrol;
  assign vif.alu_op1     = dut.alu_i.operand1;
  assign vif.alu_op2     = dut.alu_i.operand2;
  assign vif.alu_result  = dut.alu_i.alu_result;
  assign vif.b_condition_rs1_rs2 = dut.branch_cmp_i.branch_taken;

  // MEM
  assign vif.dmem_we     = dut.data_mem_i.wr_en;
  assign vif.dmem_addr   = dut.data_mem_i.addr;
  assign vif.dmem_wdata  = dut.data_mem_i.data_in;
  assign vif.dmem_rdata  = dut.data_mem_i.data_out;

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
      repeat (100_000) begin
        if (!tr.randomize()) $fatal("Randomize failed");
        //$display("[TB] %s", tr.s_print());
        drive_if.drive_item(tr);
      end
        
        // Run for enough cycles to complete the program
        @(posedge clk);
        $finish;
      end

    initial begin // Initial block to open shared memory and probe signals
		$shm_open("shm_db");
		$shm_probe("AS");
	end


//  =============================================================================================================
//  PC AND PRF
`AST (it, pc_aligned,
     1'b1 |->, (vif.pc_q[1:0] == 2'b00)
)

`AST(it, next_instr,
    (vif.opcode == (OPCODE_R_TYPE || OPCODE_I_TYPE || OPCODE_U_LUI || OPCODE_U_AUIPC || OPCODE_L_TYPE || OPCODE_S_TYPE) ) |->,
    (vif.pc_next == vif.pc_q + 3'b100)
)

`AST (it, prf_x0,
     1'b1 |->, (vif.x0 == '0)
) 
//  ===========================================================================================================
//  TYPE_I INSTRUCTIONS 
`AST (it, imm_I_type, 
     (vif.opcode == OPCODE_I_TYPE) |->, (vif.imm_sel == IMM_I)
)
                    
`AST(it, prf_we,
    (vif.opcode == OPCODE_I_TYPE) |->, (vif.rf_we == 1'b1)
)
                    
`AST(it, pc_4,
    (vif.opcode == OPCODE_I_TYPE) |->, (vif.pc_next == vif.pc_q + 3'b100)
)                  
// =========================================================
// I-type: ADDI, SLTI, SLTIU, XORI, ORI, ANDI
// =========================================================

// ADDI: wb_data = op1 + op2
`AST(it, addi_result,
  ((vif.opcode == OPCODE_I_TYPE) && (vif.funct_3 == ADDI)) |->,
  (vif.wb_data == (vif.alu_op1 + vif.alu_op2))
)

// SLTI: wb_data = (signed(op1) < signed(op2)) ? 1 : 0
`AST(it, slti_result,
  ((vif.opcode == OPCODE_I_TYPE) && (vif.funct_3 == SLTI)) |->,
  (vif.wb_data == (($signed(vif.alu_op1) < $signed(vif.alu_op2)) ? 32'd1 : 32'd0))
)

// SLTIU: wb_data = (unsigned(op1) < unsigned(op2)) ? 1 : 0
`AST(it, sltiu_result,
  ((vif.opcode == OPCODE_I_TYPE) && (vif.funct_3 == SLTIU)) |->,
  (vif.wb_data == ((vif.alu_op1 < vif.alu_op2) ? 32'd1 : 32'd0))
)

// XORI: wb_data = op1 ^ op2
`AST(it, xori_result,
  ((vif.opcode == OPCODE_I_TYPE) && (vif.funct_3 == XORI)) |->,
  (vif.wb_data == (vif.alu_op1 ^ vif.alu_op2))
)

// ORI: wb_data = op1 | op2
`AST(it, ori_result,
  ((vif.opcode == OPCODE_I_TYPE) && (vif.funct_3 == ORI)) |->,
  (vif.wb_data == (vif.alu_op1 | vif.alu_op2))
)

// ANDI: wb_data = op1 & op2
`AST(it, andi_result,
  ((vif.opcode == OPCODE_I_TYPE) && (vif.funct_3 == ANDI)) |->,
  (vif.wb_data == (vif.alu_op1 & vif.alu_op2))
)
//  ===========================================================
//  R-type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
//  ==========================================================

//  SUB: wb_data = rs1 - rs2 
`AST(it, sub,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == SUB) && (vif.funct_7 == 7'b0100_000)) |->,
    (vif.wb_data == (vif.rs1_data - vif.rs2_data))
)

//  ADD: wb_data = rs1 + rs2 
`AST(it, add,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == SUB) && (vif.funct_7 == 7'b0100_000)) |->,
    (vif.wb_data == (vif.rs1_data - vif.rs2_data))
)

// SLL: wb_data = rs1 << rs2[4:0]
`AST(it, sll,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == SLL) && (vif.funct_7 == 7'b0000_000)) |->,
    (vif.wb_data == (vif.rs1_data << vif.rs2_data[4:0]))
)

// SLT: wb_data = rs1 < rs2
`AST(it, slt,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == SLT) && (vif.funct_7 == 7'b0000_000)) |->,
    ((vif.wb_data) == ($signed(vif.rs1_data) < $signed(vif.rs2_data) ? 32'd1 : 32'd0))
)

// SLTU: wb_data = rs1 < rs2 
`AST(it, sltu,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == SLTU) && (vif.funct_7 == 7'b0000_000)) |->,
    (vif.wb_data == (vif.rs1_data < vif.rs2_data ? 32'd1 : 32'd0) )
)

// XOR: wb_data = rs1 ^ rs2 
`AST(it, xor_,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == XOR_) && (vif.funct_7 == 7'b0000_000)) |->,
    (vif.wb_data == (vif.rs1_data ^ vif.rs2_data))
)

// SRL: wb_data = rs1 >> rs2[4:0]
`AST(it, srl,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == SRL) && (vif.funct_7 == 7'b0000_000)) |->,
    (vif.wb_data == (vif.rs1_data >> vif.rs2_data[4:0]))
)

// SRA: wb_data =  rs1 >>> rs2[4:0]
`AST(it, sra,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == SRA) && (vif.funct_7 == 7'b0100_000)) |->,
    ($signed(vif.wb_data) == ($signed(vif.rs1_data) >>> vif.rs2_data[4:0]) )
)

// OR: rs1 | rs2 
`AST(it, or_,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == OR_) && (vif.funct_7 == 7'b0000_000)) |->,
    (vif.wb_data == (vif.rs1_data | vif.rs2_data))
)

// AND: rs1 & rs2 
`AST(it, and_,
    ((vif.opcode == OPCODE_R_TYPE) && (vif.funct_3 == AND_) && (vif.funct_7 == 7'b0000_000)) |->,
    (vif.wb_data == (vif.rs1_data & vif.rs2_data))
)

//  ==============================================================================================
//  JAL (JUMP AND LINK) INSTRUCTION 
//  =============================================================================================
`AST(it, jal,
    (vif.opcode == OPCODE_JAL_TYPE) |->,
    (vif.pc_next == (vif.pc_q + vif.alu_op2))
)

// ===============================================================================================
// LUI INSTRUCTION 
// ==============================================================================================
`AST (it, lui,
     (vif.opcode == OPCODE_U_LUI) |->, 
     (vif.wb_data == (32'd0 + vif.imm))
)

//  =============================================================================================
//  AUIPC INSTRUCTION 
//  ============================================================================================
`AST (it, auipc,
     (vif.opcode == OPCODE_U_AUIPC) |->,
     (vif.wb_data == (vif.pc_q + vif.imm))
)

//  =============================================================================================
//  TYPE B INSTRUCTIONS 
//  ============================================================================================

//  all types b
`AST(it, b_instr,
    (vif.opcode == OPCODE_B_TYPE) |->,
    ((vif.b_condition_rs1_rs2) ? (vif.pc_next == vif.pc_q + vif.imm): (vif.pc_q + 3'b100))
)

//  BEQ
`AST(it, beq,
    ((vif.opcode == OPCODE_B_TYPE) && (vif.funct_3 == BEQ) ) |->,
    ((vif.rs1_data == vif.rs2_data) ? (vif.pc_next == vif.pc_q + vif.imm): (vif.pc_q + 3'b100))
)

//  BNE
`AST(it, bne,
    ((vif.opcode == OPCODE_B_TYPE) && (vif.funct_3 == BNE) ) |->,
    ((vif.rs1_data != vif.rs2_data) ? (vif.pc_next == vif.pc_q + vif.imm): (vif.pc_q + 3'b100))
)

//  BLT
`AST(it, blt,
    ((vif.opcode == OPCODE_B_TYPE) && (vif.funct_3 == BLT) ) |->,
    (($signed(vif.rs1_data) < $signed(vif.rs2_data)) ? (vif.pc_next == vif.pc_q + vif.imm): (vif.pc_q + 3'b100))
)

//  GBE
`AST(it, bge,
    ((vif.opcode == OPCODE_B_TYPE) && (vif.funct_3 == BGE) ) |->,
    (($signed(vif.rs1_data) >= $signed(vif.rs2_data)) ? (vif.pc_next == vif.pc_q + vif.imm): (vif.pc_q + 3'b100))
)

//  BLTU
`AST(it, bltu,
    ((vif.opcode == OPCODE_B_TYPE) && (vif.funct_3 == BLTU) ) |->,
    ((vif.rs1_data < vif.rs2_data) ? (vif.pc_next == vif.pc_q + vif.imm): (vif.pc_q + 3'b100))
)

//  BGEU
`AST(it, bgeu,
    ((vif.opcode == OPCODE_B_TYPE) && (vif.funct_3 == BGEU) ) |->,
    ((vif.rs1_data >= vif.rs2_data) ? (vif.pc_next == vif.pc_q + vif.imm): (vif.pc_q + 3'b100))
)

//  ================================================================================================================
//  TYPE S INSTRUCCIONS 
//  ================================================================================================================
// dmem: write_en active
`AST(it,dmem_we,
    (vif.opcode == OPCODE_S_TYPE) |->,
    (vif.dmem_we == 1'b1)
)

// ALL S TYPES 
`AST(it, s_type,
    (vif.opcode == OPCODE_S_TYPE) |->,
    ((vif.dmem_addr == vif.rs1_data + vif.imm) && (vif.dmem_wdata == vif.rs2_data))
)

//  TYPE L INSTRUCCIONS 
//  ================================================================================================================
// dmem: write_en disable and prf_we active 
`AST(it,write_back_from_dmem,
    (vif.opcode == OPCODE_L_TYPE) |->,
    ((vif.dmem_we == 1'b0) && (vif.rf_we == 1'b1))
)

`AST(it, data_to_prf,
    (vif.opcode == OPCODE_L_TYPE) |->,
    (vif.dmem_addr == vif.rs1_data + vif.imm )
)
endmodule
