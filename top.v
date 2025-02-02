
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

  output reg [7:0] led,
  output reg [7:0] out,

  input wire [11:0] inputs,

  input wire sclk,
  output wire miso,
  input wire mosi,
  input wire cs,

  output reg dbg_sclk,
  output reg dbg_miso,
  output reg dbg_mosi,
  output reg dbg_cs
);

  wire [7:0] rx_data;
  wire rx_rdy;
  wire rx_ack;

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

  wire adc_wr;
  wire [2:0] adc_sel;
  wire [11:0] adc1;
  wire [11:0] adc2;

  reg parser_wr;

  always @(posedge clk60) begin
    dbg_sclk <= sclk;
    dbg_mosi <= mosi;
    dbg_cs   <= cs;
    dbg_miso <= miso;
  end

  command_parser parser(.clk(clk60), .rst(rst),
    .data(fifo_rd),
    .data_wr(parser_wr),
    .data_rdy(cmd_rdy),
    .outputs_wr(outputs_wr),
    .outputs_data(outputs),
    .adc_wr(adc_wr),
    .adc_sel(adc_sel),
    .adc_value_1(adc1),
    .adc_value_2(adc2));

  always @(posedge clk60) begin
    parser_wr <= !fifo_empty;
  end
  

  always @(posedge clk60) begin
    if (outputs_wr) begin
      out <= outputs;
    end
  end

  mock_tlv2553 tlv2553(.clk(clk60), .rst(rst),
    .sel(adc_sel),
    .in1(adc1),
    .in1_w(adc_wr),
    .in2(adc2),
    .in2_w(adc_wr),
    .sclk(sclk),
    .miso(miso),
    .mosi(mosi),
    .cs(cs),
  );


  fifo uart_rx_fifo(.clk(clk60), .rst(rst),
    .write_en(rx_rdy),
    .write_data(rx_data),
    .read_en(cmd_rdy),
    .read_data(fifo_rd),
    .full(fifo_full),
    .empty(fifo_empty),
    .almost_full(fifo_watermark));

  always @(posedge clk60) uart_ctsn <= fifo_watermark;

  uart_rx #(.CLK(60000000), .BAUD(4000000)) uart_receive
           ( .clk(clk60), .rst(rst), .rx(uart_rx),
             .data(rx_data), .read_ready(rx_rdy), .read_ack(!fifo_full));




  wire capture_wr;
  wire [23:0] capture_data;
  wire [15:0] capture_delay;

  wire tx_ready;
  wire tx_wr;
  wire [7:0] tx_data;

  wire [39:0] cap_fifo_rd_data;
  wire cap_fifo_rd_empty;
  wire cap_fifo_rd_full;
  wire cap_encoder_rdy;

  capture cap(.clk(clk60), .rst(rst),
    .inputs(inputs),
    .data_wr(capture_wr),
    .data(capture_data),
    .delay(capture_delay));
      

  fifo #(.DEPTH(4096), .WIDTH(40)) capture_fifo(.clk(clk60), .rst(rst),
    .write_en(capture_wr),
    .write_data({capture_delay, capture_data}),
    .read_en(cap_encoder_rdy),
    .read_data(cap_fifo_rd_data),
    .empty(cap_fifo_rd_empty)
  );

  reg rd_delay;
  always @(posedge clk60) rd_delay <= cap_encoder_rdy && !cap_fifo_rd_empty;

  encoder encoder(.clk(clk60), .rst(rst),
    .capture_wr(rd_delay),
    .capture_data(cap_fifo_rd_data[23:0]),
    .capture_delay(cap_fifo_rd_data[39:24]),
    .capture_rdy(cap_encoder_rdy),
    .uart_tx_rdy(tx_ready),
    .uart_tx_data(tx_data),
    .uart_tx_wr(tx_wr)
  );


  uart_tx #(.CLK(60000000), .BAUD(4000000)) uart_transmit
           ( .clk(clk60), .rst(rst), .tx(uart_tx),
             .data(tx_data), .write(tx_wr), .ready(tx_ready) );


endmodule

