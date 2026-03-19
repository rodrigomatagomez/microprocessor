# ==============================================
# ========== SRAM(s0) ==========================
../../sram/defines.svh
../../sram/sram_cell.sv
../../sram/write_driver.sv
../../sram/decoder.sv
../../sram/sense_amp.sv
../../sram/cell_array.sv
../../sram/sipo.sv
../../sram/sram_ip.sv
../../sram/wb_master.sv
../../sram/wb_mem.sv
../../sram/wb_ram.sv
../../sram/wb_reg.sv
../../sram/wb_sram.sv
../../sram/wb_interconnect.sv
../../sram/wb_top.sv     
# ==============================================
# ========== TEMP_SENSOR(s2) ===================
# ============================ rtl
../../temp_mon/wb_master.sv
../../temp_mon/comparador_temp.sv
../../temp_mon/persistencia_ctr.sv
../../temp_mon/estado_temp.sv
../../temp_mon/wb_slave2.sv
../../temp_mon/top_wishbone.sv
# ==============================================
# ========== SERVO(s3) =========================
# ============================ rtl
../../servo/conv_g_to_b.sv
../../servo/control_pid.sv
../../servo/mux.sv
../../servo/pwm.sv
../../servo/current_process.sv
../../servo/adc.sv
../../servo/current_monitor.sv
../../servo/top_servo.sv


# ==============================================
# ========== MICROPROCESSOR(m0) ================
# ============================ pckg, svh, rtl
../../microprocessor/riscv_params_pkg.sv
../../microprocessor/mac_defs.svh
../../microprocessor/mux.sv
../../microprocessor/mux_operand_1.sv
../../microprocessor/program_counter.sv
../../microprocessor/plus_4_or_2_mux.sv
../../microprocessor/adder.sv
../../microprocessor/instruction_memory.sv
../../microprocessor/physical_register_file.sv
../../microprocessor/imm_gen.sv
../../microprocessor/alu.sv
../../microprocessor/branch.sv
../../microprocessor/data_memory.sv
../../microprocessor/mux_3_to_1.sv
../../microprocessor/control_unit.sv
#============================ MAC
../../microprocessor/accumulator_unit.sv
../../microprocessor/mac_adder.sv
../../microprocessor/booth_datapath.sv
../../microprocessor/booth_fsm.sv
../../microprocessor/booth_multiplier.sv
../../microprocessor/mac_top.sv
#============================== TOP
../../microprocessor/microprocessor_top.sv

