# ============================ pckg, svh
../../rtl/riscv_params_pkg.sv
../../fv/property_defines.svh
# ============================ rtl
../../rtl/mux.sv
../../rtl/mux_operand_1.sv
../../rtl/program_counter.sv
../../rtl/plus_4_or_2_mux.sv
../../rtl/adder.sv
../../rtl/instruction_memory.sv
../../rtl/physical_register_file.sv
../../rtl/imm_gen.sv
../../rtl/alu.sv
../../rtl/branch.sv
../../rtl/data_memory.sv
../../rtl/mux_3_to_1.sv
../../rtl/control_unit.sv
../../rtl/microprocessor_top.sv
# ============================ formal verification

#../../fv/fv_pc_checker.sv
#../../fv/fv_bind_pc.sv
#../../fv/fv_prf_checker.sv
#../../fv/fv_bind_prf.sv      
# ============================ verification
../instruction_generator.sv
../instr_kind_decode_for_waves.sv
../instr_drive_if.sv
../microprocessor_if.sv
../microprocessor_probe_bridge.sv
../../fv/fv_microprocessor_top.sv
../microprocessor_top_tb.sv
