class rand_din_rst extends uvm_sequence#(transaction);
  `uvm_object_utils(rand_din_rst);
  transaction trans;
  function new(string path="rand_din_rst");
    super.new(path);
  endfunction
  
  virtual task body();
    trans=transaction::type_id::create("trans");
    repeat(10)
      begin
        start_item(trans);
        trans.randomize();
        `uvm_info("randintrst",$sformatf("RST= %0d, DIN= %0d",trans.rst,trans.din),UVM_NONE);
        finish_item(trans);
      end
  endtask
endclass
