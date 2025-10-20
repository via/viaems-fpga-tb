module encoder_tb();
  reg clk;
  reg rst;

  reg [23:0] inputs;

  wire data_wr;
  wire [23:0] data_out;
  wire [15:0] delay_out;


  initial begin
    $dumpvars;
    clk = 0;
    rst = 1;
    inputs = 0;
    forever #5 clk = ~clk;
  end

  capture dut(.clk(clk), .rst(rst), .inputs(inputs), .data_wr(data_wr), .data(data_out), .delay(delay_out));

  initial begin
    #50 rst = 0;

    inputs = 24'h200;

    #20 inputs = 24'h020;
    
    
    #100 inputs = 24'h000;
    #40 inputs = 24'h020;
    #40 inputs = 24'h021;
    #40 inputs = 24'h000;

    #500 $finish;
  end

endmodule

