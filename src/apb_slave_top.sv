`include "defines.sv"
`include "design.sv"
`include "apb_slave_interface.sv"
`include "apb_slave_package.sv"
`include "apb_slave_assertions.sv"

import uvm_pkg::*;
import apb_slave_package::*;

module apb_slave_top;

  bit PCLK = 0;
  bit PRESETn;

  // Clock generation
  always #5 PCLK = ~PCLK;

  // RESET GENERATION
  initial begin
    PRESETn = 1'b0;                // assert reset
    repeat (5) @(posedge PCLK);    // hold reset for some cycles
    PRESETn = 1'b1;                // deassert
  end

  // CORRECT INTERFACE INSTANTIATION (PASS PRESETn ALSO)
  apb_slave_interface vif(PCLK, PRESETn);

  // DUT CONNECTION
  apb_slave DUT (
    .PCLK(vif.PCLK),
    .PRESETn(vif.PRESETn),
    .PADDR(vif.PADDR),
    .PWRITE(vif.PWRITE),
    .PWDATA(vif.PWDATA),
    .PRDATA(vif.PRDATA),
    .PSEL(vif.PSEL),
    .PENABLE(vif.PENABLE),
    .PSTRB(vif.PSTRB),
    .PSLVERR(vif.PSLVERR),
    .PREADY (vif.PREADY)
  );

  // Assertions
  bind vif apb_slave_assertions ASSERT (
    .PCLK(vif.PCLK),
    .PRESETn(vif.PRESETn),
    .PADDR(vif.PADDR),
    .PWRITE(vif.PWRITE),
    .PWDATA(vif.PWDATA),
    .PRDATA(vif.PRDATA),
    .PSEL(vif.PSEL),
    .PENABLE(vif.PENABLE),
    .PSTRB(vif.PSTRB),
    .PSLVERR(vif.PSLVERR),
    .PREADY (vif.PREADY)
  );

  // ------------------------------------------------------
  // CONFIGURATION DB
  // ------------------------------------------------------
  initial begin
    uvm_config_db#(virtual apb_slave_interface)::set(null, "*", "vif", vif);
    $dumpfile("apb_slave_dump.vcd");
    $dumpvars;
  end

  initial begin
   run_test("apb_slave_regression_test");
      //   run_test("apb_slave_test");
      //    run_test("apb_reset_test");
      //   run_test("byte_strobe_test");
 // run_test("error_test");
     //   run_test("idle_test");
   // run_test("normal_write_read_test");
    #2000 $finish;
  end

endmodule

