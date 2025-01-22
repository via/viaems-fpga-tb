
module cmd_delay (
  input wire clk,
  input wire rst,
  input wire en,

  input wire start,
  input wire [12:0] delay_value,
  output wire busy
);

  reg [12:0] counter;

  assign busy = (counter != 0);

  always @(posedge clk)
    if (rst)
      counter <= 0;
    else if (en) begin
      if (start)
        counter <= delay_value;
      else if (counter > 0)
        counter <= counter - 1;
      else
        counter <= 0

endmodule
