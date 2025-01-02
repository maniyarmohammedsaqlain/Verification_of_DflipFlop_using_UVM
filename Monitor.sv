class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);
  transaction trans;
  virtual inf in;
  uvm_analysis_port #(transaction)send;
  
  function new(string path="mon",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send=new("send",this);
    trans=transaction::type_id::create("trans",this);
    if(!uvm_config_db #(virtual inf)::get(this,"","in",in))
      `uvm_info("CHKMON","Error in config of mon",UVM_NONE);
    endfunction
  virtual task run_phase(uvm_phase phase);
    forever
      begin
        repeat(2) @(posedge in.clk);
        trans.din=in.din;
        trans.rst=in.rst;
        trans.dout=in.dout;
        `uvm_info("DRV",$sformatf("Data recieved of rst: %0d, din:%0d dout:%0d",trans.rst,trans.din,trans.dout),UVM_NONE);
        send.write(trans);
      end
  endtask
endclass
