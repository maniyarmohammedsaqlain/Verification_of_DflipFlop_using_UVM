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
