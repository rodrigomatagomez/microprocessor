// fv/fv_bind_prf.sv
`timescale 1ns/1ps

//------------------------------------------------------------------------------
// Bind: attach fv_prf_checker to every instance of physical_register_file
//------------------------------------------------------------------------------

bind physical_register_file fv_prf_checker #(
  .DIR_W  (DIR_WIDTH),
  .DATA_W (DATA_WIDTH)
) u_fv_prf_checker (
  .clk        (clk),
  .arst_n     (arst_n),
  .write_en   (write_en),
  .read_dir1  (read_dir1),
  .read_dir2  (read_dir2),
  .write_dir  (write_dir),
  .write_data (write_data),
  .read_data1 (read_data1),
  .read_data2 (read_data2)
);

