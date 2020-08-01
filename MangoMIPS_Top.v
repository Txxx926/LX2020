`include "Defines.v"
`include "Config.v"

module MangoMIPS_Top
(
    input  wire         cpu_clk,
    input  wire         cpu_rstn,
    input  wire [ 5: 0] intr,

    output wire [ 3: 0] m_axi_arid,
    output wire [31: 0] m_axi_araddr,
    output wire [ 3: 0] m_axi_arlen,
    output wire [ 2: 0] m_axi_arsize,
    output wire [ 1: 0] m_axi_arburst,
    output wire [ 1: 0] m_axi_arlock,
    output wire [ 3: 0] m_axi_arcache,
    output wire [ 2: 0] m_axi_arprot,
    output wire         m_axi_arvalid,
    input  wire         m_axi_arready,
    input  wire [ 3: 0] m_axi_rid,
    input  wire [31: 0] m_axi_rdata,
    input  wire [ 1: 0] m_axi_rresp,
    input  wire         m_axi_rlast,
    input  wire         m_axi_rvalid,
    output wire         m_axi_rready,
    output wire [ 3: 0] m_axi_awid,
    output wire [31: 0] m_axi_awaddr,
    output wire [ 3: 0] m_axi_awlen,
    output wire [ 2: 0] m_axi_awsize,
    output wire [ 1: 0] m_axi_awburst,
    output wire [ 1: 0] m_axi_awlock,
    output wire [ 3: 0] m_axi_awcache,
    output wire [ 2: 0] m_axi_awprot,
    output wire         m_axi_awvalid,
    input  wire         m_axi_awready,
    output wire [ 3: 0] m_axi_wid,
    output wire [31: 0] m_axi_wdata,
    output wire [ 3: 0] m_axi_wstrb,
    output wire         m_axi_wlast,
    output wire         m_axi_wvalid,
    input  wire         m_axi_wready,
    input  wire [ 3: 0] m_axi_bid,
    input  wire [ 1: 0] m_axi_bresp,
    input  wire         m_axi_bvalid,
    output wire         m_axi_bready,
        output   [31:0] debug_pc_master,
        output   [31:0] debug_pc_slave,
        output   [3:0] debug_wb_rf_wen_master,
        output   [4:0] debug_wb_rf_wnum_master,
        output   [3:0] debug_wb_rf_wen_slave,
        output   [4:0] debug_wb_rf_wnum_slave,
        output   [31:0] debug_wb_rf_wdata_master,
        output   [31:0] debug_wb_rf_wdata_slave
);

    reg  rstn;
    always @(posedge cpu_clk) 
        rstn <= cpu_rstn;

    wire [1:0]      inst_en;
    wire [`AddrBus] inst_addr;
    wire [31:0]     inst_rdata_1;
    wire [31:0]     inst_rdata_2;
    wire            inst_ready_1;
    wire            inst_ready_2;
    wire            inst_streq;
    wire            inst_stall;
    wire            inst_cached;

    wire [1:0]      data_en;
    wire [`AddrBus] data_addr;
    wire [`DataBus] data_rdata;
    wire [`ByteWEn] data_wen;
    wire [`DataBus] data_wdata;
    wire [2:0]      data_size;
    wire            data_streq;
    wire            data_stall;
    wire            data_cached;
    
    wire [`CacheOp] cacheop;
    wire [`DataBus] cop_tag;

    wire [ 3: 0] ibus_arid;
    wire [31: 0] ibus_araddr;
    wire [ 3: 0] ibus_arlen;
    wire [ 2: 0] ibus_arsize;
    wire [ 1: 0] ibus_arburst;
    wire [ 1: 0] ibus_arlock;
    wire [ 3: 0] ibus_arcache;
    wire [ 2: 0] ibus_arprot;
    wire         ibus_arvalid;
    wire         ibus_arready;
    wire [ 3: 0] ibus_rid;
    wire [31: 0] ibus_rdata;
    wire [ 1: 0] ibus_rresp;
    wire         ibus_rlast;
    wire         ibus_rvalid;
    wire         ibus_rready;
    wire [ 3: 0] ibus_awid;
    wire [31: 0] ibus_awaddr;
    wire [ 3: 0] ibus_awlen;
    wire [ 2: 0] ibus_awsize;
    wire [ 1: 0] ibus_awburst;
    wire [ 1: 0] ibus_awlock;
    wire [ 3: 0] ibus_awcache;
    wire [ 2: 0] ibus_awprot;
    wire         ibus_awvalid;
    wire         ibus_awready;
    wire [ 3: 0] ibus_wid;
    wire [31: 0] ibus_wdata;
    wire [ 3: 0] ibus_wstrb;
    wire         ibus_wlast;
    wire         ibus_wvalid;
    wire         ibus_wready;
    wire [ 3: 0] ibus_bid;
    wire [ 1: 0] ibus_bresp;
    wire         ibus_bvalid;
    wire         ibus_bready;

    wire [ 3: 0] dbus_arid;
    wire [31: 0] dbus_araddr;
    wire [ 3: 0] dbus_arlen;
    wire [ 2: 0] dbus_arsize;
    wire [ 1: 0] dbus_arburst;
    wire [ 1: 0] dbus_arlock;
    wire [ 3: 0] dbus_arcache;
    wire [ 2: 0] dbus_arprot;
    wire         dbus_arvalid;
    wire         dbus_arready;
    wire [ 3: 0] dbus_rid;
    wire [31: 0] dbus_rdata;
    wire [ 1: 0] dbus_rresp;
    wire         dbus_rlast;
    wire         dbus_rvalid;
    wire         dbus_rready;
    wire [ 3: 0] dbus_awid;
    wire [31: 0] dbus_awaddr;
    wire [ 3: 0] dbus_awlen;
    wire [ 2: 0] dbus_awsize;
    wire [ 1: 0] dbus_awburst;
    wire [ 1: 0] dbus_awlock;
    wire [ 3: 0] dbus_awcache;
    wire [ 2: 0] dbus_awprot;
    wire         dbus_awvalid;
    wire         dbus_awready;
    wire [ 3: 0] dbus_wid;
    wire [31: 0] dbus_wdata;
    wire [ 3: 0] dbus_wstrb;
    wire         dbus_wlast;
    wire         dbus_wvalid;
    wire         dbus_wready;
    wire [ 3: 0] dbus_bid;
    wire [ 1: 0] dbus_bresp;
    wire         dbus_bvalid;
    wire         dbus_bready;

    cpu_top my_cpu_top (
        .clk            ( cpu_clk       ),
        .resetn         (  rstn         ),
        .int_           ( intr          ),
        
        .inst_en        ( inst_en       ),
        .inst_addr      ( inst_addr     ),
        .ibus_ready_1   ( inst_ready_1  ),
        .ibus_rdata_1   ( inst_rdata_1  ),
        .ibus_ready_2   ( inst_ready_2  ),
        .ibus_rdata_2   ( inst_rdata_2  ),
        .ibus_stall     ( inst_streq    ),
        .ibus_cached    ( inst_cached   ),
        
        .dbus_en        ( data_en       ),
        .dbus_wen       ( data_wen      ),
        .dbus_addr      ( data_addr     ),
        .dbus_wdata     ( data_wdata    ),
        .dbus_rdata     ( data_rdata    ),
        .dbus_size      ( data_size     ),
        .dbus_stall     ( data_streq    ),
        .dbus_cached    ( data_cached   ),
        .debug_pc_master(debug_pc_master),
        .debug_pc_slave(debug_pc_slave),
        .debug_wb_rf_wen_master(debug_wb_rf_wen_master),
        .debug_wb_rf_wnum_master(debug_wb_rf_wnum_master),
        .debug_wb_rf_wen_slave(debug_wb_rf_wen_slave),
        .debug_wb_rf_wnum_slave(debug_wb_rf_wnum_slave),
		.debug_wb_rf_wdata_master(debug_wb_rf_wdata_master),
        .debug_wb_rf_wdata_slave(debug_wb_rf_wdata_slave)
        //.cacheop        ( cacheop       ),
        //.cop_tag        ( cop_tag       )
    );

    ICache icache_ctrl (
        .clk       ( cpu_clk       ),
        .resetn_p    ( rstn          ),
        .arid       ( ibus_arid     ),
        .araddr     ( ibus_araddr   ),
        .arlen      ( ibus_arlen    ),
        .arsize     ( ibus_arsize   ),
        .arburst    ( ibus_arburst  ),
        .arlock     ( ibus_arlock   ),
        .arcache    ( ibus_arcache  ),
        .arprot     ( ibus_arprot   ),
        .arvalid    ( ibus_arvalid  ),
        .arready    ( ibus_arready  ),
        .rid        ( ibus_rid      ),
        .rdata      ( ibus_rdata    ),
        .rresp      ( ibus_rresp    ),
        .rlast      ( ibus_rlast    ),
        .rvalid     ( ibus_rvalid   ),
        .rready     ( ibus_rready   ),
        .awid       ( ibus_awid     ),
        .awaddr     ( ibus_awaddr   ),
        .awlen      ( ibus_awlen    ),
        .awsize     ( ibus_awsize   ),
        .awburst    ( ibus_awburst  ),
        .awlock     ( ibus_awlock   ),
        .awcache    ( ibus_awcache  ),
        .awprot     ( ibus_awprot   ),
        .awvalid    ( ibus_awvalid  ),
        .awready    ( ibus_awready  ),
        .wid        ( ibus_wid      ),
        .wdata      ( ibus_wdata    ),
        .wstrb      ( ibus_wstrb    ),
        .wlast      ( ibus_wlast    ),
        .wvalid     ( ibus_wvalid   ),
        .wready     ( ibus_wready   ),
        .bid        ( ibus_bid      ),
        .bresp      ( ibus_bresp    ),
        .bvalid     ( ibus_bvalid   ),
        .bready     ( ibus_bready   ),
        
        .i_en       ( inst_en       ),
        .i_addr     ( inst_addr     ),
        .i_ready_1  ( inst_ready_1  ),
        .i_rdata_1  ( inst_rdata_1  ),
        .i_ready_2  ( inst_ready_2  ),
        .i_rdata_2  ( inst_rdata_2  ),
        .i_stall    ( inst_streq    ),
        .cached     ( inst_cached   ),

        .c_op    ( 5'b11111       )
        //.cop_en     ( data_en       ),
        //.cop_addr   ( data_addr     ),
        ///.cop_itag   ( cop_tag       )
    );

    DCache dcache_ctrl (
        .clk       ( cpu_clk       ),
        .resetn_p    ( rstn          ),
        .arid       ( dbus_arid     ),
        .araddr     ( dbus_araddr   ),
        .arlen      ( dbus_arlen    ),
        .arsize     ( dbus_arsize   ),
        .arburst    ( dbus_arburst  ),
        .arlock     ( dbus_arlock   ),
        .arcache    ( dbus_arcache  ),
        .arprot     ( dbus_arprot   ),
        .arvalid    ( dbus_arvalid  ),
        .arready    ( dbus_arready  ),
        .rid        ( dbus_rid      ),
        .rdata      ( dbus_rdata    ),
        .rresp      ( dbus_rresp    ),
        .rlast      ( dbus_rlast    ),
        .rvalid     ( dbus_rvalid   ),
        .rready     ( dbus_rready   ),
        .awid       ( dbus_awid     ),
        .awaddr     ( dbus_awaddr   ),
        .awlen      ( dbus_awlen    ),
        .awsize     ( dbus_awsize   ),
        .awburst    ( dbus_awburst  ),
        .awlock     ( dbus_awlock   ),
        .awcache    ( dbus_awcache  ),
        .awprot     ( dbus_awprot   ),
        .awvalid    ( dbus_awvalid  ),
        .awready    ( dbus_awready  ),
        .wid        ( dbus_wid      ),
        .wdata      ( dbus_wdata    ),
        .wstrb      ( dbus_wstrb    ),
        .wlast      ( dbus_wlast    ),
        .wvalid     ( dbus_wvalid   ),
        .wready     ( dbus_wready   ),
        .bid        ( dbus_bid      ),
        .bresp      ( dbus_bresp    ),
        .bvalid     ( dbus_bvalid   ),
        .bready     ( dbus_bready   ),
        
        .d_en     ( data_en       ),
        .w_b_s    ( data_wen      ),
        .d_addr   ( data_addr     ),
        .d_rdata  ( data_rdata    ),
        .d_wdata  ( data_wdata    ),
        .d_size   ( data_size     ),
        .d_stall  ( data_streq    ),
        //.d_stall  ( data_stall    ),
        .cached ( data_cached   ),
        
        .c_op    ( 5'b11111       )
        //.cop_dtag   ( cop_tag       )
    );

    Bus_Interface biu (
        .aclk             ( cpu_clk     ),
        .aresetn          ( rstn        ),
        
        .s_axi_arid       ( {ibus_arid   ,dbus_arid   } ),
        .s_axi_araddr     ( {ibus_araddr ,dbus_araddr } ),
        .s_axi_arlen      ( {ibus_arlen  ,dbus_arlen  } ),
        .s_axi_arsize     ( {ibus_arsize ,dbus_arsize } ),
        .s_axi_arburst    ( {ibus_arburst,dbus_arburst} ),
        .s_axi_arlock     ( {ibus_arlock ,dbus_arlock } ),
        .s_axi_arcache    ( {ibus_arcache,dbus_arcache} ),
        .s_axi_arprot     ( {ibus_arprot ,dbus_arprot } ),
        .s_axi_arqos      ( 0                           ),
        .s_axi_arvalid    ( {ibus_arvalid,dbus_arvalid} ),
        .s_axi_arready    ( {ibus_arready,dbus_arready} ),
        .s_axi_rid        ( {ibus_rid    ,dbus_rid    } ),
        .s_axi_rdata      ( {ibus_rdata  ,dbus_rdata  } ),
        .s_axi_rresp      ( {ibus_rresp  ,dbus_rresp  } ),
        .s_axi_rlast      ( {ibus_rlast  ,dbus_rlast  } ),
        .s_axi_rvalid     ( {ibus_rvalid ,dbus_rvalid } ),
        .s_axi_rready     ( {ibus_rready ,dbus_rready } ),
        .s_axi_awid       ( {ibus_awid   ,dbus_awid   } ),
        .s_axi_awaddr     ( {ibus_awaddr ,dbus_awaddr } ),
        .s_axi_awlen      ( {ibus_awlen  ,dbus_awlen  } ),
        .s_axi_awsize     ( {ibus_awsize ,dbus_awsize } ),
        .s_axi_awburst    ( {ibus_awburst,dbus_awburst} ),
        .s_axi_awlock     ( {ibus_awlock ,dbus_awlock } ),
        .s_axi_awcache    ( {ibus_awcache,dbus_awcache} ),
        .s_axi_awprot     ( {ibus_awprot ,dbus_awprot } ),
        .s_axi_awqos      ( 0                           ),
        .s_axi_awvalid    ( {ibus_awvalid,dbus_awvalid} ),
        .s_axi_awready    ( {ibus_awready,dbus_awready} ),
        .s_axi_wid        ( {ibus_wid    ,dbus_wid    } ),
        .s_axi_wdata      ( {ibus_wdata  ,dbus_wdata  } ),
        .s_axi_wstrb      ( {ibus_wstrb  ,dbus_wstrb  } ),
        .s_axi_wlast      ( {ibus_wlast  ,dbus_wlast  } ),
        .s_axi_wvalid     ( {ibus_wvalid ,dbus_wvalid } ),
        .s_axi_wready     ( {ibus_wready ,dbus_wready } ),
        .s_axi_bid        ( {ibus_bid    ,dbus_bid    } ),
        .s_axi_bresp      ( {ibus_bresp  ,dbus_bresp  } ),
        .s_axi_bvalid     ( {ibus_bvalid ,dbus_bvalid } ),
        .s_axi_bready     ( {ibus_bready ,dbus_bready } ),
        
        .m_axi_arid       ( m_axi_arid          ),
        .m_axi_araddr     ( m_axi_araddr        ),
        .m_axi_arlen      ( m_axi_arlen[3:0]    ),
        .m_axi_arsize     ( m_axi_arsize        ),
        .m_axi_arburst    ( m_axi_arburst       ),
        .m_axi_arlock     ( m_axi_arlock        ),
        .m_axi_arcache    ( m_axi_arcache       ),
        .m_axi_arprot     ( m_axi_arprot        ),
        .m_axi_arqos      (                     ),
        .m_axi_arvalid    ( m_axi_arvalid       ),
        .m_axi_arready    ( m_axi_arready       ),
        .m_axi_rid        ( m_axi_rid           ),
        .m_axi_rdata      ( m_axi_rdata         ),
        .m_axi_rresp      ( m_axi_rresp         ),
        .m_axi_rlast      ( m_axi_rlast         ),
        .m_axi_rvalid     ( m_axi_rvalid        ),
        .m_axi_rready     ( m_axi_rready        ),
        .m_axi_awid       ( m_axi_awid          ),
        .m_axi_awaddr     ( m_axi_awaddr        ),
        .m_axi_awlen      ( m_axi_awlen[3:0]    ),
        .m_axi_awsize     ( m_axi_awsize        ),
        .m_axi_awburst    ( m_axi_awburst       ),
        .m_axi_awlock     ( m_axi_awlock        ),
        .m_axi_awcache    ( m_axi_awcache       ),
        .m_axi_awprot     ( m_axi_awprot        ),
        .m_axi_awqos      (                     ),
        .m_axi_awvalid    ( m_axi_awvalid       ),
        .m_axi_awready    ( m_axi_awready       ),
        .m_axi_wid        ( m_axi_wid           ),
        .m_axi_wdata      ( m_axi_wdata         ),
        .m_axi_wstrb      ( m_axi_wstrb         ),
        .m_axi_wlast      ( m_axi_wlast         ),
        .m_axi_wvalid     ( m_axi_wvalid        ),
        .m_axi_wready     ( m_axi_wready        ),
        .m_axi_bid        ( m_axi_bid           ),
        .m_axi_bresp      ( m_axi_bresp         ),
        .m_axi_bvalid     ( m_axi_bvalid        ),
        .m_axi_bready     ( m_axi_bready        )
    );

endmodule