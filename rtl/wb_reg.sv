`timescale 1ns/1ps

module wb_reg #(parameter AW = 16, parameter DW =32)(
  input logic clk,
  input logic rst_n,
  
  input logic  [AW-1:0] wbs_adr_i,  //Not using yet
  input logic  [DW-1:0] wbs_dat_i,
  output logic [DW-1:0] wbs_dat_o,
  input logic           wbs_we_i,
  input logic  [3:0]    wbs_sel_i,  //Not usign yet
  input logic           wbs_stb_i,
  input logic           wbs_cyc_i,
  output logic          wbs_ack_o,
  output logic          wbs_err_o,  //Not using yet

  output logic [DW-1:0] reg_out
);

logic [DW-1:0] register;

  always_ff @(posedge clk) begin 
    if(!rst_n) begin             //Syncronous reset active with '0'
      wbs_ack_o <= 1'b0;
      wbs_err_o <= 1'b0;
      wbs_dat_o <= '0;
      register  <= '0;
    end else begin 
      wbs_ack_o <= 1'b0; // No ack by default 

      if(wbs_cyc_i && wbs_stb_i) begin 
        wbs_ack_o <= 1'b1;    //Say to the master "Transsaction is complete"
        if (wbs_we_i) begin   //When write  
          register <= wbs_dat_i;
        end else begin        //Then is a read 
          wbs_dat_o <= register;
        end
      end
    end
  end

  assign reg_out = register;

endmodule
