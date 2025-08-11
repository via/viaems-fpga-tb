
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

  output reg [7:0] out,

  input wire [11:0] inputs,

  input wire sclk,
  output wire miso,
  input wire mosi,
  input wire cs,
);

  wire clk60;
  wire rst;

  clock clocks (.clk12(clk), .nrst(rstn), .clkout(clk60), .rst(rst));

  core core ( .clk(clk60), .rst(rst),
              .uart_tx(uart_tx),
              .uart_rx(uart_rx),
              .uart_ctsn(uart_ctsn),
              .out(out),
              .inputs(inputs),
              .sclk(sclk),
              .miso(miso),
              .mosi(mosi),
              .cs(cs) );


endmodule

