`uvm_analysis_imp_decl(_act_mon)
`uvm_analysis_imp_decl(_pass_mon)

class apb_slave_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(apb_slave_scoreboard)

  // Internal reference memory
  logic [31:0] mem [0:255];

  int PASS = 0;
  int FAIL = 0;

  apb_slave_sequence_item inp_q[$];
  apb_slave_sequence_item out_q[$];

  uvm_analysis_imp_act_mon #(apb_slave_sequence_item, apb_slave_scoreboard) active_mon_port;
  uvm_analysis_imp_pass_mon #(apb_slave_sequence_item, apb_slave_scoreboard) passive_mon_port;

  apb_slave_sequence_item inp_item, out_item;

  // Constructor
  function new(string name="apb_slave_scoreboard", uvm_component parent=null);
    super.new(name,parent);

    active_mon_port  = new("active_mon_port", this);
    passive_mon_port = new("passive_mon_port", this);

    // Initialize memory
    foreach(mem[i])
      mem[i] = 32'h0;
  endfunction

  // Receive request (from active monitor)
  function void write_act_mon(apb_slave_sequence_item t);
    inp_q.push_back(t);
  endfunction

  // Receive response (from passive monitor)
  function void write_pass_mon(apb_slave_sequence_item t);
    out_q.push_back(t);
  endfunction


  // ================================================================
  //                         COMPARE LOGIC
  // ================================================================
  task compare(apb_slave_sequence_item in_item, apb_slave_sequence_item out_item);

    int i;
    logic [31:0] expected_data;
    logic [31:0] new_word;


    // ----------------------------------------------------------
    // RESET CASE
    // ----------------------------------------------------------
    if (!out_item.PRESETn) begin
      expected_data = 32'h0;

      if (out_item.PRDATA === expected_data && !out_item.PSLVERR) begin
        PASS++;
        `uvm_info("SCBD",
          $sformatf("RESET PASS: RESET=%0b ACT_RDATA=0x%0h EXP_RDATA=0x%0h PSLVERR=%0b", out_item.PRESETn, out_item.PRDATA, expected_data, out_item.PSLVERR),
          UVM_LOW)
      end
      else begin
        FAIL++;
        `uvm_error("SCBD",
          $sformatf("RESET FAIL: ACT_RDATA=0x%0h EXP_RDATA=0x%0h PSLVERR=%0b",
                    out_item.PRDATA, expected_data, out_item.PSLVERR))
      end
      return;
    end


    // ----------------------------------------------------------
    // WRITE CASE
    // ----------------------------------------------------------
    if (in_item.PWRITE) begin

      // OOR write
      if (in_item.PADDR >= 256) begin
        if (out_item.PSLVERR) begin
          PASS++;
          `uvm_info("SCBD",
            $sformatf("WRITE PASS: ADDR=0x%0h PSLVERR=%0b",
                      in_item.PADDR, out_item.PSLVERR),
            UVM_LOW)
        end
        else begin
          FAIL++;
          `uvm_error("SCBD",
            $sformatf("WRITE FAIL: ADDR=0x%0h PSLVERR=%0b",
                      in_item.PADDR, out_item.PSLVERR))
        end
      end

      // Valid write
      else begin
        new_word = mem[in_item.PADDR];

        for (i = 0; i < 4; i++)
          if (in_item.PSTRB[i])
            new_word[i*8 +: 8] = in_item.PWDATA[i*8 +: 8];

        mem[in_item.PADDR] = new_word;

        `uvm_info("SCBD",
          $sformatf("WRITE OK: ADDR=0x%0h WDATA=0x%0h STRB=0x%0h NEW_MEM=0x%0h",
                    in_item.PADDR, in_item.PWDATA, in_item.PSTRB, new_word),
          UVM_LOW)
      end
    end


    // ----------------------------------------------------------
    // READ CASE
    // ----------------------------------------------------------
    else begin

      // OOR read
      if (in_item.PADDR >= 256) begin
        if (out_item.PSLVERR && out_item.PRDATA === 32'hFFFF_FFFF) begin
          PASS++;
          `uvm_info("SCBD",
            $sformatf("READ PASS (OOR): ACT_RDATA=0x%0h EXP=0xFFFF_FFFF PSLVERR=%0b",
                      out_item.PRDATA, out_item.PSLVERR),
            UVM_LOW)
        end
        else begin
          FAIL++;
          `uvm_error("SCBD",
            $sformatf("READ FAIL (OOR): ACT_RDATA=0x%0h EXP=0xFFFF_FFFF PSLVERR=%0b",
                      out_item.PRDATA, out_item.PSLVERR))
        end
      end

      // Normal read
      else begin
        expected_data = mem[in_item.PADDR];

        if (out_item.PRDATA === expected_data && !out_item.PSLVERR) begin
          PASS++;
          `uvm_info("SCBD",
            $sformatf("READ PASS: ADDR=0x%0h ACT=0x%0h EXP=0x%0h",
                      in_item.PADDR, out_item.PRDATA, expected_data),
            UVM_LOW)
        end
        else begin
          FAIL++;
          `uvm_error("SCBD",
            $sformatf("READ FAIL: ADDR=0x%0h ACT=0x%0h EXP=0x%0h PSLVERR=%0b",
                      in_item.PADDR, out_item.PRDATA, expected_data, out_item.PSLVERR))
        end
      end
    end

  endtask


 // ================================================================
  //                     MATCH QUEUE PAIRS
  // ================================================================
  task run_phase(uvm_phase phase);
    forever begin
      wait(inp_q.size() > 0 && out_q.size() > 0);

      inp_item = inp_q.pop_front();
      out_item = out_q.pop_front();

      compare(inp_item, out_item);
    end
  endtask


  // ================================================================
  //                          REPORT
  // ================================================================
  function void report_phase(uvm_phase phase);
    `uvm_info("SCBD",
      $sformatf("RESULTS : PASS=%0d   FAIL=%0d", PASS, FAIL),
      UVM_NONE)
  endfunction

endclass

