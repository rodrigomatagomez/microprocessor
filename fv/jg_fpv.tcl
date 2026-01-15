clear -all

set sepIdx [lsearch $argv ---]
if {$sepIdx == -1 || [expr {$sepIdx + 1}] >= [llength $argv]} {
  puts "-Uso: jg -tcl jg_fpv.tcl --- <nombre_top_module>" 
  exit 1
}
set FV_TOP [lindex $argv [expr {$sepIdx + 1}]]

### add here secundary files for analysis if needed

### ----------------------------------

set RTL_DIR "../rtl"
set FV_DIR  "."

foreach f {
  defines.svh
  program_counter.sv
  plus_4_or_2_mux.sv
  adder.sv
  instruction_memory.sv
  physical_register_file.sv
  mux.sv
  alu.sv
  data_memory.sv
  imm_gen.sv
  control_unit.sv
  branch.sv
  mux_3_to_1.sv
  microprocessor_top.sv
} {
  eval analyze -sv $RTL_DIR/$f
}

eval analyze -sv $FV_DIR/fv_$FV_TOP.sv

elaborate -top $FV_TOP
get_design_info

clock clk
reset -expression !arst_n

prove -all

