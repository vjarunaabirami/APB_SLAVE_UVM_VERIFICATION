
class apb_slave_active_agent extends uvm_agent;
  `uvm_component_utils(apb_slave_active_agent)

  apb_slave_driver        drv;
  apb_slave_sequencer     seqr;
  apb_slave_active_monitor mon_active;

  function new(string name = "apb_active_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (get_is_active() == UVM_ACTIVE) begin
      seqr = apb_slave_sequencer::type_id::create("seqr", this);
      drv  = apb_slave_driver::type_id::create("drv", this);
    end
    
    mon_active = apb_slave_active_monitor::type_id::create("mon_active", this);
  endfunction

  // Connect phase
  function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end
  endfunction

endclass

