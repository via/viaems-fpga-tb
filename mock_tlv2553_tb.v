`timescale 1us/1ns
module mock_tlv2553_tb();
  reg clk;
  reg rst;

  wire miso;
  reg mosi;
  reg sclk;
  reg cs;

  initial begin
    $dumpvars;
    clk = 0;
    rst = 1;

    mosi = 0;
    sclk = 0;
    cs = 1;
    forever #5 clk = ~clk;
  end

  mock_tlv2553 dut(.clk(clk), .rst(rst),
                   .sel(3'b0),
                   .in1(12'b0),
                   .in1_w(1'b0),
                   .in2(12'b0),
                   .in2_w(1'b0),
                   .sclk(sclk),
                   .miso(miso),
                   .mosi(mosi),
                   .cs(cs));

  initial begin
    #50 rst = 0;

    #40 cs = 0;

    #20 mosi = 0;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 0;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 0;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 0;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #20 mosi = 1;
    #20 sclk = 1;
    #40 sclk = 0;

    #40 cs = 1;

    #100 $finish;
  end

endmodule
