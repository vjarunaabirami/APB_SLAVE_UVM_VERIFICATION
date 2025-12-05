class apb_slave_passive_monitor extends uvm_monitor;
  `uvm_component_utils(apb_slave_passive_monitor)

  virtual apb_slave_interface vif;
  uvm_analysis_port #(apb_slave_sequence_item) ap_passive;

  function new(string name="apb_slave_passive_monitor", uvm_component parent=null);
    super.new(name,parent);
    ap_passive = new("ap_passive", this);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual apb_slave_interface)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Passive monitor: vif not found");
  endfunction

  task run_phase(uvm_phase phase);
    forever monitor_transfer();
  endtask

  task automatic monitor_transfer();
    apb_slave_sequence_item rsp;
    rsp = apb_slave_sequence_item::type_id::create("rsp");

    // Wait SETUP
    do @(vif.mon_cb);
    while(!(vif.mon_cb.PSEL && !vif.mon_cb.PENABLE));

    rsp.PRESETn = vif.mon_cb.PRESETn;
    rsp.PWRITE  = vif.mon_cb.PWRITE;
    rsp.PADDR   = vif.mon_cb.PADDR;

    // WAIT ACCESS
    do @(vif.mon_cb);
    while(!(vif.mon_cb.PSEL && vif.mon_cb.PENABLE));

    // WAIT PREADY – capture DUT outputs
    do @(vif.mon_cb);
    while (vif.mon_cb.PREADY == 0);

    rsp.PRDATA  =  vif.mon_cb.PRDATA ;
    rsp.PSLVERR = vif.mon_cb.PSLVERR;

    ap_passive.write(rsp);

    @(vif.mon_cb);

  endtask

endclass

