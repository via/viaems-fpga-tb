
module top (
  input ft_clkout,
  output ft_oe,
  output ft_rd,
  output ft_wr,
  input ft_txe,
  input ft_rxf,
  inout [7:0] ft_d,

  inout [15:0] A,
  inout [15:0] B,

  input wire sclk,
  output wire miso,
  input wire mosi,
  input wire cs
);

  wire [7:0] outputs;
  wire [31:0] inputs;

  // B[15:8] is outputs, B[7:] + A[15:0] is input pins
  assign inputs = {A, B};

  assign A = 16'hZZZZ;
  assign B = {8'hZZ, outputs}; 

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

