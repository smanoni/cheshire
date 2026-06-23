// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Simone Manoni <s.manoni@unibo.it>
//
// Resize AXI DW and IW, cross to the HBM AXI clock, split bursts to AXI3
// limits, and connect to the Xilinx HBM controller (single AXI_00 port).

`include "cheshire/typedef.svh"
`include "phy_definitions.svh"
`include "common_cells/registers.svh"

module hbm_wrapper_xilinx #(
  parameter type axi_soc_aw_chan_t = logic,
  parameter type axi_soc_w_chan_t  = logic,
  parameter type axi_soc_b_chan_t  = logic,
  parameter type axi_soc_ar_chan_t = logic,
  parameter type axi_soc_r_chan_t  = logic,
  parameter type axi_soc_req_t     = logic,
  parameter type axi_soc_resp_t    = logic
) (
  // Controller reset (active low) and SoC-side AXI clock
  input  logic  soc_resetn_i,
  input  logic  soc_clk_i,
  // HBM clocks: reference, APB configuration, and the user AXI clock we supply
  input  logic  hbm_ref_clk_i,
  input  logic  hbm_apb_clk_i,
  input  logic  hbm_axi_clk_i,
  // Catastrophic-temperature trip to the board satellite controller
  output logic  hbm_cattrip_o,
  // DRAM AXI interface
  input  axi_soc_req_t  soc_req_i,
  output axi_soc_resp_t soc_rsp_o
);

  //////////////////////////////////////
  //  Configurations and definitions  //
  //////////////////////////////////////

  // Xilinx HBM IP single AXI port (AXI_00): 256-bit data, 33-bit address (per
  // stack-0 reach), 6-bit ID, AXI3 (16-beat max bursts). See
  // target/xilinx/scripts/impl_ip.tcl and the generated hbm.veo for the exact
  // port widths.
  localparam int unsigned IdWidth     = 6;
  localparam int unsigned AddrWidth   = 33;
  localparam int unsigned DataWidth   = 256;
  localparam int unsigned StrobeWidth = 32;
  localparam int unsigned MaxUniqIds  = 8;  // TODO: limited by CVA6/LLC
  localparam int unsigned MaxTxns     = 24; // TODO: limited by CVA6/LLC
  localparam int unsigned CdcLogDepth = 5;
  // AXI3 maximum burst length is 16 beats (AWLEN/ARLEN are 4 bits wide).
  localparam int unsigned MaxAxi3Len  = 16;

  localparam SocDataWidth = $bits(soc_req_i.w.data);
  localparam SocIdWidth   = $bits(soc_req_i.ar.id);
  localparam SocUserWidth = $bits(soc_req_i.ar.user);
  localparam SocAddrWidth = $bits(soc_req_i.ar.addr);

  // Define type after data width and address resizer
  `AXI_TYPEDEF_ALL(axi_dw, logic[SocAddrWidth-1:0], logic[SocIdWidth-1:0],
                   logic[DataWidth-1:0], logic[StrobeWidth-1:0],
                   logic[SocUserWidth-1:0])

  // Define type after data & id width resizers
  `AXI_TYPEDEF_ALL(axi_dw_iw, logic[SocAddrWidth-1:0], logic[IdWidth-1:0],
                   logic[DataWidth-1:0], logic[StrobeWidth-1:0],
                   logic[SocUserWidth-1:0])

  // Signals before resizing
  axi_soc_req_t  soc_dresizer_req;
  axi_soc_resp_t soc_dresizer_rsp;

  // Signals after data width resizing
  axi_dw_req_t  dresizer_iresizer_req;
  axi_dw_resp_t dresizer_iresizer_rsp;

  // Signals after id width resizing
  axi_dw_iw_req_t  iresizer_cdc_req, cdc_split_req, split_hbm_req;
  axi_dw_iw_resp_t iresizer_cdc_rsp, cdc_split_rsp, split_hbm_rsp;

  // Entry signals
  assign soc_dresizer_req = soc_req_i;
  assign soc_rsp_o = soc_dresizer_rsp;

  ////////////////////////////////
  //  HBM AXI domain reset gen  //
  ////////////////////////////////

  // The HBM IP brings itself up over APB after reset and asserts
  // `apb_complete_0` when done. Hold the user AXI port in reset (and thus the
  // CDC/burst-splitter destination domain) until init completes.
  logic apb_complete;
  logic apb_complete_sync;
  logic hbm_axi_rst_n;

  sync #(
    .STAGES     ( 3    ),
    .ResetValue ( 1'b0 )
  ) i_apb_complete_sync (
    .clk_i    ( hbm_axi_clk_i ),
    .rst_ni   ( soc_resetn_i  ),
    .serial_i ( apb_complete  ),
    .serial_o ( apb_complete_sync )
  );

  rstgen i_hbm_axi_rstgen (
    .clk_i       ( hbm_axi_clk_i ),
    .rst_ni      ( soc_resetn_i & apb_complete_sync ),
    .test_mode_i ( 1'b0 ),
    .rst_no      ( hbm_axi_rst_n ),
    .init_no     ( )
  );

  ////////////////////
  //  DW converter  //
  ////////////////////

  axi_dw_converter #(
    .AxiMaxReads          ( MaxTxns      ),
    .AxiSlvPortDataWidth  ( SocDataWidth ),
    .AxiMstPortDataWidth  ( DataWidth    ),
    .AxiAddrWidth         ( SocAddrWidth ),
    .AxiIdWidth           ( SocIdWidth   ),
    // Common AW, AR, B
    .aw_chan_t            ( axi_soc_aw_chan_t ),
    .b_chan_t             ( axi_soc_b_chan_t  ),
    .ar_chan_t            ( axi_soc_ar_chan_t ),
    // Manager W, R
    .mst_w_chan_t         ( axi_dw_w_chan_t ),
    .mst_r_chan_t         ( axi_dw_r_chan_t ),
    .axi_mst_req_t        ( axi_dw_req_t    ),
    .axi_mst_resp_t       ( axi_dw_resp_t   ),
    // Subordinate W, R
    .slv_w_chan_t         ( axi_soc_w_chan_t ),
    .slv_r_chan_t         ( axi_soc_r_chan_t ),
    .axi_slv_req_t        ( axi_soc_req_t  ),
    .axi_slv_resp_t       ( axi_soc_resp_t )
  ) i_axi_dw_converter (
    .clk_i      ( soc_clk_i    ),
    .rst_ni     ( soc_resetn_i ),
    .slv_req_i  ( soc_dresizer_req ),
    .slv_resp_o ( soc_dresizer_rsp ),
    .mst_req_o  ( dresizer_iresizer_req ),
    .mst_resp_i ( dresizer_iresizer_rsp )
  );

  //////////////////
  //  ID resizer  //
  //////////////////

  axi_iw_converter #(
    .AxiAddrWidth           ( SocAddrWidth ),
    .AxiDataWidth           ( DataWidth    ),
    .AxiUserWidth           ( SocUserWidth ),
    .AxiSlvPortIdWidth      ( SocIdWidth   ),
    .AxiSlvPortMaxUniqIds   ( MaxUniqIds   ),
    .AxiSlvPortMaxTxnsPerId ( MaxTxns      ),
    .AxiSlvPortMaxTxns      ( MaxTxns      ),
    .AxiMstPortIdWidth      ( IdWidth      ),
    .AxiMstPortMaxUniqIds   ( MaxUniqIds   ),
    .AxiMstPortMaxTxnsPerId ( MaxTxns      ),
    .slv_req_t              ( axi_dw_req_t     ),
    .slv_resp_t             ( axi_dw_resp_t    ),
    .mst_req_t              ( axi_dw_iw_req_t  ),
    .mst_resp_t             ( axi_dw_iw_resp_t )
  ) i_axi_iw_converter (
    .clk_i      ( soc_clk_i    ),
    .rst_ni     ( soc_resetn_i ),
    .slv_req_i  ( dresizer_iresizer_req ),
    .slv_resp_o ( dresizer_iresizer_rsp ),
    .mst_req_o  ( iresizer_cdc_req ),
    .mst_resp_i ( iresizer_cdc_rsp )
  );

  ////////////////////////
  //  Instantiate CDC   //
  ////////////////////////

  axi_cdc #(
    .aw_chan_t  ( axi_dw_iw_aw_chan_t ),
    .w_chan_t   ( axi_dw_iw_w_chan_t  ),
    .b_chan_t   ( axi_dw_iw_b_chan_t  ),
    .ar_chan_t  ( axi_dw_iw_ar_chan_t ),
    .r_chan_t   ( axi_dw_iw_r_chan_t  ),
    .axi_req_t  ( axi_dw_iw_req_t  ),
    .axi_resp_t ( axi_dw_iw_resp_t ),
    .LogDepth   ( CdcLogDepth )
  ) i_axi_cdc_hbm (
    .src_clk_i  ( soc_clk_i     ),
    .src_rst_ni ( soc_resetn_i  ),
    .src_req_i  ( iresizer_cdc_req ),
    .src_resp_o ( iresizer_cdc_rsp ),
    .dst_clk_i  ( hbm_axi_clk_i ),
    .dst_rst_ni ( hbm_axi_rst_n ),
    .dst_req_o  ( cdc_split_req ),
    .dst_resp_i ( cdc_split_rsp )
  );

  /////////////////////////////
  //  AXI4 -> AXI3 splitter  //
  /////////////////////////////

  // The HBM port is AXI3: cap bursts at 16 beats (len_limit is len-1).
  axi_burst_splitter_gran #(
    .MaxReadTxns   ( MaxTxns      ),
    .MaxWriteTxns  ( MaxTxns      ),
    .FullBW        ( 1'b1         ),
    .AddrWidth     ( SocAddrWidth ),
    .DataWidth     ( DataWidth    ),
    .IdWidth       ( IdWidth      ),
    .UserWidth     ( SocUserWidth ),
    .axi_req_t     ( axi_dw_iw_req_t     ),
    .axi_resp_t    ( axi_dw_iw_resp_t    ),
    .axi_aw_chan_t ( axi_dw_iw_aw_chan_t ),
    .axi_w_chan_t  ( axi_dw_iw_w_chan_t  ),
    .axi_b_chan_t  ( axi_dw_iw_b_chan_t  ),
    .axi_ar_chan_t ( axi_dw_iw_ar_chan_t ),
    .axi_r_chan_t  ( axi_dw_iw_r_chan_t  )
  ) i_axi_burst_splitter (
    .clk_i       ( hbm_axi_clk_i ),
    .rst_ni      ( hbm_axi_rst_n ),
    .len_limit_i ( axi_pkg::len_t'(MaxAxi3Len - 1) ),
    .slv_req_i   ( cdc_split_req ),
    .slv_resp_o  ( cdc_split_rsp ),
    .mst_req_o   ( split_hbm_req ),
    .mst_resp_i  ( split_hbm_rsp )
  );

  ////////////////////////////////
  //  Map User, Resize Address  //
  ////////////////////////////////

  assign split_hbm_rsp.b.user = '0;
  assign split_hbm_rsp.r.user = '0;

  logic [AddrWidth-1:0] hbm_req_aw_addr;
  logic [AddrWidth-1:0] hbm_req_ar_addr;

  assign hbm_req_aw_addr = split_hbm_req.aw.addr[AddrWidth-1:0];
  assign hbm_req_ar_addr = split_hbm_req.ar.addr[AddrWidth-1:0];

  ///////////////////////
  //  Instantiate HBM  //
  ///////////////////////

  hbm i_hbm (
    // Reference clock (stack 0)
    .HBM_REF_CLK_0        ( hbm_ref_clk_i ),
    // User AXI port clock/reset (active low)
    .AXI_00_ACLK          ( hbm_axi_clk_i ),
    .AXI_00_ARESET_N      ( hbm_axi_rst_n ),
    // AXI write address
    .AXI_00_AWID          ( split_hbm_req.aw.id      ),
    .AXI_00_AWADDR        ( hbm_req_aw_addr          ),
    .AXI_00_AWLEN         ( split_hbm_req.aw.len[3:0]),
    .AXI_00_AWSIZE        ( split_hbm_req.aw.size    ),
    .AXI_00_AWBURST       ( split_hbm_req.aw.burst   ),
    .AXI_00_AWVALID       ( split_hbm_req.aw_valid   ),
    .AXI_00_AWREADY       ( split_hbm_rsp.aw_ready   ),
    // AXI write data
    .AXI_00_WDATA         ( split_hbm_req.w.data     ),
    .AXI_00_WSTRB         ( split_hbm_req.w.strb     ),
    .AXI_00_WLAST         ( split_hbm_req.w.last     ),
    .AXI_00_WDATA_PARITY  ( '0 ),
    .AXI_00_WVALID        ( split_hbm_req.w_valid    ),
    .AXI_00_WREADY        ( split_hbm_rsp.w_ready    ),
    // AXI write response
    .AXI_00_BREADY        ( split_hbm_req.b_ready    ),
    .AXI_00_BID           ( split_hbm_rsp.b.id       ),
    .AXI_00_BRESP         ( split_hbm_rsp.b.resp     ),
    .AXI_00_BVALID        ( split_hbm_rsp.b_valid    ),
    // AXI read address
    .AXI_00_ARID          ( split_hbm_req.ar.id      ),
    .AXI_00_ARADDR        ( hbm_req_ar_addr          ),
    .AXI_00_ARLEN         ( split_hbm_req.ar.len[3:0]),
    .AXI_00_ARSIZE        ( split_hbm_req.ar.size    ),
    .AXI_00_ARBURST       ( split_hbm_req.ar.burst   ),
    .AXI_00_ARVALID       ( split_hbm_req.ar_valid   ),
    .AXI_00_ARREADY       ( split_hbm_rsp.ar_ready   ),
    // AXI read data
    .AXI_00_RREADY        ( split_hbm_req.r_ready    ),
    .AXI_00_RID           ( split_hbm_rsp.r.id       ),
    .AXI_00_RDATA         ( split_hbm_rsp.r.data     ),
    .AXI_00_RRESP         ( split_hbm_rsp.r.resp     ),
    .AXI_00_RLAST         ( split_hbm_rsp.r.last     ),
    .AXI_00_RVALID        ( split_hbm_rsp.r_valid    ),
    .AXI_00_RDATA_PARITY  ( ),
    // APB configuration: tie off, let the IP self-initialize
    .APB_0_PCLK           ( hbm_apb_clk_i ),
    .APB_0_PRESET_N       ( soc_resetn_i  ),
    .APB_0_PADDR          ( '0 ),
    .APB_0_PWDATA         ( '0 ),
    .APB_0_PWRITE         ( 1'b0 ),
    .APB_0_PSEL           ( 1'b0 ),
    .APB_0_PENABLE        ( 1'b0 ),
    .APB_0_PRDATA         ( ),
    .APB_0_PREADY         ( ),
    .APB_0_PSLVERR        ( ),
    .apb_complete_0       ( apb_complete ),
    // Status
    .DRAM_0_STAT_CATTRIP  ( hbm_cattrip_o ),
    .DRAM_0_STAT_TEMP     ( )
  );

endmodule
