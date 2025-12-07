interface apb_slave_assertions (
    input  logic PCLK,
    input  logic PRESETn,
    input  logic PSEL,
    input  logic PENABLE,
    input  logic PWRITE,
  input  logic [`ADDR_WIDTH-1:0] PADDR,
  input  logic [`DATA_WIDTH-1:0] PWDATA,
  input  logic [`DATA_WIDTH/8-1:0] PSTRB,
  input  logic [`DATA_WIDTH-1:0] PRDATA,
    input  logic PREADY,
    input  logic PSLVERR
);
  
    //======================================================
    // 1. Reset Check: Memory and outputs are zeroed
    //======================================================
    property reset_check;
        @(posedge PCLK) disable iff(PRESETn)
        (PRDATA == 0 && PSLVERR == 0);
    endproperty

    assert_reset_check: assert property(reset_check)
      $info("Reset check passed - Assertion 1");
        else $error("Assertion 1 failed - PRDATA/PSLVERR not reset");
      
      //======================================================
      // 2. Transfer Address Range Check (without internal signal)
      //======================================================
      property addr_range_check;
        @(posedge PCLK) (PSEL && PENABLE) |-> (PADDR < `MEM_DEPTH);
      endproperty

      assert_addr_range: assert property(addr_range_check)
        $info("Address within range - Assertion 2");
        else $error("Assertion 2 failed - Address out of range");


        //======================================================
        // 3. Write Transfer Check with PSTRB 
        //======================================================
        property write_transfer_check;
          @(posedge PCLK) 
          (PSEL && PENABLE && PWRITE && (PADDR < `MEM_DEPTH)) |-> 
          ##1 ($stable(PWDATA) && $stable(PSTRB));
        endproperty

        assert_write_transfer: assert property(write_transfer_check)
          $info("Write transfer stable - Assertion 3");
          else $error("Assertion 3 failed - Write data or strobe changed during transfer");

        //======================================================
        // 4. Read Transfer Check: Data stable
        //======================================================
        property read_transfer_check_direct;
          @(posedge PCLK) (PSEL && PENABLE && !PWRITE && (PADDR < `MEM_DEPTH)) |-> ##1 $stable(PRDATA);
        endproperty

        assert_read_transfer_direct: assert property(read_transfer_check_direct)
          $info("Read data stable - Assertion 4");
            else $error("Assertion 4 failed - PRDATA unstable during read");

        //======================================================
        // 5. PSLVERR Assertion: Out-of-range access
        //======================================================
        property pslverr_check_direct;
          @(posedge PCLK) (PSEL && PENABLE && (PADDR >= `MEM_DEPTH)) |-> (PSLVERR == 1'b1);
        endproperty

        assert_pslverr_direct: assert property(pslverr_check_direct)
          $info("PSLVERR correct for invalid address - Assertion 5");
            else $error("Assertion 5 failed - PSLVERR not asserted for invalid address");
          
endinterface
