`include "uvm_macros.svh";
import uvm_pkg::*;




class config_dff extends uvm_object;
  `uvm_object_utils(config_dff);
  
  uvm_active_passive_enum agent_type=UVM_ACTIVE;
  
  function new(string path="config_dff");
    super.new(path);
  endfunction
endclass
               

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction);
  rand bit din;
  rand bit rst;
  bit dout;
  
  function new(string path="trans");
    super.new(path);
  endfunction
endclass


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

class env extends uvm_env;
  `uvm_component_utils(env);
  agent a;
  scoreboard scb;
  function new(string path="env",uvm_component parent=null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a=agent::type_id::create("a",this);
    scb=scoreboard::type_id::create("scb",this);
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    a.mon.send.connect(scb.recv);
  endfunction
endclass

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

module tb;
  inf in();
  dff dut(.din(in.din),.dout(in.dout),.rst(in.rst),.clk(in.clk));
  
  initial
    begin
      in.clk=0;
    end
  always
    #10 in.clk=~in.clk;
  initial
    begin
      uvm_config_db #(virtual inf)::set(null,"*","in",in);
      run_test("test");
    end
endmodule
