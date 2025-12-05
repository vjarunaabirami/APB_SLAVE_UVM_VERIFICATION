class apb_slave_driver extends uvm_driver #(apb_slave_sequence_item);
  `uvm_component_utils(apb_slave_driver)

  virtual apb_slave_interface vif;

  function new(string name="apb_slave_driver", uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual apb_slave_interface)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Driver: vif not found");
  endfunction

  task run_phase(uvm_phase phase);
    apb_slave_sequence_item req;
    forever begin
      seq_item_port.get_next_item(req);
      drive(req);
      seq_item_port.item_done();
    end
  endtask

  task drive(apb_slave_sequence_item req);

    @(vif.drv_cb);

    // SETUP phase
    vif.PWRITE  <= req.PWRITE;
    vif.PADDR   <= req.PADDR;
    vif.PWDATA  <= req.PWDATA;
    vif.PSTRB   <= req.PSTRB;
    vif.PSEL    <= 1;
    vif.PENABLE <= 0;
`uvm_info("DRV_SETUP", $sformatf(
      "SETUP :ADDR=0x%0h WRITE=%0b WDATA=0x%0h STRB=0x%0h",
        req.PADDR, req.PWRITE, req.PWDATA, req.PSTRB), UVM_LOW)

    @(vif.drv_cb);

    // ACCESS phase
    vif.drv_cb.PENABLE <= 1;
    `uvm_info("DRV_ACCESS", $sformatf(
      "ACCESS : ADDR=0x%0h WRITE=%0b",
        req.PADDR, req.PWRITE), UVM_LOW)
    // WAIT for PREADY — but DO NOT sample PRDATA/PSLVERR
    do @(vif.mon_cb);
    while (vif.mon_cb.PREADY == 0);

    // END TRANSFER
    @(vif.drv_cb) vif.drv_cb.PENABLE <= 0;
    @(vif.drv_cb) vif.drv_cb.PSEL    <= 0;

    // Clear signals
  //  @(vif.drv_cb);
//     vif.drv_cb.PWRITE <= 0;
//     vif.drv_cb.PADDR  <= '0;
//     vif.drv_cb.PWDATA <= '0;
//     vif.drv_cb.PSTRB  <= '0;

    @(vif.drv_cb);

  endtask

endclass

