module pll
(
    input clkin, // 12 MHz, 0 deg
    output clkout0, // 60 MHz, 0 deg
    output locked
);

  assign clkout0 = clkin;
  assign locked = 1;

endmodule
