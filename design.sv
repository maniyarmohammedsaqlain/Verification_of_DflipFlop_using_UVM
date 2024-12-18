module dff(din,clk,rst,dout);
  input din,clk,rst;
  output reg dout;
  
  always@(posedge clk)
    begin
      if(rst)
        dout<=0;
      else
        dout<=din;
    end
endmodule

interface inf;
  logic clk;
  logic rst;
  logic din;
  logic dout;
endinterface
