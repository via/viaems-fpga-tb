
// UART RX
// UART TX
// LED0
// LED1

// OUT1
// OUT2

// IN1-24                               
/*                                       timer
                                           |
                                           |
UART RX -> uart_rx -> FIFO -> parser -> cmd_delay
                                     -> cmd_output -> outputs
                                     -> cmd_adc -> spi adc
                                           |
                                           |
                                           |
                                       capture unit <- inputs
 

*/

module top (
  input wire clk,
  input wire rstn,

  output wire uart_tx,
  input wire uart_rx,

  output wire uart_ctsn,

  output reg dbg,
  output reg [7:0] led,
  output reg [7:0] out
);

  reg tx_write;
  wire tx_ready;

  wire [7:0] rx_data;

  wire rx_rdy;
  wire rx_ack;

  reg [7:0] value;
  reg value_ready;

  wire clk60;
  wire rst;

  clock clocks (.clk12(clk), .nrst(rstn), .clkout(clk60), .rst(rst));

  wire fifo_full;
  wire fifo_empty;
  wire fifo_watermark;
  wire [7:0] fifo_rd;
  wire cmd_rdy;

  wire [7:0] outputs;
  wire outputs_wr;

  reg parser_wr;

  command_parser parser(.clk(clk60), .rst(rst),
    .data(fifo_rd),
    .data_wr(parser_wr),
    .data_rdy(cmd_rdy),
    .outputs_wr(outputs_wr),
    .outputs_data(outputs));

  always @(posedge clk60)
    parser_wr <= !fifo_empty;

  always @(posedge clk60) begin
    if (outputs_wr) begin
      led <= outputs;
      out[6:0] <= outputs[6:0];
    end
    out[7] <= fifo_empty;
  end


  fifo uart_rx_fifo(.clk(clk60), .rst(rst),
    .write_en(rx_rdy),
    .write_data(rx_data),
    .read_en(cmd_rdy),
    .read_data(fifo_rd),
    .full(fifo_full),
    .empty(fifo_empty),
    .almost_full(fifo_watermark));

  assign uart_ctsn = fifo_watermark;

  uart_tx #(.CLK(60000000), .BAUD(4000000)) uart_transmit
           ( .clk(clk60), .rst(rst), .tx(uart_tx),
             .data(rx_data), .write(1'b0), .ready(tx_ready) );

  uart_rx #(.CLK(60000000), .BAUD(4000000)) uart_receive
           ( .clk(clk60), .rst(rst), .rx(uart_rx),
             .data(rx_data), .read_ready(rx_rdy), .read_ack(!fifo_full));


endmodule

