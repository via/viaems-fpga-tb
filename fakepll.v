module pll
(
    input clkin, // 12 MHz, 0 deg
    output clkout0, // 12 MHz
    output locked
);

  assign clkout0 = clkin;
  assign locked = 1;

endmodule
