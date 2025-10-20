module encoder(
  input wire clk,
  input wire rst,

  input wire capture_overflow,
  input wire capture_wr,
  input wire [23:0] capture_data,
  input wire [15:0] capture_delay,
  output wire capture_rdy,

  input wire uart_tx_wr,
  output reg [7:0] uart_tx_data,
  output wire uart_tx_wr_ready
);
  reg [4:0] total_bytes;
  reg [4:0] current_byte;
  reg [63:0] payload;
  reg overflowed;

  wire in_progress = (total_bytes != current_byte);

  assign uart_tx_wr_ready = in_progress;
  assign capture_rdy = !in_progress && !capture_wr;

  always @(posedge clk) begin
    if (rst) begin
      payload <= 0;
      total_bytes <= 0;
      current_byte <= 0;
      overflowed <= 0;
    end else begin

      if (capture_overflow)
        overflowed <= 1;

      if (!in_progress && overflowed) begin
        overflowed <= 0;
        total_bytes <= 1;
        current_byte <= 0;

        payload <= {8'b10110000,
                    8'b0,
                    8'b0,
                    8'b0,
                    8'b0,
                    8'b0,
                    8'b0,
                    8'b0};

      end else if (!in_progress && capture_wr) begin
        total_bytes <= 6;
        current_byte <= 0;

        payload <= {3'b110, capture_delay[15:11],
                    1'b0,   capture_delay[10:4],
                    1'b0,   capture_delay[3:0], capture_data[23:21],
                    1'b0,   capture_data[20:14],
                    1'b0,   capture_data[13:7],
                    1'b0,   capture_data[6:0],
                    8'b0,
                    8'b0};
//      payload <= { 8'h1F,
//                   8'h2F,
//                   8'h3F,
//                   8'h4F,
//                   8'h5F,
//                   8'h6F,
//                   8'h7F,
//                   8'h8F
//                   };

     end else if (in_progress && uart_tx_wr) begin
        uart_tx_data <= payload[63:56];
        payload <= {payload[55:0], 8'b0};
        current_byte <= current_byte + 1;
      end else begin
      end
    end
  end

endmodule

