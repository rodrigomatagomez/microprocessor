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
  `include "defines.svh"
  parameter MAX_CYCLES      = 10_000;
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

`ifndef prf_init
initial begin
    for (int i = 1; i < 32; i++) begin  
        microprocessor_DUT.prf_i.prf[i] = 32'b0;
    end
end
`endif

`ifndef data_mem
initial begin
    for (int i = 0; i < 1024; i++) begin  
        microprocessor_DUT.data_mem_i.mem[i] = 32'b0;
    end
end
`endif

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
    assert property (@(posedge clk) disable iff (!arst_n)
      ( (microprocessor_DUT.cu_i.opcode != OPCODE_JAL_TYPE)  &&
        (microprocessor_DUT.cu_i.opcode != OPCODE_B_TYPE)
      )
      |-> (microprocessor_DUT.pc_i.pc_in == microprocessor_DUT.pc_i.pc_out + 32'd4)
    )
    else begin
      $error("PC next must be PC+4 when not JAL/JALR/BRANCH");
      $finish;
    end

    assert property ( @(posedge clk) disable iff (!arst_n) 
        ((microprocessor_DUT.upc_next_mux_i.sel) |-> ((microprocessor_DUT.pc_i.pc_in) == (microprocessor_DUT.imm_gen_i.imm_out + microprocessor_DUT.pc_i.pc_out)))//Check when branch taken the next instruction is PC + imm
        ) else begin 
            $fatal("Direction must be PC+imm");
            $finish;
    end;
    //--------------PRF---------------------------------------------------------
        logic [4:0] rd_q;
        //Save the past value of prf[rd]
        always_ff @(posedge clk or negedge arst_n) begin
          if (!arst_n) rd_q <= 5'd0;
          else         rd_q <= microprocessor_DUT.prf_i.write_dir; // = instr[11:7]
        end
    assert property ( @(posedge clk) disable iff (!arst_n)
        microprocessor_DUT.prf_i.prf[0] == 32'd0    //Check if prf[0] is ALWAYS zero 
        ) else begin 
        $fatal("x0 violation: register x0 is not zero");
        $finish;
    end;
    assert property ( @(posedge clk) disable iff (!arst_n)
        ((microprocessor_DUT.cu_i.prf_wr_en == 1'b1) && (microprocessor_DUT.instr[11:7] == 5'd0)) |-> (microprocessor_DUT.prf_i.prf[0] == 32'd0)    //Even if the instruction works with x0 is has to remain in zero
        ) else begin 
            $fatal("The instruction overwrited prf[0]");
            $finish;
        end; 
    /*assert property (@(posedge clk) disable iff (!arst_n)
        (!microprocessor_DUT.prf_i.write_en && (rd_q != 5'd0))
        |-> (microprocessor_DUT.prf_i.prf[rd_q] == $past(microprocessor_DUT.prf_i.prf[rd_q]))
        ) else begin
            $fatal("PRF changed when write_en = 0");
            $finish;
        end;*/
    //-------------TYPE-I INSTRUCTIONS-----------------------------------------
    assert property (@(posedge clk) disable iff (!arst_n)
        (microprocessor_DUT.cu_i.opcode == OPCODE_I_TYPE) |-> (microprocessor_DUT.prf_i.write_en)
        ) else begin 
            $fatal("prf_wr_en must be 1 in type I instruction");
            $finish;
          end;
   
   assert property (@(posedge clk) disable iff (!arst_n)
        (microprocessor_DUT.cu_i.opcode == OPCODE_I_TYPE) |-> (!microprocessor_DUT.data_mem_i.wr_en)
        ) else begin 
            $fatal("mem_wr_en must be 0 in type I instruction");
            $finish;
   end;
   
   assert property (@(posedge clk) disable iff (!arst_n)
        (microprocessor_DUT.cu_i.opcode == OPCODE_I_TYPE) |-> (microprocessor_DUT.imm_gen_i.imm_out == {{20{microprocessor_DUT.instr_mem_i.instr[31]}}, microprocessor_DUT.instr_mem_i.instr[31:20]})
        ) else begin
            $fatal("I-immediate sign-extension wrong");
            $finish;
   end;
   
   assert property (@(posedge clk) disable iff (!arst_n)
        ((microprocessor_DUT.cu_i.opcode == OPCODE_I_TYPE) && (microprocessor_DUT.cu_i.funct_3 == ADDI)) |-> (microprocessor_DUT.alu_i.alu_result == (microprocessor_DUT.prf_i.read_data1 + microprocessor_DUT.imm_gen_i.imm_out))
        ) else begin 
            $fatal("ADDI ALU result mismatch");
            $finish;
   end;
   
   assert property (@(posedge clk) disable iff (!arst_n)
        ((microprocessor_DUT.cu_i.opcode == OPCODE_I_TYPE) && (microprocessor_DUT.cu_i.funct_3 == SLTI)) |-> (microprocessor_DUT.alu_i.alu_result == (($signed(microprocessor_DUT.prf_i.read_data1) < $signed(microprocessor_DUT.imm_gen_i.imm_out)) ? 32'd1 : 32'd0))
        ) else begin 
            $fatal("SLTI mismatch");
            $finish;
   end;
   
   assert property (@(posedge clk) disable iff (!arst_n)
        ((microprocessor_DUT.cu_i.opcode == OPCODE_I_TYPE) && (microprocessor_DUT.cu_i.funct_3 == SLTIU)) |-> (microprocessor_DUT.alu_i.alu_result == ((microprocessor_DUT.prf_i.read_data1 < microprocessor_DUT.imm_gen_i.imm_out) ? 32'd1 : 32'd0))
        ) else begin 
            $fatal("SLTIU mismatch");
            $finish;
   end;
   
   assert property (@(posedge clk) disable iff (!arst_n)
          ((microprocessor_DUT.cu_i.opcode == OPCODE_I_TYPE) && (microprocessor_DUT.cu_i.funct_3 == XORI)) |-> (microprocessor_DUT.alu_i.alu_result == (microprocessor_DUT.prf_i.read_data1 ^ microprocessor_DUT.imm_gen_i.imm_out))
          ) else begin 
            $fatal("XORI mismatch");
            $finish;
   end;

   assert property (@(posedge clk) disable iff (!arst_n)
          ((microprocessor_DUT.cu_i.opcode == OPCODE_I_TYPE) && (microprocessor_DUT.cu_i.funct_3 == ORI)) |-> (microprocessor_DUT.alu_i.alu_result == (microprocessor_DUT.prf_i.read_data1 | microprocessor_DUT.imm_gen_i.imm_out))
          ) else begin 
            $fatal("ORI mismatch");
            $finish;
   end;

   assert property (@(posedge clk) disable iff (!arst_n)
          ((microprocessor_DUT.cu_i.opcode == OPCODE_I_TYPE) && (microprocessor_DUT.cu_i.funct_3 == ANDI)) |-> (microprocessor_DUT.alu_i.alu_result == (microprocessor_DUT.prf_i.read_data1 & microprocessor_DUT.imm_gen_i.imm_out))
          ) else begin 
            $fatal("ORI mismatch");
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

