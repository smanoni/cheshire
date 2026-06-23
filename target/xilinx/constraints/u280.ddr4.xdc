# Copyright 2022 ETH Zurich and University of Bologna.
# Solderpad Hardware License, Version 0.51, see LICENSE for details.
# SPDX-License-Identifier: SHL-0.51
#
# Simone Manoni <s.manoni@unibo.it>
#
# U280 DDR4-specific constraints (DRAM controller = DDR4 MIG). Loaded by
# impl_sys.tcl when USE_HBM is not set.

#######
# MIG #
#######

# Dram axi clock : 333 MHz (defined by MIG constraints)
set MIG_TCK 3

# False-path incoming reset
set MIG_RST_I [get_pin i_dram_wrapper/i_dram/c0_ddr4_aresetn]
set_false_path -hold -setup -through $MIG_RST_I

# Constrain outgoing reset
set MIG_RST_O [get_pins i_dram_wrapper/i_dram/c0_ddr4_ui_clk_sync_rst]
set_false_path -hold -through $MIG_RST_O
set_max_delay -through $MIG_RST_O $MIG_TCK

# Limit delay across DRAM CDC (hold already false-pathed)
# tclint-disable line-length
set_max_delay -datapath_only \
    -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
    -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*i_sync/reg*/D] $MIG_TCK
set_max_delay -datapath_only \
    -from [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/*reg*/C] \
    -to [get_pins i_dram_wrapper/gen_cdc.i_axi_cdc_mig/i_axi_cdc_*/i_cdc_fifo_gray_*/i_spill_register/spill_register_flushable_i/*reg*/D] $MIG_TCK
# tclint-enable line-length

###############
# Assign Pins #
###############

# tclint-disable line-length, spacing

# DDR4 pin placement: from the official Alveo U280 board XDC (DDR4 C0, 64-bit, NO_DM_NO_DBI).
set_property PACKAGE_PIN BH41 [get_ports "c0_ddr4_act_n"    ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_act_n"    ]
set_property PACKAGE_PIN BG33 [get_ports "c0_ddr4_reset_n"  ] ; set_property IOSTANDARD LVCMOS12         [get_ports "c0_ddr4_reset_n"  ]
set_property PACKAGE_PIN BH46 [get_ports "c0_ddr4_ck_t[0]"  ] ; set_property IOSTANDARD DIFF_SSTL12_DCI  [get_ports "c0_ddr4_ck_t[0]"  ]
set_property PACKAGE_PIN BJ46 [get_ports "c0_ddr4_ck_c[0]"  ] ; set_property IOSTANDARD DIFF_SSTL12_DCI  [get_ports "c0_ddr4_ck_c[0]"  ]
set_property PACKAGE_PIN BH42 [get_ports "c0_ddr4_cke[0]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_cke[0]"   ]
set_property PACKAGE_PIN BK46 [get_ports "c0_ddr4_cs_n[0]"  ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_cs_n[0]"  ]
set_property PACKAGE_PIN BG44 [get_ports "c0_ddr4_odt[0]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_odt[0]"   ]
set_property PACKAGE_PIN BF41 [get_ports "c0_ddr4_bg[0]"    ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_bg[0]"    ]
set_property PACKAGE_PIN BH45 [get_ports "c0_ddr4_ba[0]"    ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_ba[0]"    ]
set_property PACKAGE_PIN BM47 [get_ports "c0_ddr4_ba[1]"    ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_ba[1]"    ]
set_property PACKAGE_PIN BF46 [get_ports "c0_ddr4_adr[0]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[0]"   ]
set_property PACKAGE_PIN BG43 [get_ports "c0_ddr4_adr[1]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[1]"   ]
set_property PACKAGE_PIN BK45 [get_ports "c0_ddr4_adr[2]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[2]"   ]
set_property PACKAGE_PIN BF42 [get_ports "c0_ddr4_adr[3]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[3]"   ]
set_property PACKAGE_PIN BL45 [get_ports "c0_ddr4_adr[4]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[4]"   ]
set_property PACKAGE_PIN BF43 [get_ports "c0_ddr4_adr[5]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[5]"   ]
set_property PACKAGE_PIN BG42 [get_ports "c0_ddr4_adr[6]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[6]"   ]
set_property PACKAGE_PIN BL43 [get_ports "c0_ddr4_adr[7]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[7]"   ]
set_property PACKAGE_PIN BK43 [get_ports "c0_ddr4_adr[8]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[8]"   ]
set_property PACKAGE_PIN BM42 [get_ports "c0_ddr4_adr[9]"   ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[9]"   ]
set_property PACKAGE_PIN BG45 [get_ports "c0_ddr4_adr[10]"  ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[10]"  ]
set_property PACKAGE_PIN BD41 [get_ports "c0_ddr4_adr[11]"  ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[11]"  ]
set_property PACKAGE_PIN BL42 [get_ports "c0_ddr4_adr[12]"  ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[12]"  ]
set_property PACKAGE_PIN BE44 [get_ports "c0_ddr4_adr[13]"  ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[13]"  ]
set_property PACKAGE_PIN BE43 [get_ports "c0_ddr4_adr[14]"  ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[14]"  ]
set_property PACKAGE_PIN BL46 [get_ports "c0_ddr4_adr[15]"  ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[15]"  ]
set_property PACKAGE_PIN BH44 [get_ports "c0_ddr4_adr[16]"  ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_adr[16]"  ]
set_property PACKAGE_PIN BN32 [get_ports "c0_ddr4_dq[0]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[0]"    ]
set_property PACKAGE_PIN BP32 [get_ports "c0_ddr4_dq[1]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[1]"    ]
set_property PACKAGE_PIN BL30 [get_ports "c0_ddr4_dq[2]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[2]"    ]
set_property PACKAGE_PIN BM30 [get_ports "c0_ddr4_dq[3]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[3]"    ]
set_property PACKAGE_PIN BP29 [get_ports "c0_ddr4_dq[4]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[4]"    ]
set_property PACKAGE_PIN BP28 [get_ports "c0_ddr4_dq[5]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[5]"    ]
set_property PACKAGE_PIN BP31 [get_ports "c0_ddr4_dq[6]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[6]"    ]
set_property PACKAGE_PIN BN31 [get_ports "c0_ddr4_dq[7]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[7]"    ]
set_property PACKAGE_PIN BJ31 [get_ports "c0_ddr4_dq[8]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[8]"    ]
set_property PACKAGE_PIN BH31 [get_ports "c0_ddr4_dq[9]"    ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[9]"    ]
set_property PACKAGE_PIN BF32 [get_ports "c0_ddr4_dq[10]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[10]"   ]
set_property PACKAGE_PIN BF33 [get_ports "c0_ddr4_dq[11]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[11]"   ]
set_property PACKAGE_PIN BH29 [get_ports "c0_ddr4_dq[12]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[12]"   ]
set_property PACKAGE_PIN BH30 [get_ports "c0_ddr4_dq[13]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[13]"   ]
set_property PACKAGE_PIN BF31 [get_ports "c0_ddr4_dq[14]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[14]"   ]
set_property PACKAGE_PIN BG32 [get_ports "c0_ddr4_dq[15]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[15]"   ]
set_property PACKAGE_PIN BK31 [get_ports "c0_ddr4_dq[16]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[16]"   ]
set_property PACKAGE_PIN BL31 [get_ports "c0_ddr4_dq[17]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[17]"   ]
set_property PACKAGE_PIN BK33 [get_ports "c0_ddr4_dq[18]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[18]"   ]
set_property PACKAGE_PIN BL33 [get_ports "c0_ddr4_dq[19]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[19]"   ]
set_property PACKAGE_PIN BL32 [get_ports "c0_ddr4_dq[20]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[20]"   ]
set_property PACKAGE_PIN BM33 [get_ports "c0_ddr4_dq[21]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[21]"   ]
set_property PACKAGE_PIN BN34 [get_ports "c0_ddr4_dq[22]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[22]"   ]
set_property PACKAGE_PIN BP34 [get_ports "c0_ddr4_dq[23]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[23]"   ]
set_property PACKAGE_PIN BH34 [get_ports "c0_ddr4_dq[24]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[24]"   ]
set_property PACKAGE_PIN BH35 [get_ports "c0_ddr4_dq[25]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[25]"   ]
set_property PACKAGE_PIN BF35 [get_ports "c0_ddr4_dq[26]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[26]"   ]
set_property PACKAGE_PIN BF36 [get_ports "c0_ddr4_dq[27]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[27]"   ]
set_property PACKAGE_PIN BJ33 [get_ports "c0_ddr4_dq[28]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[28]"   ]
set_property PACKAGE_PIN BJ34 [get_ports "c0_ddr4_dq[29]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[29]"   ]
set_property PACKAGE_PIN BG34 [get_ports "c0_ddr4_dq[30]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[30]"   ]
set_property PACKAGE_PIN BG35 [get_ports "c0_ddr4_dq[31]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[31]"   ]
set_property PACKAGE_PIN BM52 [get_ports "c0_ddr4_dq[32]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[32]"   ]
set_property PACKAGE_PIN BL53 [get_ports "c0_ddr4_dq[33]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[33]"   ]
set_property PACKAGE_PIN BL52 [get_ports "c0_ddr4_dq[34]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[34]"   ]
set_property PACKAGE_PIN BL51 [get_ports "c0_ddr4_dq[35]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[35]"   ]
set_property PACKAGE_PIN BN50 [get_ports "c0_ddr4_dq[36]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[36]"   ]
set_property PACKAGE_PIN BN51 [get_ports "c0_ddr4_dq[37]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[37]"   ]
set_property PACKAGE_PIN BN49 [get_ports "c0_ddr4_dq[38]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[38]"   ]
set_property PACKAGE_PIN BM48 [get_ports "c0_ddr4_dq[39]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[39]"   ]
set_property PACKAGE_PIN BE50 [get_ports "c0_ddr4_dq[40]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[40]"   ]
set_property PACKAGE_PIN BE49 [get_ports "c0_ddr4_dq[41]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[41]"   ]
set_property PACKAGE_PIN BE51 [get_ports "c0_ddr4_dq[42]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[42]"   ]
set_property PACKAGE_PIN BD51 [get_ports "c0_ddr4_dq[43]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[43]"   ]
set_property PACKAGE_PIN BF52 [get_ports "c0_ddr4_dq[44]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[44]"   ]
set_property PACKAGE_PIN BF51 [get_ports "c0_ddr4_dq[45]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[45]"   ]
set_property PACKAGE_PIN BG50 [get_ports "c0_ddr4_dq[46]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[46]"   ]
set_property PACKAGE_PIN BF50 [get_ports "c0_ddr4_dq[47]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[47]"   ]
set_property PACKAGE_PIN BH50 [get_ports "c0_ddr4_dq[48]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[48]"   ]
set_property PACKAGE_PIN BJ51 [get_ports "c0_ddr4_dq[49]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[49]"   ]
set_property PACKAGE_PIN BH51 [get_ports "c0_ddr4_dq[50]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[50]"   ]
set_property PACKAGE_PIN BH49 [get_ports "c0_ddr4_dq[51]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[51]"   ]
set_property PACKAGE_PIN BK50 [get_ports "c0_ddr4_dq[52]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[52]"   ]
set_property PACKAGE_PIN BK51 [get_ports "c0_ddr4_dq[53]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[53]"   ]
set_property PACKAGE_PIN BJ49 [get_ports "c0_ddr4_dq[54]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[54]"   ]
set_property PACKAGE_PIN BJ48 [get_ports "c0_ddr4_dq[55]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[55]"   ]
set_property PACKAGE_PIN BN44 [get_ports "c0_ddr4_dq[56]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[56]"   ]
set_property PACKAGE_PIN BN45 [get_ports "c0_ddr4_dq[57]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[57]"   ]
set_property PACKAGE_PIN BM44 [get_ports "c0_ddr4_dq[58]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[58]"   ]
set_property PACKAGE_PIN BM45 [get_ports "c0_ddr4_dq[59]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[59]"   ]
set_property PACKAGE_PIN BP43 [get_ports "c0_ddr4_dq[60]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[60]"   ]
set_property PACKAGE_PIN BP44 [get_ports "c0_ddr4_dq[61]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[61]"   ]
set_property PACKAGE_PIN BN47 [get_ports "c0_ddr4_dq[62]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[62]"   ]
set_property PACKAGE_PIN BP47 [get_ports "c0_ddr4_dq[63]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[63]"   ]
set_property PACKAGE_PIN BN29 [get_ports "c0_ddr4_dqs_t[0]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[0]" ]
set_property PACKAGE_PIN BN30 [get_ports "c0_ddr4_dqs_c[0]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[0]" ]
set_property PACKAGE_PIN BM28 [get_ports "c0_ddr4_dqs_t[1]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[1]" ]
set_property PACKAGE_PIN BM29 [get_ports "c0_ddr4_dqs_c[1]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[1]" ]
set_property PACKAGE_PIN BJ29 [get_ports "c0_ddr4_dqs_t[2]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[2]" ]
set_property PACKAGE_PIN BK30 [get_ports "c0_ddr4_dqs_c[2]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[2]" ]
set_property PACKAGE_PIN BG29 [get_ports "c0_ddr4_dqs_t[3]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[3]" ]
set_property PACKAGE_PIN BG30 [get_ports "c0_ddr4_dqs_c[3]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[3]" ]
set_property PACKAGE_PIN BL35 [get_ports "c0_ddr4_dqs_t[4]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[4]" ]
set_property PACKAGE_PIN BM35 [get_ports "c0_ddr4_dqs_c[4]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[4]" ]
set_property PACKAGE_PIN BM34 [get_ports "c0_ddr4_dqs_t[5]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[5]" ]
set_property PACKAGE_PIN BN35 [get_ports "c0_ddr4_dqs_c[5]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[5]" ]
set_property PACKAGE_PIN BK34 [get_ports "c0_ddr4_dqs_t[6]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[6]" ]
set_property PACKAGE_PIN BK35 [get_ports "c0_ddr4_dqs_c[6]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[6]" ]
set_property PACKAGE_PIN BH32 [get_ports "c0_ddr4_dqs_t[7]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[7]" ]
set_property PACKAGE_PIN BJ32 [get_ports "c0_ddr4_dqs_c[7]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[7]" ]
set_property PACKAGE_PIN BM49 [get_ports "c0_ddr4_dqs_t[8]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[8]" ]
set_property PACKAGE_PIN BM50 [get_ports "c0_ddr4_dqs_c[8]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[8]" ]
set_property PACKAGE_PIN BP48 [get_ports "c0_ddr4_dqs_t[9]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[9]" ]
set_property PACKAGE_PIN BP49 [get_ports "c0_ddr4_dqs_c[9]" ] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[9]" ]
set_property PACKAGE_PIN BF47 [get_ports "c0_ddr4_dqs_t[10]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[10]"]
set_property PACKAGE_PIN BF48 [get_ports "c0_ddr4_dqs_c[10]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[10]"]
set_property PACKAGE_PIN BG48 [get_ports "c0_ddr4_dqs_t[11]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[11]"]
set_property PACKAGE_PIN BG49 [get_ports "c0_ddr4_dqs_c[11]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[11]"]
set_property PACKAGE_PIN BH47 [get_ports "c0_ddr4_dqs_t[12]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[12]"]
set_property PACKAGE_PIN BJ47 [get_ports "c0_ddr4_dqs_c[12]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[12]"]
set_property PACKAGE_PIN BK48 [get_ports "c0_ddr4_dqs_t[13]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[13]"]
set_property PACKAGE_PIN BK49 [get_ports "c0_ddr4_dqs_c[13]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[13]"]
set_property PACKAGE_PIN BN46 [get_ports "c0_ddr4_dqs_t[14]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[14]"]
set_property PACKAGE_PIN BP46 [get_ports "c0_ddr4_dqs_c[14]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[14]"]
set_property PACKAGE_PIN BN42 [get_ports "c0_ddr4_dqs_t[15]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[15]"]
set_property PACKAGE_PIN BP42 [get_ports "c0_ddr4_dqs_c[15]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[15]"]
set_property PACKAGE_PIN BH54 [get_ports "c0_ddr4_dqs_t[16]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[16]"]
set_property PACKAGE_PIN BJ54 [get_ports "c0_ddr4_dqs_c[16]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[16]"]
set_property PACKAGE_PIN BJ52 [get_ports "c0_ddr4_dqs_t[17]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[17]"]
set_property PACKAGE_PIN BJ53 [get_ports "c0_ddr4_dqs_c[17]"] ; set_property IOSTANDARD DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[17]"]
set_property PACKAGE_PIN BG54 [get_ports "c0_ddr4_dq[64]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[64]"   ]
set_property PACKAGE_PIN BG53 [get_ports "c0_ddr4_dq[65]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[65]"   ]
set_property PACKAGE_PIN BE53 [get_ports "c0_ddr4_dq[66]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[66]"   ]
set_property PACKAGE_PIN BE54 [get_ports "c0_ddr4_dq[67]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[67]"   ]
set_property PACKAGE_PIN BH52 [get_ports "c0_ddr4_dq[68]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[68]"   ]
set_property PACKAGE_PIN BG52 [get_ports "c0_ddr4_dq[69]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[69]"   ]
set_property PACKAGE_PIN BK54 [get_ports "c0_ddr4_dq[70]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[70]"   ]
set_property PACKAGE_PIN BK53 [get_ports "c0_ddr4_dq[71]"   ] ; set_property IOSTANDARD POD12_DCI        [get_ports "c0_ddr4_dq[71]"   ]
set_property PACKAGE_PIN BE41 [get_ports "c0_ddr4_bg[1]"    ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports "c0_ddr4_bg[1]"    ]
set_property PACKAGE_PIN BF45 [get_ports  {c0_ddr4_parity}  ] ; set_property IOSTANDARD SSTL12_DCI       [get_ports  {c0_ddr4_parity}  ]
# tclint-enable line-length, spacing
