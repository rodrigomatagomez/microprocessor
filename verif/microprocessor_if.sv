interface microprocessor_if #(int DATA_W = 32, int DIR_W = 5) (input logic clk);

  // ===============================================
  // SIGNALS
  // ===============================================

  // IF (Instruction Fetch)
  logic [DATA_W-1:0]  pc_q;
  logic [DATA_W-1:0]  pc_next;
  logic [DATA_W-1:0]  pc_plus_inc;
  logic               branch_taken;
  logic [DATA_W-1:0]  branch_target;
  logic               instruction_sel;
  logic [DATA_W-1:0]  instruction;

  // Control Unit
  logic [6:0]         opcode;
  logic [2:0]         funct_3;
  logic [6:0]         funct_7;

  // ID/WB
  logic                   rf_we;
  logic [DATA_W-1:0]      x0;
  logic [DIR_W-1:0]       rs1, rs2, rd;
  logic [DATA_W-1:0]      rs1_data, rs2_data;
  logic [DATA_W-1:0]      wb_data;
  logic [1:0]             wb_sel;

  // IMM/EX
  logic [2:0]         imm_sel;
  logic [DATA_W-1:0]  imm;
  logic [1:0]         op1_sel_pc;
  logic               op2_sel_imm;
  logic [3:0]         alu_ctrl;
  logic [DATA_W-1:0]  alu_op1, alu_op2, alu_result;
  logic               b_condition_rs1_rs2;

  // MEM
  logic               dmem_we;
  logic [DATA_W-1:0]  dmem_addr;
  logic [DATA_W-1:0]  dmem_wdata;
  logic [DATA_W-1:0]  dmem_rdata;

  // ===============================================
  // Clocking block (monitor sampling)
  // ===============================================
  clocking cb @(posedge clk);
    default input #1step output #1step;

    input pc_q, pc_next, pc_plus_inc;
    input branch_taken, branch_target, instruction, instruction_sel;

    input opcode, funct_3, funct_7;

    input rf_we, rs1, rs2, rd, x0;
    input rs1_data, rs2_data, wb_data, wb_sel;

    input imm_sel, imm;
    input op1_sel_pc, op2_sel_imm;
    input alu_ctrl, alu_op1, alu_op2, alu_result;
    input b_condition_rs1_rs2;

    input dmem_we, dmem_addr, dmem_wdata, dmem_rdata;
  endclocking

  // Monitor modport (uses clocking block)
  modport monitor (clocking cb);

  // Probe modport (bridge drives these signals into the interface)
  // NOTE: Do not redeclare clk here; clk is already the interface port.
  modport probe (
    output pc_q, pc_next, pc_plus_inc,
    output branch_taken, branch_target,
    output instruction_sel, instruction,

    output opcode, funct_3, funct_7,

    output rf_we, rs1, rs2, rd, x0,
    output rs1_data, rs2_data, wb_data, wb_sel,

    output imm_sel, imm,
    output op1_sel_pc, op2_sel_imm,
    output alu_ctrl, alu_op1, alu_op2, alu_result,
    output b_condition_rs1_rs2,

    output dmem_we, dmem_addr, dmem_wdata, dmem_rdata
  );

endinterface

