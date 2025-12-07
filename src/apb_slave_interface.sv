interface apb_slave_interface(input logic PCLK, input logic PRESETn);

    // -------------------------------------------------
    // APB signals
    // -------------------------------------------------
    logic        PSEL;
    logic        PENABLE;
    logic        PWRITE;
  logic [7:0]  PADDR;
    logic [31:0] PWDATA;
    logic [3:0]  PSTRB;

    logic [31:0] PRDATA;
    logic        PREADY;
    logic        PSLVERR;

    // -------------------------------------------------
    // Driver Clocking Block
    // -------------------------------------------------
    clocking drv_cb @(posedge PCLK);
        default output #1step;
        input PRDATA,PSLVERR,PREADY;
        output PSEL, PENABLE, PWRITE, PADDR, PWDATA, PSTRB;
    endclocking

    // -------------------------------------------------
    // Monitor Clocking Block
    // -------------------------------------------------
    clocking mon_cb @(posedge PCLK);
        default input #1step;
        
        // Add ALL signals monitors need to sample
        input PRESETn;   // <-- MUST BE ADDED
        input PSEL;
        input PENABLE;
        input PWRITE;
        input PADDR;
        input PWDATA;
        input PSTRB;
        input PRDATA;
        input PREADY;
        input PSLVERR;
    endclocking

endinterface

