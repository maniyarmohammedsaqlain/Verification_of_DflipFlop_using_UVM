class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction);
  rand bit din;
  rand bit rst;
  bit dout;
  
  function new(string path="trans");
    super.new(path);
  endfunction
endclass
