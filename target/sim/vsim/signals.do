onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group LSU_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/lsu_i/fu_data_i}
add wave -noupdate -expand -group LSU_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/lsu_i/lsu_ready_o}
add wave -noupdate -expand -group LSU_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/lsu_i/lsu_valid_i}
add wave -noupdate -expand -group LSU_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/lsu_i/load_result_o}
add wave -noupdate -expand -group LSU_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/lsu_i/load_valid_o}
add wave -noupdate -expand -group LSU_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/lsu_i/store_result_o}
add wave -noupdate -expand -group LSU_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/lsu_i/load_trans_id_o}
add wave -noupdate -expand -group LSU_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/ex_stage_i/lsu_i/store_valid_o}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/dcache_miss_o}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/dcache_req_ports_i}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/dcache_req_ports_o}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/axi_req_o}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/axi_resp_i}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/axi_req_icache}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/axi_resp_icache}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/axi_req_bypass}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/axi_resp_bypass}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/axi_req_data}
add wave -noupdate -expand -group dcache_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/axi_resp_data}
add wave -noupdate -expand -group dcache_ports -radix decimal {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/csr_regfile_i/cycle_q}
add wave -noupdate -expand -group id_stage_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/id_stage_i/issue_entry_o}
add wave -noupdate -expand -group id_stage_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/id_stage_i/orig_instr_o}
add wave -noupdate -expand -group id_stage_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/id_stage_i/issue_entry_valid_o}
add wave -noupdate -expand -group id_stage_ports {/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/id_stage_i/issue_instr_ack_i}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2457390000 ps} 1} {{Cursor 2} {3123235000 ps} 1} {{Cursor 3} {2457570000 ps} 1} {{Cursor 4} {1668180000 ps} 1} {{Cursor 5} {108485361 ps} 0}
quietly wave cursor active 5
configure wave -namecolwidth 690
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {469986200 ps} {583890200 ps}
