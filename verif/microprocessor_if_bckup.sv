`timescale 1ns/1ps

interface micro_if #(parameter DATA_WIDTH = 32) (input logic clk);

  // --------------------------------------------
  // Reset
  // --------------------------------------------
  bit arst_n;

  // --------------------------------------------
  // Observation taps (from DUT)
  // --------------------------------------------
  logic [DATA_WIDTH-1:0]    pc;
  logic [DATA_WIDTH-1:0]    instr;

  // Write-back observation
  logic                     wb_we;
  logic [4:0]               wb_rd;
  logic [DATA_WIDTH-1:0]    wb_data;

  // Data memory observation
  logic                     dmem_we;
  logic [DATA_WIDTH-1:0]    dmem_addr;
  logic [DATA_WIDTH-1:0]    dmem_wdata;
  logic [DATA_WIDTH-1:0]    dmem_rdata;

  // Control unit observation
  logic         cu_branch_taken;
  logic [6:0]   cu_opcode;

  // ALU observation
  logic [DATA_WIDTH-1:0]    alu_operand_1;
  logic [DATA_WIDTH-1:0]    alu_operand_2;
  logic [DATA_WIDTH-1:0]    alu_result;

  // Imm generator observation 
  logic [DATA_WIDTH-1:0]    imm_out;
    
  // --------------------------------------------
  // Clocking block
  // --------------------------------------------
  clocking cb @(posedge clk);
    default input #1step output #1step;

    // Drive
    output arst_n;

    // Sample
    input  pc, instr; 					                //program_conter and instruction_mem
    input  wb_we, wb_rd, wb_data;			            //prf 
    input  dmem_we, dmem_addr, dmem_wdata, dmem_rdata;	//data_mem
    input  cu_branch_taken, cu_opcode;                  //control_unit
    input  alu_operand_1, alu_operand_2, alu_result;    //ALU
    input  imm_out;                                     //imm_gen

  endclocking

  // --------------------------------------------
  // Modports
  // --------------------------------------------
  modport TB (clocking cb);

  modport DUT (
    input  clk,
    input  arst_n,
    // PC and instruction 
    output pc,
    output instr,
    // PRF
    output wb_we,
    output wb_rd,
    output wb_data,
    // data_mem
    output dmem_we,
    output dmem_addr,
    output dmem_wdata,
    output dmem_rdata,
    // control_unit 
    output cu_branch_taken,
    output cu_opcode,
    // ALU 
    output alu_operand_1,
    output alu_operand_2,
    output alu_result,
    // imm_gen
    output imm_out
  );

  // --------------------------------------------
  // TB helper tasks
  // --------------------------------------------
  task automatic apply_reset(int unsigned cycles = 5);
    cb.arst_n <= 1'b0;
    repeat (cycles) @(cb);
    cb.arst_n <= 1'b1;
    @(cb);
  endtask
  
  

endinterface
