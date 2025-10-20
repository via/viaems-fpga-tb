
`define assert(signal, value) \
  if (signal != value) $display("ASSERT FAIL in %m: signal != value");

module parser_tb();
  reg clk;
  reg rst;

  reg [7:0] data;
  reg data_wr;


  initial begin
    $dumpvars;
    clk = 0;
    rst = 1;
    data = 0;
    data_wr = 0;
    forever #5 clk = ~clk;
  end

  command_parser parser(.clk(clk), 
                        .rst(rst), 
                        .data(data),
                        .data_wr(data_wr));

  initial begin
    #50 rst = 0;

    #10 data = 8'b11000000;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b00000000;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b00000000;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b00001100;
    data_wr = 1;
    #10 data_wr = 0;

    while (!parser.data_rdy)
      #10 ;

    #10 data = 8'b10000000;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b00000000;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b00000001;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b0010101;
    data_wr = 1;
    #10 data_wr = 0;

    while (!parser.data_rdy)
      #10 ;

    #10 data = 8'b11111111;
    data_wr = 1;
    #10 data_wr = 0;

    #10 $finish;
  end

endmodule
