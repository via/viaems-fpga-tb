module uart_tx_tb();
  reg clk;
  reg rst;

  wire tx_out;
  wire tx_ready;
  reg tx_write;
  
  reg [7:0] value;
  initial begin
    $dumpvars;
    clk = 0;
    rst = 1;
    value = 0;
    forever #5 clk = ~clk;
  end

  uart_tx tx(.clk(clk), .rst(rst), .tx(tx_out), .data(value),
             .write(tx_write), .ready(tx_ready));

  initial begin
    #50 rst = 0;
    value = 8'hAE;
    #100 tx_write = 1;
    #10 tx_write = 0;
    #800 tx_write = 0;
    value = 8'h67;
    #10 tx_write = 1;
    #10 tx_write = 0;
    #800 tx_write = 0;
    $finish;
  end

endmodule

