class apb_slave_passive_agent extends uvm_agent;
  `uvm_component_utils(apb_slave_passive_agent)

  apb_slave_passive_monitor mon_passive;

  function new(string name = "apb_slave_passive_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (get_is_active() == UVM_PASSIVE) begin
      mon_passive = apb_slave_passive_monitor::type_id::create("mon_passive", this);
    end
  endfunction
  
endclass

