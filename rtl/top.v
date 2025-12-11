
module top (
  input ft_clkout,
  output ft_oe,
  output ft_rd,
  output ft_wr,
  input ft_txe,
  input ft_rxf,
  inout [7:0] ft_d,

  input [7:0] A,
  input [7:0] B,
  input [7:0] C,
  output [7:0] D,
  output status,

  input wire sclk,
  output wire miso,
  input wire mosi,
  input wire cs
);

  wire [7:0] outputs;
  wire [31:0] inputs;

  assign inputs = {8'h0, C, 5'b0, B[2:0], 5'b0, A[2:0]};

  assign D = outputs;


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
              .cs(cs),
              .status(status));


endmodule

