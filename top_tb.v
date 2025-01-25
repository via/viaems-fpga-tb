module top_tb();
  reg clk;
  reg rst;


  reg rxd;

  wire [7:0] outputs;
  wire nrst = !rst;

  
  initial begin
    $dumpvars;
    clk = 0;
    rst = 1;
    rxd = 1;
    forever #5 clk = ~clk;
  end

  top dut(.clk(clk), .rstn(nrst), .uart_rx(rxd),
          .led(outputs));


  initial begin
    #50 rst = 0;
    rxd = 0;        // start
    #1040 rxd = 0;  // D0
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

    #1040 rxd = 1;  // Idle
    #1040 rxd = 1;  // Idle
    $finish;
  end

endmodule

