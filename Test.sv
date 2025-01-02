class test extends uvm_test;
  `uvm_component_utils(test);
  env e;
  rand_din_rst seq;
  
  function new(string path="test",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e=env::type_id::create("e",this);
    seq=rand_din_rst::type_id::create("seq",this);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(e.a.seqr);
    #50;
    phase.drop_objection(this);
  endtask
endclass
