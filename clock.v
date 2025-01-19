
module clock (
  input wire clk12,
  input wire nrst,

  output wire clkout,
  output wire rst
);

  wire locked;
  reg [3:0] resets;

  pll pll( .clkin(clk12), .clkout0(clkout), .locked(locked));

  always @(posedge clkout)
    if (~nrst)
      resets <= 4'hF;
    else
      resets <= {resets[2:0], !locked};

  assign rst = resets[3];

endmodule


