module fifo (
  input wire clk,
  input wire rst,

  input wire write_en,
  input wire [7:0] write_data,

  input wire read_en,
  output reg [7:0] read_data,

  output wire full,
  output wire empty,
  output wire almost_full
);

  reg [7:0] memory [1024];
  reg [9:0] read_idx;
  reg [9:0] write_idx;

  assign full = (read_idx == ((write_idx + 1) % 1024));
  assign empty = (read_idx == write_idx);
  assign almost_full = 0;

  always @(posedge clk)
    if (rst) begin
      write_idx <= 0;
      read_idx <= 0;
      read_data <= 0;
    end else begin
      if (write_en && !full) begin
        memory[write_idx] <= write_data;
        write_idx <= (write_idx + 1) % 1024;
      end 
      if (read_en && !empty) begin
        read_data <= memory[read_idx];
        read_idx <= (read_idx + 1) % 1024;
      end
    end



//  FIFO8KB #(
//    .DATA_WIDTH_R(9),
//    .DATA_WIDTH_W(9),
//    .FULLPOINTER(1024),
//    .AFPOINTER(512)
//    ) fifo8kb (
//    .DI(write_data),
//    .CLKW(clk),
//    .WE(write_en),
//    .AFF(almost_full),
//    .FF(full),
//    .EF(empty),
//    .DO(read_data),
//    .ORE(1'b1),
//    .CLKR(clk),
//    .RE(read_en)
//    );

endmodule
