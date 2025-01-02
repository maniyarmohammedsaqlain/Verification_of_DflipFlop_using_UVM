class agent extends uvm_agent;
  `uvm_component_utils(agent);
  monitor mon;
  uvm_sequencer #(transaction)seqr;
  driver drv;
  config_dff cdf;
  
  
  function new(string path="a",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon=monitor::type_id::create("mon",this);
    cdf=config_dff::type_id::create("cdf",this);
    if(cdf.agent_type==UVM_ACTIVE)
      begin
        drv=driver::type_id::create("drv",this);
        seqr=uvm_sequencer#(transaction)::type_id::create("seqr",this);
      end
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass
