module ff_sync(
  input wire clk,
  input wire in,
  output wire out);

  reg ff1;
  reg ff2;

  assign out = ff2;
  always @(posedge clk) begin
    ff1 <= in;
    ff2 <= ff1;
  end

endmodule

