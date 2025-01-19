
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
  reg [7:0] value;
  wire tx_ready;

  wire [7:0] rx_data;

  wire rx_rdy;
  reg rx_rdy_reg;


  uart_tx #(.BAUD(115200)) uart_transmit
           ( .clk(clk), .rst(~rstn), .tx(uart_tx),
             .data(value), .write(tx_write), .ready(tx_ready) );

  uart_rx #(.BAUD(115200)) uart_receive
           ( .clk(clk), .rst(~rstn), .rx(uart_rx),
             .read_data(rx_data), .read_ready(rx_rdy));

  assign dbg = rx_rdy_reg;
  assign led = value;

  always @(posedge clk) begin
    if (~rstn) begin
      value = 0;
      rx_rdy_reg = 0;
      tx_write = 0;
    end else begin
      tx_write <= 0;
      rx_rdy_reg <= rx_rdy;

      if (rx_rdy && !rx_rdy_reg) begin
        value <= rx_data;
        if (tx_ready)
          tx_write <= 1;
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
