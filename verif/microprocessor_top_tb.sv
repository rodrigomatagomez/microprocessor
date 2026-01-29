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
    .dbg_dmem_rdata(micro_vif.dmem_rdata)
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
pc_aligned: assert property (
  @(posedge micro_vif.clk) disable iff (!micro_vif.arst_n)
    (micro_vif.pc[1:0] == 2'b00)
) else begin
    $fatal("PC alignment error: pc=%0h", micro_vif.pc);
    $finish;
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
