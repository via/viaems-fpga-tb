module uart_tx_tb();
  reg clk;
  reg rst;

  wire tx_out;
  wire tx_ready;
  reg tx_write;
  
  initial begin
    $dumpvars;
    clk = 0;
    rst = 1;
    forever #5 clk = ~clk;
  end

  uart_tx tx(.clk(clk), .rst(rst), .tx(tx_out), .data(8'hAE),
             .write(tx_write), .ready(tx_ready));


  initial begin
    #50 rst = 0;
    #100 tx_write = 1;
    #10 tx_write = 0;
    #20000 tx_write = 0;
    $finish;
  end

endmodule

