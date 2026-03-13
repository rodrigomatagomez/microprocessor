module wishbone_top #(parameter AW = 16, parameter DW = 32)(
  input logic clk,
  input logic rst_n,
  // ----- Command -----
  input logic [AW-1:0]  cmd_addr,
  input logic [DW-1:0]  cmd_wdata,
  input logic           cmd_we,
  input logic           cmd_valid,
  output logic          cmd_ready,

  //  ----Response ------
  output logic [DW-1:0] rsp_rdata,
  output logic          rsp_valid
);
  
  //  -----INTERNAL SIGNALS---------
  //SLAVE
  logic [AW-1:0] wbs_adr_i;
  logic [DW-1:0] wbs_dat_i;
  logic [DW-1:0] wbs_dat_o;
  logic          wbs_we_i;
  logic [3:0]    wbs_sel_i;
  logic          wbs_stb_i;
  logic          wbs_cyc_i;
  logic          wbs_ack_o;
  logic          wbs_err_o;
  logic [DW-1:0] reg_out;

    // ---- Master 0 ----
    wb_master #(.AW(AW), .DW(DW)) u_m0 (
        .clk         (clk),
        .rst_n       (rst_n),
        .cmd_addr    (cmd_addr),
        .cmd_wdata   (cmd_wdata),
        .cmd_we      (cmd_we),
        .cmd_valid   (cmd_valid),
        .cmd_ready   (cmd_ready),
        .rsp_rdata   (rsp_rdata),
        .rsp_valid   (rsp_valid),
        .wbm_adr_o   (wbs_adr_i),
        .wbm_dat_o   (wbs_dat_i),
        .wbm_dat_i   (wbs_dat_o),
        .wbm_we_o    (wbs_we_i),
        .wbm_sel_o   (wbs_sel_i),
        .wbm_stb_o   (wbs_stb_i),
        .wbm_cyc_o   (wbs_cyc_i),
        .wbm_ack_i   (wbs_ack_o),
        .wbm_err_i   (wbs_err_o)
    );
 
    // ---- Slave 0 — wb_reg ----
    wb_reg #(.AW(AW), .DW(DW)) u_reg (
        .clk       (clk),
        .rst_n     (rst_n),
        .wbs_adr_i (wbs_adr_i),
        .wbs_dat_i (wbs_dat_i),
        .wbs_dat_o (wbs_dat_o),
        .wbs_we_i  (wbs_we_i),
        .wbs_sel_i (wbs_sel_i),
        .wbs_stb_i (wbs_stb_i),
        .wbs_cyc_i (wbs_cyc_i),
        .wbs_ack_o (wbs_ack_o),
        .wbs_err_o (wbs_err_o),
        .reg_out   (reg_out)
    );


endmodule 
