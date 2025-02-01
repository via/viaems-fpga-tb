module encoder_tb();
  reg clk;
  reg rst;

  reg wr;
  reg [23:0] data;
  reg [15:0] delay;
  wire ready;

  reg tx_ready;
  wire [7:0] tx_data;
  wire tx_write;

  initial begin
    $dumpvars;
    clk = 0;
    rst = 1;
    data = 0;
    delay = 0;
    tx_ready = 0;
    forever #5 clk = ~clk;
  end

  encoder dut(.clk(clk), .rst(rst), .capture_wr(wr),
    .capture_data(data), .capture_delay(delay),
    .capture_rdy(ready), .uart_tx_rdy(tx_ready),
    .uart_tx_data(tx_data), .uart_tx_wr(tx_write));


  initial begin
    #50 rst = 0;
    
    data = 24'h5e5e5;
    delay = 16'h7fff;
    tx_ready = 1;
    wr = 1;

    while (!tx_write) #10;
    tx_ready = 0;
    #50 tx_ready = 1;
    while (!tx_write) #10;
    tx_ready = 0;
    #50 tx_ready = 1;
    while (!tx_write) #10;
    tx_ready = 0;
    #50 tx_ready = 1;
    while (!tx_write) #10;
    tx_ready = 0;
    #50 tx_ready = 1;

#500


    $finish;
  end

endmodule

