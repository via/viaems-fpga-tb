module mock_tlv2553(
  input wire clk,
  input wire rst,

  input wire [2:0] sel, // Choose which pair of outputs to write, e.g. "0" -> outputs 0 and 1, "2" -> 2,3, etc

  input wire [11:0] in1,
  input wire in1_w,

  input wire [11:0] in2,
  input wire in2_w,

  input wire sclk,
  output wire miso,
  input wire mosi,
  input wire cs
);


  reg [11:0] bank1[7:0];
  reg [11:0] bank2[7:0];

  always @(posedge clk) begin
    if (in1_w)
      bank1[sel] <= in1;
    if (in2_w)
      bank2[sel] <= in2;
  end

  reg [15:0] shiftreg;

  reg [2:0] last_cs;   // synchronizers for cs, sclk, and mosi
  reg [2:0] last_sclk;
  reg [2:0] last_mosi;

  wire bank_sel = shiftreg[12];
  wire [2:0] bank_idx = shiftreg[15:13];

  assign miso = shiftreg[15];

  always @(posedge clk) begin
    if (rst) begin
      last_mosi <= 0;
      last_cs <= 0;
      last_sclk <= 0;
      shiftreg <= 0;
    end else begin
      last_cs <= {last_cs[1:0], cs};
      last_sclk <= {last_sclk[1:0], sclk};
      last_mosi <= {last_mosi[1:0], mosi};

      // On falling CS edge
      if (last_cs[2:1] == 2'b10) begin
//        shiftreg <= 16'hB5F5;
        shiftreg <= {bank_sel ? bank2[bank_idx] : bank1[bank_idx], 4'b0};
      end

      // On rising SCLK
      if (last_sclk[2:1] == 2'b01) begin
        shiftreg <= {shiftreg[14:0], last_mosi[1]};
      end

      //On falling SCLK
      if (last_sclk[2:1] == 2'b10) begin
      end


    end
  end


endmodule
