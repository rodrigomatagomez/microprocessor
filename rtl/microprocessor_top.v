`timescale 1ns / 1ps
`include "riscv_params.vh"
//------------------------------------------------------------------------------
// Module: microprocessor_top
// Description:
//   Top-level integration for a single-cycle RV32-style microprocessor datapath.
//------------------------------------------------------------------------------

module microprocessor_top #(
    parameter DATA_WIDTH = 32,
    parameter DIR_WIDTH  = 5,
    parameter DEPTH      = 1024
)(
    input  wire                  clk,
    input  wire                  arst_n,
    input  wire                  instr_en,
    input  wire [DATA_WIDTH-1:0] driven_instr
);

    //--------------------------------------------------------------------------
    // IF: Program Counter and Instruction Fetch
    //--------------------------------------------------------------------------

    wire [DATA_WIDTH-1:0] pc_q;
    wire [DATA_WIDTH-1:0] pc_next;
    wire [DATA_WIDTH-1:0] pc_plus_inc;
    wire                  pc_inc_sel;
    wire [2:0]            pc_inc;

    wire [DATA_WIDTH-1:0] instruction;
    wire [DATA_WIDTH-1:0] mem_instruction;

    wire                  branch_taken;
    wire [DATA_WIDTH-1:0] branch_target;

    // PC next mux: select sequential or redirect target
    mux #(.WIDTH(DATA_WIDTH)) upc_next_mux_i (
        .in1(branch_target),  // sel=1 -> redirect
        .in2(pc_plus_inc),    // sel=0 -> sequential
        .sel(branch_taken),
        .out(pc_next)
    );

    // PC register
    program_counter pc_i (
        .clk    (clk),
        .arst_n (arst_n),
        .pc_in  (pc_next),
        .pc_out (pc_q)
    );

    // PC increment select (+4 now; +2 reserved)
    plus_4_or_2_mux pc_inc_sel_i (
        .sel             (pc_inc_sel),
        .instruction_add (pc_inc)
    );

    // PC + increment
    adder #(.DATA_WIDTH(DATA_WIDTH)) pc_adder_i (
        .constant_operand (pc_inc),
        .instruction_addr (pc_q),
        .next_instruction (pc_plus_inc)
    );

    // Instruction memory
    instruction_memory #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) instr_mem_i (
        .pc    (pc_q),
        .instr (mem_instruction)
    );

    //--------------------------------------------------------------------------
    // ID: Decode and Register File Read
    //--------------------------------------------------------------------------

    wire                  rf_we;
    wire [DATA_WIDTH-1:0] rs1_data;
    wire [DATA_WIDTH-1:0] rs2_data;

    wire [DATA_WIDTH-1:0] wb_data;

    physical_register_file #(.DIR_WIDTH(DIR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) prf_i (
        .clk        (clk),
        .arst_n     (arst_n),
        .write_en   (rf_we),
        .read_dir1  (instruction[19:15]),   // rs1
        .read_dir2  (instruction[24:20]),   // rs2
        .write_dir  (instruction[11:7]),    // rd
        .write_data (wb_data),
        .read_data1 (rs1_data),
        .read_data2 (rs2_data)
    );

    //--------------------------------------------------------------------------
    // ID/EX: Immediate Generation and Operand Select
    //--------------------------------------------------------------------------

    wire [2:0]            imm_sel;
    wire [DATA_WIDTH-1:0] imm;

    imm_gen imm_gen_i (
        .instr   (instruction),
        .imm_sel (imm_sel),
        .imm_out (imm)
    );

    wire [1:0]             op1_sel_pc;
    wire                   op2_sel_imm;

    wire [DATA_WIDTH-1:0] alu_op1;
    wire [DATA_WIDTH-1:0] alu_op2;

    // Zero operand for LUI operation
    wire [DATA_WIDTH-1:0] zero_operand;
    assign zero_operand = {DATA_WIDTH{1'b0}};

    // Operand1 mux: 00->0, 01->PC, 10->rs1
    mux_operand_1 alu_op1_mux_i (
        .in1     (zero_operand),
        .in2     (pc_q),
        .in3     (rs1_data),
        .sel     (op1_sel_pc),
        .data_out(alu_op1)
    );

    // Operand2 mux: imm vs rs2
    mux #(.WIDTH(DATA_WIDTH)) alu_op2_mux_i (
        .in1(imm),         // sel=1 -> imm
        .in2(rs2_data),    // sel=0 -> rs2
        .sel(op2_sel_imm),
        .out(alu_op2)
    );

    //--------------------------------------------------------------------------
    // EX: ALU and Branch Decision
    //--------------------------------------------------------------------------

    wire [3:0]            alu_ctrl;
    wire [DATA_WIDTH-1:0] alu_result;

    alu #(.OPERAND_WIDTH(DATA_WIDTH)) alu_i (
        .operand1   (alu_op1),
        .operand2   (alu_op2),
        .alucontrol (alu_ctrl),
        .alu_result (alu_result)
    );

    // Branch/jump target computed by ALU in your design
    assign branch_target = alu_result;

    wire b_condition_rs1_rs2;

    branch #(.DATA_WIDTH_BRANCH(DATA_WIDTH)) branch_cmp_i (
        .rs_1         (rs1_data),
        .rs_2         (rs2_data),
        .opcode       (instruction[6:0]),
        .funct_3      (instruction[14:12]),
        .branch_taken (b_condition_rs1_rs2)
    );

    //--------------------------------------------------------------------------
    // MEM: Data Memory
    //--------------------------------------------------------------------------

    wire                  dmem_we;
    wire [DATA_WIDTH-1:0] dmem_rdata;

    data_memory #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) data_mem_i (
        .clk      (clk),
        .wr_en    (dmem_we),
        .addr     (alu_result),
        .data_in  (rs2_data),
        .data_out (dmem_rdata)
    );

    //--------------------------------------------------------------------------
    // WB: Write-back Mux
    //--------------------------------------------------------------------------

    wire [1:0] wb_sel;

    mux_3_to_1 wb_mux_i (
        .data_out_to_pc  (pc_plus_inc),
        .alu_to_mem_addr (alu_result),
        .data_out_to_mux (dmem_rdata),
        .sel             (wb_sel),
        .data_out        (wb_data)
    );

    //--------------------------------------------------------------------------
    // Control Unit
    //--------------------------------------------------------------------------

    control_unit cu_i (
        .opcode             (instruction[6:0]),
        .funct_3            (instruction[14:12]),
        .funct_7            (instruction[31:25]),
        .zero               (b_condition_rs1_rs2),

        .prf_wr_en          (rf_we),
        .cu_imm_sel         (imm_sel),
        .prf_pc_mux_ctrl    (op1_sel_pc),
        .prf_imm_mux_ctrl   (op2_sel_imm),
        .cu_alu_ctrl        (alu_ctrl),
        .cu_mem_out_mux_sel (wb_sel),
        .cu_data_mem_wr_en  (dmem_we),
        .cu_pc_add_sel      (pc_inc_sel),
        .branch_taken       (branch_taken)
    );

    // Instruction select: external driven vs memory
    assign instruction = (instr_en) ? driven_instr : mem_instruction;

endmodule