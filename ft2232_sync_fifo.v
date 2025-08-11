module ft2232_sync_fifo (
  input ft_clkout,
  output ft_oe,
  input ft_txe,
  input ft_rxf,
  output ft_wr,
  output ft_rd,
  inout [7:0] ft_d,

  input read_ready,
  output read,
  output [7:0] read_data,

  input write_ready,
  output write,
  input [7:0] write_data
);

  reg transmitting = 1;
  reg stall = 0;
  reg [15:0] burst_counter = 0;

  wire ft_issue_write;
  wire ft_issue_read;

  assign ft_oe = transmitting;
  assign read_data = ft_d;
  assign ft_d = transmitting ? write_data : 8'hZZ;

  assign ft_issue_read = ~ft_oe && read_ready && ~ft_rxf && ~stall;
  assign ft_issue_write = ft_oe && write_ready && ~ft_txe && ~stall;

  assign read = ft_issue_read;
  assign ft_rd = ~ft_issue_read;

  assign write = ft_issue_write;
  assign ft_wr = ~ft_issue_write;

  always @(posedge ft_clkout) begin
    if (stall)
      stall = 0;

    else if (transmitting && ~stall)
      if (~ft_rxf && ((burst_counter == 16'hFFFF) || ft_txe)) begin
        transmitting = 0;
        stall = 1;
        burst_counter = 0;
      end else begin
        burst_counter = { burst_counter[14:0], 1'b1 };
      end
    else if (~transmitting && ~stall)
      if (~ft_txe && ((burst_counter == 16'hFFFF) || ft_rxf)) begin
        transmitting = 1;
        stall = 1;
        burst_counter = 0;
      end else begin
        burst_counter = { burst_counter[14:0], 1'b1 };
      end
  end
endmodule
