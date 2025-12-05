`include "uvm_macros.svh"
`include "defines.sv"
import uvm_pkg::*;

class apb_slave_sequence_item extends uvm_sequence_item;
  
  rand bit                       PRESETn;   //reset
  rand bit [`ADDR_WIDTH-1:0]     PADDR;     // Address
  rand  bit                       PSEL;      // Select
  rand bit                       PENABLE;   // Enable
  rand bit                       PWRITE;    // 1=Write, 0=Read
  rand bit [`DATA_WIDTH-1:0]     PWDATA;    // Write data
  rand bit [`DATA_WIDTH/8-1:0]   PSTRB;     // Byte strobe


  logic [`DATA_WIDTH-1:0]          PRDATA;    // Read data
  logic                            PREADY;    // Slave ready
  logic                            PSLVERR;   // Slave error

  `uvm_object_utils_begin(apb_slave_sequence_item)
    `uvm_field_int(PRESETn,  UVM_ALL_ON)
    `uvm_field_int(PADDR,    UVM_ALL_ON)
    `uvm_field_int(PSEL,     UVM_ALL_ON)
    `uvm_field_int(PENABLE,  UVM_ALL_ON)
    `uvm_field_int(PWRITE,   UVM_ALL_ON)
    `uvm_field_int(PWDATA,   UVM_ALL_ON)
    `uvm_field_int(PSTRB,    UVM_ALL_ON)
    `uvm_field_int(PRDATA,   UVM_ALL_ON)
    `uvm_field_int(PREADY,   UVM_ALL_ON)
    `uvm_field_int(PSLVERR,  UVM_ALL_ON)
  `uvm_object_utils_end

  constraint addr_range { PADDR inside {[0:511]}; }
  
  function new(string name = "apb_slave_sequence_item");
    super.new(name);
  endfunction

endclass

