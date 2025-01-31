/**
     * PLL configuration
     *
     * This Verilog module was generated automatically
     * using the gowin-pll tool.
     * Use at your own risk.
     *
     * Target-Device:                GW1NR-9 C6/I5
     * Given input frequency:        25.000 MHz
     * Requested output frequency:   60.000 MHz
     * Achieved output frequency:    60.000 MHz
     */

module pll(
        input  clkin,
        output clkout0,
        output locked
    );

    rPLL #(
        .FCLKIN("25.0"),
        .IDIV_SEL(4), // -> PFD = 5.0 MHz (range: 3-400 MHz)
        .FBDIV_SEL(11), // -> CLKOUT = 60.0 MHz (range: 400-600 MHz)
        .ODIV_SEL(8) // -> VCO = 480.0 MHz (range: 600-1200 MHz)
    ) pll (.CLKOUTP(), .CLKOUTD(), .CLKOUTD3(), .RESET(1'b0), .RESET_P(1'b0), .CLKFB(1'b0), .FBDSEL(6'b0), .IDSEL(6'b0), .ODSEL(6'b0), .PSDA(4'b0), .DUTYDA(4'b0), .FDLY(4'b0), 
        .CLKIN(clkin), // 25.0 MHz
        .CLKOUT(clkout0), // 60.0 MHz
        .LOCK(locked)
    );

endmodule

    
