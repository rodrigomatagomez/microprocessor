//------------------------------------------------------------------------------
// Bind file for program_counter
// Attaches fv_pc_checker to every instance of program_counter
//------------------------------------------------------------------------------

bind program_counter
  fv_pc_checker #(
    .DATA_W(DATA_WIDTH),
    .RESET_PC(RESET_PC)
  ) u_fv_pc_checker (
    .clk    (clk),
    .arst_n (arst_n),
    .pc_in  (pc_in),
    .pc_out (pc_out)
  );

