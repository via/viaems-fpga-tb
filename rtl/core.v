module core (

  input ft_clkout,
  output ft_oe,
  output ft_rd,
  output ft_wr,
  input ft_txe,
  input ft_rxf,
  inout [7:0] ft_d,

  output reg [7:0] out,
  input wire [31:0] inputs,

  output wire sclk,
  input wire miso,
  output wire mosi,
  output wire cs,

  output wire status
);

  // Simple power-on reset
  reg rst = 1;
  reg [3:0] por = 10;

  always @(posedge ft_clkout) begin
      rst <= (por > 0);
      por <= (por == 0) ? 0 : (por - 1);
  end

  wire [7:0] rx_data;
  wire rx_fifo_wr;

  wire rx_fifo_full;
  wire rx_fifo_empty;
  wire [7:0] rx_fifo_rd;
  wire cmd_rdy;

  wire [7:0] outputs;
  wire outputs_wr;

  wire adc_wr;
  wire [2:0] adc_sel;
  wire [11:0] adc1;
  wire [11:0] adc2;

  wire start_cmd;
  wire stop_cmd;

  reg parser_wr;

  reg scenario_running;

  command_parser parser(.clk(ft_clkout), .rst(rst),
    .data(rx_fifo_rd),
    .data_wr(parser_wr),
    .data_rdy(cmd_rdy),
    .outputs_wr(outputs_wr),
    .outputs_data(outputs),
    .adc_wr(adc_wr),
    .adc_sel(adc_sel),
    .adc_value_1(adc1),
    .adc_value_2(adc2),
    .start_cmd(start_cmd),
    .stop_cmd(stop_cmd));

  always @(posedge ft_clkout)
    if (rst || stop_cmd)
      scenario_running <= 0;
    else if (start_cmd)
      scenario_running <= 1;

  always @(posedge ft_clkout) begin
    parser_wr <= !rx_fifo_empty;
  end

  reg capture_wr;
  wire cap_fifo_full;

  always @(posedge ft_clkout) begin
    if (rst)
      out <= 0;
    else if (outputs_wr)
      out <= {outputs[7:0]};
  end

//  mock_tlv2553 tlv2553(
//    .clk(ft_clkout),
//    .rst(rst || !scenario_running),
//    .sel(adc_sel),
//    .in1(adc1),
//    .in1_w(adc_wr),
//    .in2(adc2),
//    .in2_w(adc_wr),
//    .sclk(sclk),
//    .miso(miso),
//    .mosi(mosi),
//    .cs(cs)
//  );
  ad5674 dac(
    .clk(ft_clkout),
    .rst(rst), // || !scenario_running),
    .sel(adc_sel),
    .in1(adc1),
    .in1_w(adc_wr),
    .in2(adc2),
    .in2_w(adc_wr),
    .sclk(sclk),
    .miso(miso),
    .mosi(mosi),
    .cs(cs)
  );


  fifo uart_rx_fifo(.clk(ft_clkout), .rst(rst),
    .write_en(rx_fifo_wr),
    .write_data(rx_data),
    .read_en(cmd_rdy),
    .read_data(rx_fifo_rd),
    .full(rx_fifo_full),
    .empty(rx_fifo_empty)
  );


  wire [23:0] capture_data;
  wire [15:0] capture_delay;

  wire tx_ready;
  wire tx_wr;
  wire [7:0] tx_data;

  wire [39:0] cap_fifo_rd_data;
  wire cap_fifo_rd_empty;
  wire cap_fifo_rd_full;
  wire cap_encoder_rdy;

  capture cap(.clk(ft_clkout), .rst(rst),
    .inputs({out[1:0], inputs[21:0]}),
    .data_wr(capture_wr),
    .data(capture_data),
    .delay(capture_delay));

  reg rd_delay;
  always @(posedge ft_clkout) rd_delay <= cap_encoder_rdy && !cap_fifo_rd_empty;

  fifo #(.DEPTH(1024), .WIDTH(40)) capture_fifo(.clk(ft_clkout), .rst(rst || !scenario_running),
    .write_en(capture_wr),
    .write_data({capture_delay, capture_data}),
    .read_en(cap_encoder_rdy && !cap_fifo_rd_empty),
    .read_data(cap_fifo_rd_data),
    .empty(cap_fifo_rd_empty),
    .full(cap_fifo_full),
  );

  encoder encoder(.clk(ft_clkout), .rst(rst || !scenario_running),
    .capture_overflow(capture_wr && cap_fifo_full),
    .parser_underflow(scenario_running && cmd_rdy && rx_fifo_empty),
    .capture_wr(rd_delay),
    .capture_data(cap_fifo_rd_data[23:0]),
    .capture_delay(cap_fifo_rd_data[39:24]),
    .capture_rdy(cap_encoder_rdy),
    .uart_tx_wr(tx_wr),
    .uart_tx_wr_ready(tx_ready),
    .uart_tx_data(tx_data),
  );


  ft2232_sync_fifo usb(.ft_clkout(ft_clkout),
                       .ft_oe(ft_oe),
                       .ft_txe(ft_txe),
                       .ft_rxf(ft_rxf),
                       .ft_wr(ft_wr),
                       .ft_rd(ft_rd),
                       .ft_d(ft_d),

                       .read_ready(~rx_fifo_full),
                       .read(rx_fifo_wr),
                       .read_data(rx_data),

                       .write_ready(tx_ready), // ???
                       .write(tx_wr),
                       .write_data(tx_data)
                      );


  reg [31:0] status_counter = 0;
  assign status = status_counter > 15000000;
  always @(posedge ft_clkout)
    if (status_counter > 30000000)
      status_counter = 0;
    else
      status_counter = status_counter + 1;


endmodule

