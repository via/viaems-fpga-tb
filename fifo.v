module fifo #(
  parameter DEPTH = 4096,
  parameter WIDTH = 8
  )
  (
  input wire clk,
  input wire rst,

  input wire write_en,
  input wire [WIDTH - 1:0] write_data,

  input wire read_en,
  output reg [WIDTH - 1:0] read_data,

  output wire full,
  output wire empty,
  output wire almost_full
);

  localparam IDX_BITS = $clog2(DEPTH);
  reg [WIDTH - 1:0] memory [DEPTH];
  reg [IDX_BITS-1:0] read_idx;
  reg [IDX_BITS-1:0] write_idx;

  assign full = (read_idx == (write_idx + 1));
  assign empty = (read_idx == write_idx);

  assign almost_full = ((write_idx - read_idx) >> (IDX_BITS - 2)) == 2'b11;

  always @(posedge clk)
    if (rst) begin
      write_idx <= 0;
      read_idx <= 0;
      read_data <= 0;
    end else begin
      if (write_en && !full) begin
        memory[write_idx] <= write_data;
        write_idx <= write_idx + 1;
      end 
      if (read_en && !empty) begin
        read_data <= memory[read_idx];
        read_idx <= read_idx + 1;
      end
    end
endmodule
