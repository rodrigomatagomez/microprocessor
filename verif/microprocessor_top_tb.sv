`timescale 1ns / 1ps
//------------------------------------------------------------------------------
// Testbench: microprocessor_top_tb
// Description:
//   Simple randomized ADDI stimulus via microprocessor_if tasks.
//
// Notes:
//   - Assumes microprocessor_if provides:
//       * task init_prf();
//       * task build_addi_random();
//   - Instruction is driven through the interface into the DUT.
//------------------------------------------------------------------------------

module microprocessor_top_tb;

  // ---------------------------------------------------------------------------
  // Params
  // ---------------------------------------------------------------------------
  parameter MAX_CYCLES = 10_000;
  parameter OPCODE_JAL = 7'b110_1111;
  // ---------------------------------------------------------------------------
  // Signals
  // ---------------------------------------------------------------------------
  bit clk;
  bit arst_n;

  // ---------------------------------------------------------------------------
  // Interface
  // ---------------------------------------------------------------------------
  microprocessor_if micro (
    .clk    (clk),
    .arst_n (arst_n)
  );
  // ---------------------------------------------------------------------------
  
  always begin
    #5ns clk = ~clk; //Clock generation 
  end

  initial begin
    arst_n = 1'b0; //Reset 
    #20ns;
    arst_n = 1'b1;
  end

  // ---------------------------------------------------------------------------
  // DUT
  // ---------------------------------------------------------------------------
  microprocessor_top microprocessor_DUT (
    .clk         (clk),
    .arst_n      (arst_n)
  );

  // ---------------------------------------------------------------------------
  // Main stimulus
  // ---------------------------------------------------------------------------
  initial begin
    wait (arst_n == 1'b1);
    repeat (MAX_CYCLES) begin
    @(posedge clk);
    end
    $finish;
  end
  //----------------------------------------------------------------------------
  // Assertions 
  // ---------------------------------------------------------------------------
    
    //-----------------Program_counter---------------------------------------------
    assert property (@(posedge clk) disable iff (!arst_n)
        microprocessor_DUT.pc_i.pc_out[1:0] == 2'b00 //Check if PC is ALWAYS aligned 
        ) else begin
            $error("PC misaligned");
            $finish;
        end;
    assert property ( @(posedge clk) disable iff (!arst_n)
        (microprocessor_DUT.cu_i.opcode == OPCODE_JAL) |-> ((microprocessor_DUT.pc_i.pc_in) == (microprocessor_DUT.alu_i.alu_result)) //Check when branch taken the next instruction is PC + imm
        ) else begin 
            $error("Wrong direction");
            $finish;
        end;
    //--------------PRF---------------------------------------------------------
    assert property ( @(posedge clk) disable iff (!arst_n)
        microprocessor_DUT.prf_i.prf[0] == 32'd0    //Check if prf[0] is ALWAYS zero 
        ) else begin 
        $fatal("prf has to be always zero");
        $finish;
    end;
    assert property ( @(posedge clk) disable iff (!arst_n)
        ((microprocessor_DUT.cu_i.prf_wr_en == 1'b1) && (microprocessor_DUT.instr[11:7] == 5'd0)) |-> (microprocessor_DUT.prf_i.prf[0] == 32'd0)    //Even if the instruction works with x0 is has to remain in zero
        ) else begin 
            $fatal("The instruction overwrited prf[0]");
            $finish;
        end;  
  // ---------------------------------------------------------------------------
  // Waves (Xcelium/SimVision SHM)
  // ---------------------------------------------------------------------------
  /*initial begin
    $shm_open("shm_db");
    $shm_probe("ASMTR");
  end
  */
endmodule

