class apb_slave_environment extends uvm_env;
  `uvm_component_utils(apb_slave_environment)

  apb_slave_active_agent  act_agent;
  apb_slave_passive_agent  pass_agent;
  apb_slave_scoreboard  scb;
  apb_slave_subscriber  cov;

  function new(string name="apb_slave_environment", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    act_agent = apb_slave_active_agent ::type_id::create("act_agent", this);
    pass_agent = apb_slave_passive_agent::type_id::create("pass_agent", this);
    scb = apb_slave_scoreboard ::type_id::create("scb", this);
    cov = apb_slave_subscriber::type_id::create("cov", this);
    
    set_config_int("act_agent", "is_active", UVM_ACTIVE);
    set_config_int("pass_agent", "is_active", UVM_PASSIVE);
  endfunction

  function void connect_phase(uvm_phase phase);

    // Active monitor connections
    act_agent.mon_active.ap_active.connect(scb.active_mon_port);
    act_agent.mon_active.ap_active.connect(cov.active_port);

    // Passive monitor connections
    pass_agent.mon_passive.ap_passive.connect(scb.passive_mon_port);
    pass_agent.mon_passive.ap_passive.connect(cov.passive_port);

  endfunction

endclass
