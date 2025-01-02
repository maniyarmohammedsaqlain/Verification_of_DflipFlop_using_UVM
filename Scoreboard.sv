class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard);
  
  transaction tra;
  uvm_analysis_imp #(transaction,scoreboard)recv;
  function new(string path="scb",uvm_component parent=null);
    super.new(path,parent);
    
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tra=transaction::type_id::create("tra",this);
    recv=new("recv",this);
  endfunction
  
  virtual function void write(transaction trans);
    tra=trans;
    `uvm_info("scb",$sformatf("Data recieved of rst: %0d, din:%0d dout:%0d",trans.rst,trans.din,trans.dout),UVM_NONE);
    if(trans.rst==1)
      begin
        `uvm_info("scb","DUT RESET",UVM_NONE);
      end
    else if(trans.rst==0 && trans.din==trans.dout)
      begin
        `uvm_info("trans","PASSED",UVM_NONE);
      end
    else
      begin
        `uvm_info("trans","FAILED",UVM_NONE);
      end
  endfunction
endclass
