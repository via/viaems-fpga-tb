
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

    #10 data = 8'b10101010;
    data_wr = 1;
    #10 data_wr = 0;
    `assert(parser.cmd_rdy, 0)

    #10 data = 8'b10111011;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b00110110;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b11001010;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b01000101;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b11111111;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b11111111;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b11111111;
    data_wr = 1;
    #10 data_wr = 0;

    #10 data = 8'b11111111;
    data_wr = 1;
    #10 data_wr = 0;

    #10 $finish;
  end

endmodule
