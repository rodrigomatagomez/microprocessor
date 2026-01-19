`timescale 1ns / 1ps

//------------------------------------------------------------------------------
// Module: microprocessor_top
// Description:
//   Top-level integration for a single-cycle RV32-style microprocessor datapath.
//   Contains:
//     - PC register and next-PC selection (sequential vs redirect)
//     - Instruction fetch (instruction memory)
//     - Register file read/write-back
//     - Immediate generation
//     - ALU execute
//     - Data memory (stores/loads when implemented)
//     - Control unit decode and branch decision
//
// Notes:
//   - Signal naming follows datapath intent: pc_* , if_* , id_* , ex_* , mem_* , wb_*
//   - This module is structural (wires + instantiations) and contains no state
//     besides submodules (PC, RF, memories).
//------------------------------------------------------------------------------
module microprocessor_top (
    input logic clk,
    input logic arst_n
);

//`include "defines.svh"

    //--------------------------------------------------------------------------
    // IF: Program Counter and Instruction Fetch
    //--------------------------------------------------------------------------

    logic [DATA_WIDTH-1:0] pc_q;            // current PC (byte address)
    logic [DATA_WIDTH-1:0] pc_next;         // next PC selected by pc_next mux
    logic [DATA_WIDTH-1:0] pc_plus_inc;     // sequential next PC (PC + inc)
    logic                  pc_inc_sel;      // +4 vs +2 selector (future)
    logic [2:0]            pc_inc;          // increment constant (2 or 4)
    logic [DATA_WIDTH-1:0] instr;           // fetched instruction

    // Next-PC select:
    //   - branch_taken=0 -> sequential PC+4
    //   - branch_taken=1 -> redirect target (computed in EX path)
    logic                  branch_taken;
    logic [DATA_WIDTH-1:0] branch_target;   // target address (PC + imm), produced in EX

    // PC next mux: select sequential or redirect target
    mux #(.WIDTH(DATA_WIDTH)) upc_next_mux_i (
        .in1(branch_target),     // sel=1 -> redirect
        .in2(pc_plus_inc),       // sel=0 -> sequential
        .sel(branch_taken),
        .out(pc_next)
    );

    // PC register
    program_counter pc_i (
        .clk   (clk),
        .arst_n(arst_n),
        .pc_in (pc_next),
        .pc_out(pc_q)
    );

    // PC increment select (+4 now; +2 reserved for future compressed support)
    plus_4_or_2_mux pc_inc_sel_i (
        .sel            (pc_inc_sel),
        .instruction_add(pc_inc)
    );

    // PC + increment
    adder #(.DATA_WIDTH(DATA_WIDTH)) pc_adder_i (
        .constant_operand(pc_inc),
        .instruction_addr(pc_q),
        .next_instruction (pc_plus_inc)
    );

    // Instruction memory (word-indexed; PC is byte-addressed)
    instruction_memory #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) instr_mem_i (
        .pc   (pc_q),
        .instr(instr)
    );

    //--------------------------------------------------------------------------
    // ID: Decode and Register File Read
    //--------------------------------------------------------------------------

    logic                  rf_we;
    logic [DATA_WIDTH-1:0] rs1_data;
    logic [DATA_WIDTH-1:0] rs2_data;

    // Write-back data (selected later)
    logic [DATA_WIDTH-1:0] wb_data;

    physical_register_file #(.DIR_WIDTH(DIR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) prf_i (
        .clk       (clk),
        .arst_n    (arst_n),
        .write_en  (rf_we),
        .read_dir1 (instr[19:15]),   // rs1
        .read_dir2 (instr[24:20]),   // rs2
        .write_dir (instr[11:7]),    // rd
        .write_data(wb_data),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    //--------------------------------------------------------------------------
    // ID/EX: Immediate Generation and Operand Select
    //--------------------------------------------------------------------------

    logic [2:0]            imm_sel;
    logic [DATA_WIDTH-1:0] imm;

    imm_gen imm_gen_i (
        .instr   (instr),
        .imm_sel (imm_sel),
        .imm_out (imm)
    );

    // ALU operand mux controls
    logic                  op1_sel_pc;      // 1: use PC, 0: use rs1
    logic                  op2_sel_imm;     // 1: use imm, 0: use rs2

    logic [DATA_WIDTH-1:0] alu_op1;
    logic [DATA_WIDTH-1:0] alu_op2;

    // Operand1: PC vs rs1
    mux #(.WIDTH(DATA_WIDTH)) alu_op1_mux_i (
        .in1(pc_q),        // sel=1 -> PC
        .in2(rs1_data),    // sel=0 -> rs1
        .sel(op1_sel_pc),
        .out(alu_op1)
    );

    // Operand2: imm vs rs2
    mux #(.WIDTH(DATA_WIDTH)) alu_op2_mux_i (
        .in1(imm),         // sel=1 -> imm
        .in2(rs2_data),    // sel=0 -> rs2
        .sel(op2_sel_imm),
        .out(alu_op2)
    );

    //--------------------------------------------------------------------------
    // EX: ALU and Branch Decision
    //--------------------------------------------------------------------------

    logic [3:0]            alu_ctrl;
    logic [DATA_WIDTH-1:0] alu_result;

    alu #(.OPERAND_WIDTH(DATA_WIDTH)) alu_i (
        .operand1   (alu_op1),
        .operand2   (alu_op2),
        .alucontrol (alu_ctrl),
        .alu_result (alu_result)
    );

    // For branches/jumps in this single-cycle design, branch_target is produced by ALU
    // when operand1=PC and operand2=imm and alu_ctrl=ADD.
    assign branch_target = alu_result;

    // Comparator for BEQ condition (rs1 == rs2)
    logic eq_rs1_rs2;

    branch #(.DATA_WIDTH(DATA_WIDTH)) branch_cmp_i (
        .rs_1        (rs1_data),
        .rs_2        (rs2_data),
        .branch_taken(eq_rs1_rs2)
    );

    //--------------------------------------------------------------------------
    // MEM: Data Memory (store/load datapath)
    //--------------------------------------------------------------------------

    logic                  dmem_we;
    logic [DATA_WIDTH-1:0] dmem_rdata;

    data_memory #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) data_mem_i (
        .clk     (clk),
        .wr_en   (dmem_we),
        .addr    (alu_result),    // byte address from ALU
        .data_in (rs2_data),      // store data
        .data_out(dmem_rdata)     // load data
    );

    //--------------------------------------------------------------------------
    // WB: Write-back Mux (ALU vs MEM vs PC+4)
    //--------------------------------------------------------------------------

    logic [1:0] wb_sel;

    mux_3_to_1 wb_mux_i (
        .data_out_to_pc   (pc_plus_inc),  // PC+4 (link address)
        .alu_to_mem_addr  (alu_result),   // ALU result
        .data_out_to_mux  (dmem_rdata),   // memory read data
        .sel              (wb_sel),
        .data_out         (wb_data)
    );

    //--------------------------------------------------------------------------
    // Control Unit: Decode instruction -> drive control signals
    //--------------------------------------------------------------------------

    control_unit cu_i (
        .opcode            (instr[6:0]),
        .funct_3           (instr[14:12]),
        .funct_7           (instr[31:25]),
        .zero              (eq_rs1_rs2),     // BEQ condition

        .prf_wr_en         (rf_we),
        .cu_imm_sel        (imm_sel),
        .prf_pc_mux_ctrl   (op1_sel_pc),
        .prf_imm_mux_ctrl  (op2_sel_imm),
        .cu_alu_ctrl       (alu_ctrl),
        .cu_mem_out_mux_sel(wb_sel),
        .cu_data_mem_wr_en (dmem_we),
        .cu_pc_add_sel     (pc_inc_sel),
        .branch_taken      (branch_taken)
    );

endmodule
