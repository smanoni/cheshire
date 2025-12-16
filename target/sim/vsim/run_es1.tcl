set BINARY ../../../sw/tests/array_traversal.dram.memh
set PRELMODE 3
source compile.cheshire_soc.tcl
source start.cheshire_soc.tcl

# Create the VCD file
vcd file waves.vcd

# Add your 2 signals to the VCD
vcd add sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/gen_cache_wb/i_cache_subsystem/dcache_miss_o
vcd add sim:/tb_cheshire_soc/fix/dut/gen_cva6_cores[0]/i_core_cva6/csr_regfile_i/cycle_q