
// UART RX
// UART TX
// LED0
// LED1

// OUT1
// OUT2

// IN1-24                               
/*                                      timer
                                          |
                                          |
UART RX -> bytes -> command parser -> control unit -> outputs
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

  uart_tx #(.CLK(96000000), .BAUD(4000000)) uart_transmit
           ( .clk(clk96), .rst(rst), .tx(uart_tx),
             .data(value), .write(tx_write), .ready(tx_ready) );

  uart_rx #(.CLK(96000000), .BAUD(4000000)) uart_receive
           ( .clk(clk96), .rst(rst), .rx(uart_rx),
             .data(rx_data), .read_ready(rx_rdy), .read_ack(rx_ack));

  reg [7:0] overflows;
  assign dbg = uart_tx;
  assign led = !rst;

  assign rx_ack = rx_rdy;

  always @(posedge clk96) begin
    if (rst) begin
      value = 0;
      tx_write = 0;
      value_ready = 0;
      overflows = 0;
    end else begin
      tx_write <= 0;

      if (rx_rdy) begin
        if (!value_ready) begin
          value <= rx_data;
          value_ready <= 1;
        end else begin
          overflows <= overflows + 1;
        end
      end

      if (tx_ready && value_ready) begin
          tx_write <= 1;
          value_ready <= 0;
      end
    end

  end


endmodule

module control_unit (
  input wire clk,
  input wire rst,

  input wire cmd_en,
  input wire [3:0] cmd_type,
  input wire [15:0] cmd_value,
  output reg [15:0] debug);

  reg [15:0] current_rpm;


  initial begin
    current_rpm = 0;
  end

  always @(posedge clk) begin
    if (rst) begin
      current_rpm <= 0;
      debug <= 0;
    end

    if (!rst) debug <= current_rpm;

    if (!rst && cmd_en) begin
      if (cmd_type == 1) begin
        current_rpm <= cmd_value;
      end
    end


  end
endmodule

module CrankNMinus1Trigger (
  input wire clk,
  input wire rst,

  input wire [15:0] rpm,
  input wire rpm_wr);

endmodule
