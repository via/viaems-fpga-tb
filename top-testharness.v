
module top (
  input ft_clkout,
  output ft_oe,
  output ft_rd,
  output ft_wr,
  input ft_txe,
  input ft_rxf,
  inout [7:0] ft_d,

  input [15:0] A,
  inout [15:0] B,

  input wire sclk,
  output wire miso,
  input wire mosi,
  input wire cs
);

  wire [7:0] outputs;
  wire [31:0] inputs;

  assign inputs = {16'h0000, A};

  // A[15:0] are inputs, B[15:8] are outputs
  assign B = {outputs, 8'hZZ};

  core core ( 
              .ft_clkout(ft_clkout),
              .ft_oe(ft_oe),
              .ft_txe(ft_txe),
              .ft_rxf(ft_rxf),
              .ft_wr(ft_wr),
              .ft_rd(ft_rd),
              .ft_d(ft_d),
              .out(outputs),
              .inputs(inputs),
              .sclk(sclk),
              .miso(miso),
              .mosi(mosi),
              .cs(cs) );


endmodule

