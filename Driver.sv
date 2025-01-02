class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver);
  virtual inf in;
  transaction trans;
  function new(string path="drv",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    
    if(!uvm_config_db #(virtual inf)::get(this,"","in",in))
      `uvm_info("CHKDRV","Error in config of drv",UVM_NONE);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    trans=transaction::type_id::create("trans",this);
    forever
      begin
        seq_item_port.get_next_item(trans);
        in.din<=trans.din;
        in.rst<=trans.rst;
        `uvm_info("DRV",$sformatf("Data recieved of rst: %0d, din:%0d",trans.rst,trans.din),UVM_NONE);
        seq_item_port.item_done(trans);
        repeat(2) @(posedge in.clk);
      end
  endtask
endclass
