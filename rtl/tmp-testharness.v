
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

  reg clk = 0;
  always @(posedge ft_clkout) clk = ~clk;
  assign B = {1'b0, ft_clkout, ft_txe, ft_txf, clk, 11'b0};

  assign ft_rd = 0;
  assign ft_wr = 0;


endmodule

