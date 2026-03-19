`timescale 1ns/1ps
import riscv_params_pkg::*;

module microprocessor_top_tb;

  // ---------------------------------------------------------------------------
  // Clock / Reset
  // ---------------------------------------------------------------------------
  bit clk;
  bit arst_n;

  initial clk = 1'b0;
  always #5ns clk = ~clk;

  initial begin
    arst_n = 1'b0;
    repeat (3) @(posedge clk);
    arst_n = 1'b1;
  end

  // ---------------------------------------------------------------------------
  // Loader "Wishbone-like" Command/Response bus (host -> wb_loader)
  // ---------------------------------------------------------------------------
  logic [AW-1:0] cmd_addr;   // Byte address (PC-like): 0x0000, 0x0004, 0x0008, ...
  logic [DW-1:0] cmd_wdata;  // 32-bit instruction word to be written into IMEM
  logic          cmd_we;     // 1=WRITE instruction (load), 0=READ (unused here)
  logic          cmd_valid;  // Host asserts when command is valid
  logic          cmd_ready;  // Loader asserts when it can accept a command

  logic [DW-1:0] rsp_rdata;  // Response data (unused here -> 0)
  logic          rsp_valid;  // Loader pulses to ACK a completed command

  // ---------------------------------------------------------------------------
  // IMEM write port (wb_loader -> microprocessor_top -> instruction_memory)
  // ---------------------------------------------------------------------------
  logic          imem_wr_en;            // 1-cycle pulse to write one instruction word
  logic [31:0]   imem_wr_addr;          // Byte address where instruction will be stored
  logic [31:0]   imem_wr_data;          // Instruction word
  logic          imem_wr_addr_is_byte;  // 1 => wr_addr is byte-based (PC style)
  logic          loader_busy;           // Loader is busy; you already gate pc_en with this
  logic          loaded;
  logic          load_done;

  // ---------------------------------------------------------------------------
  // MICROPROCESSOR
  // ---------------------------------------------------------------------------
  microprocessor_top dut (
    .clk                  (clk),
    .arst_n               (arst_n),

    // Instruction injection disabled: fetch from IMEM
    .instr_en             (1'b0),
    .driven_instr         ('0),

    // IMEM write port (from loader)
    .imem_wr_en           (imem_wr_en),
    .imem_wr_addr         (imem_wr_addr),
    .imem_wr_data         (imem_wr_data),
    .imem_wr_addr_is_byte (imem_wr_addr_is_byte),

    .loader_busy          (loader_busy),
    .loaded               (loaded)
  );

  // ---------------------------------------------------------------------------
  // WB LOADER
  //   Host sends (cmd_addr, cmd_wdata) -> loader writes IMEM -> rsp_valid ACK
  // ---------------------------------------------------------------------------
  wb_loader #(.AW(AW), .DW(DW)) wb_loader_i (
    .clk                  (clk),
    .rst_n                (arst_n),

    // Command
    .cmd_addr             (cmd_addr),
    .cmd_wdata            (cmd_wdata),
    .cmd_we               (cmd_we),
    .cmd_valid            (cmd_valid),
    .cmd_ready            (cmd_ready),

    // Response
    .rsp_rdata            (rsp_rdata),
    .rsp_valid            (rsp_valid),

    // IMEM write port
    .imem_wr_en           (imem_wr_en),
    .imem_wr_addr         (imem_wr_addr),
    .imem_wr_data         (imem_wr_data),
    .imem_wr_addr_is_byte (imem_wr_addr_is_byte),

    // Status (used by DUT gating)
    .loader_busy          (loader_busy),
    .loaded               (loaded),
    .load_done            (load_done)
  );

  // ---------------------------------------------------------------------------
  // Initialize internal DUT memories/registers 
  // ---------------------------------------------------------------------------
  initial begin : init_state
    for (int i = 1; i < 32; i++) begin
      dut.prf_i.prf[i] = '0;
    end

    for (int j = 0; j < DEPTH; j++) begin
      dut.data_mem_i.mem[j] = '0;
    end
  end

  // ---------------------------------------------------------------------------
  // Host task: load one instruction into IMEM via wb_loader
  // ---------------------------------------------------------------------------
  task automatic load_imem_word(
      input logic [AW-1:0] byte_addr,     // 0x0000, 0x0004, ...
      input logic [DW-1:0] instr_word
  );
    // Wait until loader can accept a command
    @(posedge clk);
    while (!cmd_ready) @(posedge clk);

    // Drive WRITE command for 1 cycle (ready/valid handshake)
    cmd_addr  <= byte_addr;
    cmd_wdata <= instr_word;
    cmd_we    <= 1'b1;       // WRITE => program IMEM
    cmd_valid <= 1'b1;

    @(posedge clk);
    cmd_valid <= 1'b0;

    // Wait for ACK
    while (!rsp_valid) @(posedge clk);

    $display("[%0t ns] IMEM LOAD: addr=0x%04h instr=0x%08h (ACK)",
             $time, byte_addr, instr_word);
  endtask

  // ---------------------------------------------------------------------------
  // Bus defaults
  // ---------------------------------------------------------------------------
  initial begin
    cmd_addr  = '0;
    cmd_wdata = '0;
    cmd_we    = 1'b0;
    cmd_valid = 1'b0;
  end

  // ---------------------------------------------------------------------------
  // TEST: Wishbone/loader receives instructions, writes IMEM, then CPU runs
  // ---------------------------------------------------------------------------
  initial begin : test_load_then_run
    wait (arst_n == 1'b1);

    // -----------------------------
    // (A) LOAD PHASE
    //   While loader_busy is active, DUT is frozen by your gating:
    //     pc_en_final = pc_en_cu & ~loader_busy;
    // -----------------------------
    load_imem_word(32'h0000_0000, 32'h0050_0193); // addi x3,x0,5
    load_imem_word(32'h0000_0004, 32'h0050_0113); // addi x2,x0,5
    load_imem_word(32'h0000_0008, 32'h0221_82B3); // mul  x5,x3,x2
    load_imem_word(32'h0000_000C, 32'h0000_0013); // nop

    // -----------------------------
    // (B) RUN PHASE
    //   After loading, loader_busy returns low (IDLE),
    //   so DUT is released and fetches from IMEM combinationally.
    // -----------------------------
    repeat (25) @(posedge clk);

    $finish;
  end

endmodule
