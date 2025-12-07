class apb_slave_sequence extends uvm_sequence #(apb_slave_sequence_item);
  `uvm_object_utils(apb_slave_sequence)

  function new(string name="apb_slave_sequence");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      `uvm_do(req)
    end
  endtask
endclass
class apb_reset_sequence extends uvm_sequence #(apb_slave_sequence_item);
  `uvm_object_utils(apb_reset_sequence)

  function new(string name="apb_reset_sequence");
    super.new(name);
  endfunction

  virtual task body();

    // === During Reset ===
    `uvm_do_with(req, {
      req.PRESETn == 0;
      req.PWRITE  == 0;
      req.PSEL    == 0;
      req.PENABLE == 0;
      req.PADDR   == 0;
      req.PWDATA  == 0;
      req.PSTRB   == 0;
    })

    // === After Reset ===
    `uvm_do_with(req, {
      req.PRESETn == 1;
      req.PWRITE  inside {0,1};
      req.PADDR   inside {[0:`MEM_DEPTH-1]};
      req.PWDATA  inside {[32'h0 : 32'hFFFF_FFFF]};
      req.PSTRB   == 4'b1111;
    })
    `uvm_info(get_type_name(), "APB Reset Sequence Completed", UVM_LOW)
  endtask
endclass


class normal_write_read_seq extends uvm_sequence #(apb_slave_sequence_item);
  `uvm_object_utils(normal_write_read_seq)

  function new(string name="normal_write_read_seq");
    super.new(name);
  endfunction

  virtual task body();
    bit [`ADDR_WIDTH-1:0] addr;
    bit [`DATA_WIDTH-1:0] data;

    repeat(10) begin

      // WRITE
      `uvm_do_with(req, {
        req.PRESETn == 1;
        req.PWRITE  == 1;
        req.PADDR   inside {[0:`MEM_DEPTH-1]};
        req.PWDATA  inside {[32'h0 : 32'hFFFF_FFFF]};
        req.PSTRB   == 4'b1111;
      })
      addr = req.PADDR;
      data = req.PWDATA;

      // READ BACK
      `uvm_do_with(req, {
        req.PRESETn == 1;
        req.PWRITE  == 0;
        req.PADDR   == addr;
        req.PWDATA == data;
      })
    end
  endtask
endclass
class byte_strobe_seq extends uvm_sequence #(apb_slave_sequence_item);
  `uvm_object_utils(byte_strobe_seq)

  function new(string name="byte_strobe_seq");
    super.new(name);
  endfunction

  virtual task body();
    bit [`ADDR_WIDTH-1:0] addr;

    repeat(10) begin

      // PARTIAL WRITE
      `uvm_do_with(req, {
        req.PRESETn == 1;
        req.PWRITE  == 1;
        req.PADDR   inside {[0:`MEM_DEPTH-1]};
        req.PWDATA  inside {[32'h0 : 32'hFFFF_FFFF]};
        req.PSTRB inside {
          4'b0001, 4'b0010, 4'b0100, 4'b1000,
          4'b0011, 4'b1100
        };
      })
      addr = req.PADDR;

      // READ BACK
      `uvm_do_with(req, {
        req.PRESETn == 1;
        req.PWRITE  == 0;
        req.PADDR   == addr;
      })

    end
  endtask
endclass
// class error_seq extends uvm_sequence #(apb_slave_sequence_item);
//   `uvm_object_utils(error_seq)

//   function new(string name="error_seq");
//     super.new(name);
//   endfunction

//   virtual task body();

//     repeat(5) begin

//       // OUT OF RANGE WRITE
//       `uvm_do_with(req, {
//         req.PRESETn == 1;
//         req.PWRITE  == 1;
//         req.PADDR   inside {[`MEM_DEPTH : (1<<16)-1]};  // large OOR region
//         req.PWDATA  inside {[32'h0 : 32'hFFFF_FFFF]};
//         req.PSTRB   == 4'b1111;
//       })

//       // OUT OF RANGE READ
//       `uvm_do_with(req, {
//         req.PRESETn == 1;
//         req.PWRITE  == 0;
//         req.PADDR inside {[`MEM_DEPTH : (1<<16)-1]};
//       })

//     end
//   endtask
// endclass
class idle_seq extends uvm_sequence #(apb_slave_sequence_item);
  `uvm_object_utils(idle_seq)

  function new(string name="idle_seq");
    super.new(name);
  endfunction

  virtual task body();
    repeat(5) begin
      `uvm_do_with(req, {
        req.PRESETn == 1;
        req.PWRITE  inside {0,1};
        req.PADDR   inside {[0:`MEM_DEPTH-1]};
        req.PWDATA  inside {[32'h0 : 32'hFFFF_FFFF]};
        req.PSTRB   == 4'b1111;
        req.PSEL    == 0;
        req.PENABLE == 0;
      })
    end
  endtask
endclass
class sequential_scan_seq extends uvm_sequence #(apb_slave_sequence_item);
  `uvm_object_utils(sequential_scan_seq)

  function new(string name="sequential_scan_seq");
    super.new(name);
  endfunction

  virtual task body();
    for (int i = 0; i < `MEM_DEPTH; i++) begin

      // WRITE
      `uvm_do_with(req, {
        req.PRESETn == 1;
        req.PWRITE  == 1;
        req.PADDR   == i;
        req.PWDATA  inside {[32'h0 : 32'hFFFF_FFFF]};
        req.PSTRB   == 4'b1111;
      })

      // READ
      `uvm_do_with(req, {
        req.PRESETn == 1;
        req.PWRITE  == 0;
        req.PADDR   == i;
      })

    end
  endtask
endclass
class apb_slave_regression_seq extends uvm_sequence #(apb_slave_sequence_item);
  `uvm_object_utils(apb_slave_regression_seq)

  apb_reset_sequence        reset_seq;
  normal_write_read_seq     normal_seq;
  byte_strobe_seq           byte_seq;
 // error_seq                 err_seq;
  idle_seq                  idle_seq1;
  sequential_scan_seq       scan_seq;

  function new(string name="apb_slave_regression_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("REGSEQ","Starting Full Regression",UVM_LOW)

    `uvm_do(reset_seq)
    `uvm_do(normal_seq)
    `uvm_do(byte_seq)
    //`uvm_do(err_seq)
    `uvm_do(idle_seq1)
    `uvm_do(scan_seq)

  endtask
endclass

