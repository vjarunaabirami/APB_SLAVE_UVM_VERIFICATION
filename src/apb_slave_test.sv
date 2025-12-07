//------------------------------------------------------//
//                     Base Test                         //
//------------------------------------------------------//
class apb_slave_test extends uvm_test;
  `uvm_component_utils(apb_slave_test)

  apb_slave_environment env;

  function new(string name = "apb_slave_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_slave_environment::type_id::create("env", this);
  endfunction

  function void end_of_elaboration();
    uvm_top.print_topology();
  endfunction
endclass


//------------------------------------------------------//
//                    Reset Test                         //
//------------------------------------------------------//
class apb_reset_test extends apb_slave_test;
  `uvm_component_utils(apb_reset_test)

  apb_reset_sequence seq;

  function new(string name = "apb_reset_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = apb_reset_sequence::type_id::create("reset_seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass


//------------------------------------------------------//
//              Normal Write/Read Test                  //
//------------------------------------------------------//
class normal_write_read_test extends apb_slave_test;
  `uvm_component_utils(normal_write_read_test)

  normal_write_read_seq seq;

  function new(string name = "normal_write_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = normal_write_read_seq::type_id::create("normal_seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass


//------------------------------------------------------//
//                  Byte-Strobe Test                     //
//------------------------------------------------------//
class byte_strobe_test extends apb_slave_test;
  `uvm_component_utils(byte_strobe_test)

  byte_strobe_seq seq;

  function new(string name = "byte_strobe_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = byte_strobe_seq::type_id::create("byte_seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass


//------------------------------------------------------//
//                  Error / Out-of-Range Test           //
//------------------------------------------------------//
// class error_test extends apb_slave_test;
//   `uvm_component_utils(error_test)

//   error_seq seq;

//   function new(string name = "error_test", uvm_component parent = null);
//     super.new(name, parent);
//   endfunction

//   function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     seq = error_seq::type_id::create("error_seq");
//   endfunction

//   task run_phase(uvm_phase phase);
//     phase.raise_objection(this);
//     seq.start(env.act_agent.seqr);
//     phase.drop_objection(this);
//   endtask
// endclass


//------------------------------------------------------//
//                  Idle / No-Transfer Test             //
//------------------------------------------------------//
class idle_test extends apb_slave_test;
  `uvm_component_utils(idle_test)

  idle_seq seq;

  function new(string name = "idle_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = idle_seq::type_id::create("idle_seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass


//------------------------------------------------------//
//                  Sequential Scan Test                //
//------------------------------------------------------//
class sequential_scan_test extends apb_slave_test;
  `uvm_component_utils(sequential_scan_test)

  sequential_scan_seq seq;

  function new(string name = "sequential_scan_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seq = sequential_scan_seq::type_id::create("scan_seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass


//------------------------------------------------------//
//               Full Regression Test                   //
//------------------------------------------------------//
class apb_slave_regression_test extends apb_slave_test;
  `uvm_component_utils(apb_slave_regression_test)

  apb_slave_regression_seq reg_seq;

  function new(string name = "apb_slave_regression_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    reg_seq = apb_slave_regression_seq::type_id::create("reg_seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    reg_seq.start(env.act_agent.seqr);
   phase.drop_objection(this);
  endtask
endclass

