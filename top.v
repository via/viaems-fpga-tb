
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

  output reg uart_ctsn,

  output wire dbg,
  output wire [7:0] led
);

  reg tx_write;
  wire tx_ready;

  wire [7:0] rx_data;

  wire rx_rdy;
  wire rx_ack;

  reg [7:0] value;
  reg value_ready;

  wire clk96;
  wire rst;

  clock clocks (.clk12(clk), .nrst(rstn), .clkout(clk96), .rst(rst));

  reg [31:0] xcounter;
  always @(posedge clk96)
    if (rst)
      xcounter <= 0;
    else
      if (xcounter > 96000000 - 1)
        xcounter <= 0;
      else 
        xcounter <= xcounter + 1;

  wire fifo_full;
  fifo uart_rx_fifo(.clk(clk96), .rst(rst), 
    .write_en(rx_rdy),
    .write_data(rx_data), 
    .read_en(xcounter == 0),
    .read_data(led),
    .full(fifo_full));

  uart_tx #(.CLK(96000000), .BAUD(115200)) uart_transmit
           ( .clk(clk96), .rst(rst), .tx(uart_tx),
             .data(value), .write(tx_write), .ready(tx_ready) );

  uart_rx #(.CLK(96000000), .BAUD(115200)) uart_receive
           ( .clk(clk96), .rst(rst), .rx(uart_rx),
             .data(rx_data), .read_ready(rx_rdy), .read_ack(!fifo_full));

endmodule

