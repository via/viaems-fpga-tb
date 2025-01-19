module uart_rx_tb();
  reg clk;
  reg rst;

  wire [7:0] data;
  wire data_ready;

  reg rxd;

  
  initial begin
    $dumpvars;
    clk = 0;
    rst = 1;
    rxd = 1;
    forever #5 clk = ~clk;
  end

  uart_rx rx(.clk(clk), .rst(rst), .rx(rxd), .read_data(data),
             .read_ready(data_ready));


  initial begin
    #50 rst = 0;
    rxd = 0;        // start
    #1040 rxd = 0;  // D0
    #1040 rxd = 1;  // D1
    #1040 rxd = 0;  // D2
    #1040 rxd = 1;  // D3
    #1040 rxd = 1;  // D4
    #1040 rxd = 0;  // D5
    #1040 rxd = 1;  // D6
    #1040 rxd = 0;  // D7
    #1040 rxd = 1;  // Stop

    #1040 rxd = 0;  // Start
    #1040 rxd = 1;  // D0
    #1040 rxd = 0;  // D1
    #1040 rxd = 1;  // D2
    #1040 rxd = 1;  // D3
    #1040 rxd = 1;  // D4
    #1040 rxd = 1;  // D5
    #1040 rxd = 0;  // D6
    #1040 rxd = 0;  // D7
    #1040 rxd = 1;  // Stop
    #1040 rxd = 1;  // Idle
    #1040 rxd = 1;  // Idle
    $finish;
  end

endmodule

