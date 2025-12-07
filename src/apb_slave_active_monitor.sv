class apb_slave_active_monitor extends uvm_monitor;
  `uvm_component_utils(apb_slave_active_monitor)

  virtual apb_slave_interface vif;
  uvm_analysis_port #(apb_slave_sequence_item) ap_active;

  function new(string name="apb_slave_active_monitor", uvm_component parent=null);
    super.new(name,parent);
    ap_active = new("ap_active", this);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual apb_slave_interface)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Active monitor: vif not found");
  endfunction

  task run_phase(uvm_phase phase);
    forever monitor_transfer();
  endtask

  task automatic monitor_transfer();
    apb_slave_sequence_item req;
    req = apb_slave_sequence_item::type_id::create("req");

    // Wait SETUP
    do @(vif.mon_cb);
    while(!(vif.mon_cb.PSEL && !vif.mon_cb.PENABLE));

    req.PRESETn = vif.mon_cb.PRESETn;
    req.PWRITE  = vif.mon_cb.PWRITE;
    req.PADDR   = vif.mon_cb.PADDR;
    req.PSTRB   = vif.mon_cb.PSTRB;
    req.PWDATA  = (vif.mon_cb.PWRITE) ? vif.mon_cb.PWDATA : '0;

    // Wait ACCESS
    do @(vif.mon_cb);
    while(!(vif.mon_cb.PSEL && vif.mon_cb.PENABLE));

    // Wait PREADY (but DO NOT read PRDATA/PSLVERR here)
    do @(vif.mon_cb);
    while (vif.mon_cb.PREADY == 0);
	`uvm_info("ACT_MON_SETUP", $sformatf(
      "SETUP : ADDR=0x%0h WRITE=%0b STRB=0x%0h WDATA=0x%0h",
        req.PADDR, req.PWRITE, req.PSTRB, req.PWDATA), UVM_LOW)


    // SEND REQUEST ONLY
    ap_active.write(req);

    @(vif.mon_cb);

  endtask

endclass

