module core_tb();
  reg clk;
  reg rst;
  reg rxd;
  wire txd;
  wire ctsn;
  wire [7:0] outputs;
  reg [21:0] inputs;

  reg sclk;
  reg mosi;
  reg cs;
  wire miso;

  
  initial begin
    $dumpvars;
    clk = 0;
    rst = 1;
    rxd = 1;
    inputs = 0;
    sclk = 0;
    mosi = 0;
    cs = 1;

    forever #5 clk = ~clk;
  end

  core dut(.clk(clk),
           .rst(rst),
           .uart_tx(txd),
           .uart_rx(rxd),
           .uart_ctsn(ctsn),
           .out(outputs),
           .inputs(inputs),
           .sclk(sclk),
           .miso(miso),
           .mosi(mosi),
           .cs(cs)
         );

  initial begin
    #500 inputs = 22'h2;
    #10 inputs = 22'h3;
    #500 inputs = 22'h0;
    #500 inputs = 22'h2;
    #500 inputs = 22'h0;
  end


  initial begin
    #50 rst = 0;
    rxd = 0;        // start          DELAY: 10
    #1040 rxd = 0;  // D0
    #1040 rxd = 0;  // D1
    #1040 rxd = 0;  // D2
    #1040 rxd = 0;  // D3
    #1040 rxd = 0;  // D4
    #1040 rxd = 0;  // D5
    #1040 rxd = 1;  // D6
    #1040 rxd = 1;  // D7
    #1040 rxd = 1;  // Stop

    #1040 rxd = 0;  // Start
    #1040 rxd = 0;  // D0
    #1040 rxd = 0;  // D1
    #1040 rxd = 0;  // D2
    #1040 rxd = 0;  // D3
    #1040 rxd = 0;  // D4
    #1040 rxd = 0;  // D5
    #1040 rxd = 0;  // D6
    #1040 rxd = 0;  // D7
    #1040 rxd = 1;  // Stop

    #1040 rxd = 0;  // Start
    #1040 rxd = 0;  // D0
    #1040 rxd = 0;  // D1
    #1040 rxd = 1;  // D2
    #1040 rxd = 0;  // D3
    #1040 rxd = 0;  // D4
    #1040 rxd = 0;  // D5
    #1040 rxd = 0;  // D6
    #1040 rxd = 0;  // D7
    #1040 rxd = 1;  // Stop

    #1040 rxd = 0;  // Start
    #1040 rxd = 0;  // D0
    #1040 rxd = 0;  // D1
    #1040 rxd = 0;  // D2
    #1040 rxd = 0;  // D3
    #1040 rxd = 0;  // D4
    #1040 rxd = 0;  // D5
    #1040 rxd = 0;  // D6
    #1040 rxd = 0;  // D7
    #1040 rxd = 1;  // Stop


    ////////////////////


    #1040 rxd = 0;  // Start
    #1040 rxd = 0;  // D0    OUTPUT: 3, delay: 0
    #1040 rxd = 0;  // D1
    #1040 rxd = 0;  // D2
    #1040 rxd = 0;  // D3
    #1040 rxd = 0;  // D4
    #1040 rxd = 0;  // D5
    #1040 rxd = 0;  // D6
    #1040 rxd = 1;  // D7
    #1040 rxd = 1;  // Stop

    #1040 rxd = 0;  // Start
    #1040 rxd = 0;  // D0
    #1040 rxd = 0;  // D1
    #1040 rxd = 0;  // D2
    #1040 rxd = 0;  // D3
    #1040 rxd = 0;  // D4
    #1040 rxd = 0;  // D5
    #1040 rxd = 0;  // D6
    #1040 rxd = 0;  // D7
    #1040 rxd = 1;  // Stop

    #1040 rxd = 0;  // Start
    #1040 rxd = 0;  // D0
    #1040 rxd = 0;  // D1
    #1040 rxd = 0;  // D2
    #1040 rxd = 0;  // D3
    #1040 rxd = 0;  // D4
    #1040 rxd = 0;  // D5
    #1040 rxd = 0;  // D6
    #1040 rxd = 0;  // D7
    #1040 rxd = 1;  // Stop

    #1040 rxd = 0;  // Start
    #1040 rxd = 1;  // D0
    #1040 rxd = 1;  // D1
    #1040 rxd = 1;  // D2
    #1040 rxd = 0;  // D3
    #1040 rxd = 0;  // D4
    #1040 rxd = 0;  // D5
    #1040 rxd = 0;  // D6
    #1040 rxd = 0;  // D7
    #1040 rxd = 1;  // Stop
    //
    ////////////////////

    while (1) begin
      #1040 rxd = 0;  // Start
      #1040 rxd = 0;  // D0    OUTPUT: f8, delay: 1
      #1040 rxd = 0;  // D1
      #1040 rxd = 0;  // D2
      #1040 rxd = 0;  // D3
      #1040 rxd = 0;  // D4
      #1040 rxd = 0;  // D5
      #1040 rxd = 0;  // D6
      #1040 rxd = 1;  // D7
      #1040 rxd = 1;  // Stop
  
      #1040 rxd = 0;  // Start
      #1040 rxd = 0;  // D0
      #1040 rxd = 0;  // D1
      #1040 rxd = 0;  // D2
      #1040 rxd = 0;  // D3
      #1040 rxd = 0;  // D4
      #1040 rxd = 0;  // D5
      #1040 rxd = 1;  // D6
      #1040 rxd = 0;  // D7
      #1040 rxd = 1;  // Stop
  
      #1040 rxd = 0;  // Start
      #1040 rxd = 0;  // D0
      #1040 rxd = 0;  // D1
      #1040 rxd = 0;  // D2
      #1040 rxd = 0;  // D3
      #1040 rxd = 0;  // D4
      #1040 rxd = 0;  // D5
      #1040 rxd = 0;  // D6
      #1040 rxd = 0;  // D7
      #1040 rxd = 1;  // Stop
  
      #1040 rxd = 0;  // Start
      #1040 rxd = 0;  // D0
      #1040 rxd = 0;  // D1
      #1040 rxd = 0;  // D2
      #1040 rxd = 1;  // D3
      #1040 rxd = 1;  // D4
      #1040 rxd = 1;  // D5
      #1040 rxd = 1;  // D6
      #1040 rxd = 0;  // D7
      #1040 rxd = 1;  // Stop
  
      #1040 rxd = 1;  // Idle
      #1040 rxd = 1;  // Idle

      #1040 $finish;
    end

  end

endmodule

