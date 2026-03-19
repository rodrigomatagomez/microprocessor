`timescale 1ns/1ps

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
  // IMEM write port (wb_loader -> microprocessor_top -> instruction_memory)
  // ---------------------------------------------------------------------------
  logic            imem_wr_en;            // 1-cycle pulse to write one instruction word
  logic [AW-1:0]   imem_wr_addr;          // Byte address where instruction will be stored
  logic [DW-1:0]   imem_wr_data;          // Instruction word
  logic            prog_rdy;               // 1 => PC start count 
  logic [DW-1:0]   uc_out;                // Loads from microprocesor to FSM
  logic            uc_out_valid;          //Flag to FSM whan data is valid 
  logic            uc_out_ready;          // Flag to UART indicates that the microprocessor finished the program

  // ---------------------------------------------------------------------------
  // MICROPROCESSOR
  // ---------------------------------------------------------------------------
  microprocessor_top dut (
    .clk                  (clk),
    .arst_n               (arst_n),
    // IMEM write port (from loader)
    .imem_wr_en           (imem_wr_en),
    .imem_wr_addr         (imem_wr_addr),
    .imem_wr_data         (imem_wr_data),
    .prog_rdy             (prog_rdy),
    .uc_out               (uc_out),
    .uc_out_valid         (uc_out_valid),
    .uc_out_ready         (uc_out_ready)
  );

initial begin : test_firts_program
  prog_rdy = 1'b0;
  wait (arst_n);
  @(posedge clk);
  prog_rdy = 1'b1;
  wait (uc_out_ready);
  $display("Program finished");
  repeat (2) @(posedge clk);
  $finish;
end

endmodule 
