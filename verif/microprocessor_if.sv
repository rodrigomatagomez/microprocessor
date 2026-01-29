`timescale 1ns/1ps

interface micro_if #(parameter int XLEN = 32) (input logic clk);

  // --------------------------------------------
  // Reset
  // --------------------------------------------
  bit arst_n;

  // --------------------------------------------
  // Observation taps (from DUT)
  // --------------------------------------------
  logic [XLEN-1:0] pc;
  logic [XLEN-1:0] instr;

  // Write-back observation
  logic            wb_we;
  logic [4:0]      wb_rd;
  logic [XLEN-1:0] wb_data;

  // Data memory observation
  logic            dmem_we;
  logic [XLEN-1:0] dmem_addr;
  logic [XLEN-1:0] dmem_wdata;
  logic [XLEN-1:0] dmem_rdata;

  // --------------------------------------------
  // Clocking block
  // --------------------------------------------
  clocking cb @(posedge clk);
    default input #1step output #1step;

    // Drive
    output arst_n;

    // Sample
    input  pc, instr;
    input  wb_we, wb_rd, wb_data;
    input  dmem_we, dmem_addr, dmem_wdata, dmem_rdata;
  endclocking

  // --------------------------------------------
  // Modports
  // --------------------------------------------
  modport TB (clocking cb);

  modport DUT (
    input  clk,
    input  arst_n,
    output pc,
    output instr,
    output wb_we,
    output wb_rd,
    output wb_data,
    output dmem_we,
    output dmem_addr,
    output dmem_wdata,
    output dmem_rdata
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
