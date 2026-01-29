module tb;

  logic clk;
  micro_if #(32) micro_vif(clk);

  // Clock
  initial clk = 0;
  always #5ns clk = ~clk;

  // DUT
  microprocessor_top dut (
    .clk(clk),
    .arst_n(micro_vif.arst_n),

    .dbg_pc(micro_vif.pc),
    .dbg_instr(micro_vif.instr),

    .dbg_wb_we(micro_vif.wb_we),
    .dbg_wb_rd(micro_vif.wb_rd),
    .dbg_wb_data(micro_vif.wb_data),

    .dbg_dmem_we(micro_vif.dmem_we),
    .dbg_dmem_addr(micro_vif.dmem_addr),
    .dbg_dmem_wdata(micro_vif.dmem_wdata),
    .dbg_dmem_rdata(micro_vif.dmem_rdata),

    .dbg_cu_opcode(micro_vif.cu_opcode),
    .dbg_cu_branch_taken(micro_vif.cu_branch_taken),

    .dbg_alu_operand_1(micro_vif.alu_operand_1),
    .dbg_alu_operand_2(micro_vif.alu_operand_2),
    .dbg_alu_result(micro_vif.alu_result),

    .dbg_imm_out(micro_vif.imm_out)
  );

  initial begin
    micro_vif.apply_reset(5);
    #200ns 
    $finish;
  end
//---------------------------------------------------------
//  ASSERTS
//---------------------------------------------------------
//  PROGRAM COUNTER 
//---------------------------------------------------------
pc_aligned: assert property (@(posedge micro_vif.clk) disable iff (!micro_vif.arst_n)
    (micro_vif.pc[1:0] == 2'b00)
    ) else begin
        $error("PC alignment error: pc=%0h", micro_vif.pc);
end

pc_branch: assert property (@(posedge micro_vif.clk) disable iff (!micro_vif.arst_n)
    ((micro_vif.cu_opcode == 7'b110_0011) && (micro_vif.cu_branch_taken)) |=> (micro_vif.pc == (micro_vif.alu_operand_1 + micro_vif.imm_out))
    ) else begin 
        $error("PC should be PC+imm");
end

initial begin // Initial block to open shared memory and probe signals
	$shm_open("shm_db");
	$shm_probe("ASMTR");
end  
//Init PRF and DATA_MEM  
`ifndef prf_init
    initial begin
        for (int i = 1; i < 32; i++) begin  
            dut.prf_i.prf[i] = 32'b0;
        end
end
`endif

`ifndef data_mem_init
    initial begin
        for (int i = 0; i < 1024; i++) begin  
            dut.data_mem_i.mem[i] = 32'b0;
        end
    end
`endif
endmodule
