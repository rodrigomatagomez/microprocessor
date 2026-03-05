`timescale 1ns/1ps

module microprocessor_top_tb;

  // ---------------------------------------------------------------------------
  // Parámetros locales (igual que tu RTL típico)
  // ---------------------------------------------------------------------------
  localparam DATA_WIDTH = 32;
  localparam DIR_WIDTH  = 5;
  localparam DEPTH      = 1024;

  // ---------------------------------------------------------------------------
  // Clock / Reset
  // ---------------------------------------------------------------------------
  reg clk;
  reg arst_n;

  initial clk = 1'b0;
  always #5 clk = ~clk;   // 10ns period

  initial begin
    arst_n = 1'b0;
    repeat (3) @(posedge clk);
    arst_n = 1'b1;
  end

  // ---------------------------------------------------------------------------
  // Estímulo a la instrucción (modo "driven")
  //  - instr_en=0 => usa instruction_memory
  // ---------------------------------------------------------------------------
  reg  instr_en;
  reg  [DATA_WIDTH-1:0] driven_instr;

  // ---------------------------------------------------------------------------
  // DUT
  // ---------------------------------------------------------------------------
  microprocessor_top #(
    .DATA_WIDTH(DATA_WIDTH),
    .DIR_WIDTH (DIR_WIDTH),
    .DEPTH     (DEPTH)
  ) dut (
    .clk          (clk),
    .arst_n       (arst_n),
    .instr_en     (instr_en),
    .driven_instr (driven_instr)
  );

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  integer i;

  task init_state;
    begin
      // PRF init (deja x0 intacto, el DUT lo fuerza)
      for (i = 1; i < 32; i = i + 1) begin
        dut.prf_i.prf[i] = 32'h0000_0000;
      end

      // DMEM init
      for (i = 0; i < DEPTH; i = i + 1) begin
        dut.data_mem_i.mem[i] = 32'h0000_0000;
      end

      // IMEM init a NOP
      for (i = 0; i < DEPTH; i = i + 1) begin
        dut.instr_mem_i.mem[i] = 32'h0000_0013; // NOP = addi x0,x0,0
      end
    end
  endtask

  task load_program_simple;
    begin
      // Programa en palabras (PC = 0,4,8,... => mem[0],mem[1],mem[2]...)
      // 0: addi x1,x0,5    = 0x00500093
      // 1: addi x2,x0,5    = 0x00500113
      // 2: add  x3,x1,x2   = 0x002081B3
      // 3: sw   x3,0(x0)   = 0x00302023
      // 4: lw   x4,0(x0)   = 0x00002203
      // 5: nop             = 0x00000013
      // 6: jal  x0,0       = 0x0000006F  (loop)
      dut.instr_mem_i.mem[0] = 32'h0050_0093;
      dut.instr_mem_i.mem[1] = 32'h0050_0113;
      dut.instr_mem_i.mem[2] = 32'h0020_81B3;
      dut.instr_mem_i.mem[3] = 32'h0030_2023;
      dut.instr_mem_i.mem[4] = 32'h0000_2203;
      dut.instr_mem_i.mem[5] = 32'h0000_0013;
      dut.instr_mem_i.mem[6] = 32'h0000_006F;
    end
  endtask

  task print_state;
    begin
      $display("------------------------------------------------------------");
      $display("PC = 0x%08h", dut.pc_i.pc_out);
      $display("x1 = 0x%08h", dut.prf_i.prf[1]);
      $display("x2 = 0x%08h", dut.prf_i.prf[2]);
      $display("x3 = 0x%08h", dut.prf_i.prf[3]);
      $display("x4 = 0x%08h", dut.prf_i.prf[4]);
      $display("DMEM[0] = 0x%08h", dut.data_mem_i.mem[0]);
      $display("------------------------------------------------------------");
    end
  endtask

  // ---------------------------------------------------------------------------
  // TEST
  // ---------------------------------------------------------------------------
  initial begin
    instr_en     = 1'b0;              // usar IMEM
    driven_instr = 32'h0000_0013;

    init_state();
    load_program_simple();

    // Espera a que salga de reset
    wait (arst_n == 1'b1);
    repeat (2) @(posedge clk);

    // Corre algunos ciclos
    repeat (20) @(posedge clk);

    // Imprime y valida algo mínimo
    print_state();

    if (dut.prf_i.prf[3] !== 32'd10) begin
      $display("FAIL: x3 esperado 10, obtenido %0d (0x%08h)", dut.prf_i.prf[3], dut.prf_i.prf[3]);
      $finish;
    end

    if (dut.data_mem_i.mem[0] !== 32'd10) begin
      $display("FAIL: DMEM[0] esperado 10, obtenido %0d (0x%08h)", dut.data_mem_i.mem[0], dut.data_mem_i.mem[0]);
      $finish;
    end

    if (dut.prf_i.prf[4] !== 32'd10) begin
      $display("FAIL: x4 esperado 10 (lw), obtenido %0d (0x%08h)", dut.prf_i.prf[4], dut.prf_i.prf[4]);
      $finish;
    end

    $display("PASS: programa simple ejecutado correctamente.");
    $finish;
  end

endmodule