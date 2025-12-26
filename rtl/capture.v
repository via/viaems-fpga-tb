module capture(
  input wire clk,
  input wire rst,

  input wire [23:0] inputs,

  output reg data_wr,
  output reg [23:0] data,
  output reg [15:0] delay
  );

  reg [23:0] input_stages[5:0];
  reg [15:0] counter;

  always @(posedge clk) begin
    if (rst) begin
      input_stages[5] <= 0;
      input_stages[4] <= 0;
      input_stages[3] <= 0;
      input_stages[2] <= 0;
      input_stages[1] <= 0;
      input_stages[0] <= 0;
      data_wr <= 0;
      data <= 0;
      delay <= 0;
      counter <= 0;
    end else begin
      input_stages[5] <= input_stages[4];
      input_stages[4] <= input_stages[3];
      input_stages[3] <= input_stages[2];
      input_stages[2] <= input_stages[1];
      input_stages[1] <= input_stages[0];
      input_stages[0] <= inputs;

      if ((input_stages[5] != input_stages[4]) || (counter == 16'hFFFF)) begin
        data_wr <= 1;
        data <= input_stages[4];
        delay <= counter;
        counter <= 0;
      end else begin
        data_wr <= 0;
        data <= 0;
        delay <= 0;
        counter <= counter + 1;
      end
    end
  end
endmodule
