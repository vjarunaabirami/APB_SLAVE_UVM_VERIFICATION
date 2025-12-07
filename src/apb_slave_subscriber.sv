`uvm_analysis_imp_decl(_active)
`uvm_analysis_imp_decl(_passive)

class apb_slave_subscriber extends uvm_component;
  `uvm_component_utils(apb_slave_subscriber)

  // Analysis ports from monitors
  uvm_analysis_imp_active #(apb_slave_sequence_item, apb_slave_subscriber) active_port;
  uvm_analysis_imp_passive #(apb_slave_sequence_item, apb_slave_subscriber) passive_port;

  // Local copies of transactions
  apb_slave_sequence_item act_tx;
  apb_slave_sequence_item pas_tx;

  real active_cov, passive_cov;

  //---------------- ACTIVE COVERGROUP ----------------//
  covergroup active_mon_cov;

    cp_rw : coverpoint act_tx.PWRITE {
      bins read  = {0};
      bins write = {1};
    }

    cp_addr : coverpoint act_tx.PADDR {
      bins low  = {[0:63]};
      bins mid  = {[64:127]};
      bins high = {[128:191]};
      bins top  = {[192:255]};
    }

    cp_pstrb : coverpoint act_tx.PSTRB iff (act_tx.PWRITE == 1) {
      bins byte0 = {1};
      bins byte1 = {2};
      bins byte2 = {4};
      bins byte3 = {8};
      bins hw_low  = {3};
      bins hw_high = {12};
      bins full    = {15};
    }

    cp_wdata : coverpoint act_tx.PWDATA iff (act_tx.PWRITE == 1) {
      bins low  = {[32'h00000000 : 32'h3FFFFFFF]};
      bins mid  = {[32'h40000000 : 32'h7FFFFFFF]};
      bins high = {[32'h80000000 : 32'hFFFFFFFF]};
    }

    rw_x_addr : cross cp_rw, cp_addr;

  endgroup

  //---------------- PASSIVE COVERGROUP ----------------//
  covergroup passive_mon_cov;

    cp_rdata : coverpoint pas_tx.PRDATA {
      bins low  = {[32'h00000000 : 32'h3FFFFFFF]};
      bins med  = {[32'h40000000 : 32'h7FFFFFFF]};
      bins high = {[32'h80000000 : 32'hFFFFFFFF]};
    }

    cp_err : coverpoint pas_tx.PSLVERR {
      bins ok  = {0};
      bins err = {1};
    }

//     cp_ready : coverpoint pas_tx.PREADY {
//       bins ready = {1};
//      // bins ready0  = {0};
//     }

  endgroup

  //---------------- CONSTRUCTOR ----------------//
  function new(string name = "apb_slave_subscriber", uvm_component parent);
    super.new(name, parent);
    active_port      = new("active_port", this);
    passive_port     = new("passive_port", this);
    active_mon_cov   = new();
    passive_mon_cov  = new();
  endfunction

  //---------------- WRITE METHODS ----------------//
  function void write_active(apb_slave_sequence_item t);
    act_tx = t;
    active_mon_cov.sample();
  endfunction

  function void write_passive(apb_slave_sequence_item t);
    pas_tx = t;
    passive_mon_cov.sample();
  endfunction

  //---------------- EXTRACT PHASE ----------------//
  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    active_cov  = active_mon_cov.get_coverage();
    passive_cov = passive_mon_cov.get_coverage();
  endfunction

  //---------------- REPORT PHASE ----------------//
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(),
              $sformatf("[ACTIVE] Coverage = %0.2f%%", active_cov),
              UVM_MEDIUM)
    `uvm_info(get_type_name(),
              $sformatf("[PASSIVE] Coverage = %0.2f%%", passive_cov),
              UVM_MEDIUM)
  endfunction

endclass

