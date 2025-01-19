
module uart_baudgen #(
    parameter DIVISOR = 104
  )
  (
  input wire clk,
  input wire rst,
  output wire tx_clk);

  reg [15:0] counter;

//  always @(posedge clk) begin
//    if (rst) begin
//      counter = 0;
//      tx_clk = 0;
//    end else begin
//      tx_clk = 0;
//      counter = counter + 1;
//      if (counter == DIVISOR) begin
//        counter = 0;
//        tx_clk = 1;
//      end
//    end
//  end

  assign tx_clk = (counter == 0);

  always @(posedge clk) begin
    if (rst) begin
      counter <= 0;
    end else begin
      if (counter == DIVISOR - 1)
        counter <= 0;
      else
        counter <= counter + 1;

    end
  end

endmodule


module uart_tx #(
    parameter CLK = 12000000,
    parameter BAUD = 1500000
  ) (
  input wire clk,
  input wire rst,

  output reg tx,

  input wire [7:0] data,
  input wire write,
  
  output wire ready
);

  parameter IDLE  = 2'd0;
  parameter START = 2'd1;
  parameter DATA  = 2'd2;
  parameter STOP  = 2'd3;

  reg [3:0] bits;
  reg [1:0] state;
  reg [7:0] shiftreg;
  wire baudclk;

  uart_baudgen #(.DIVISOR(CLK/BAUD)) baud (.clk(clk), .rst(rst), .tx_clk(baudclk));

  assign ready = (state == IDLE);

  always @(posedge clk)
    if (rst) begin
      shiftreg <= 0;
      state <= IDLE;
      tx <= 0;
    end else begin
      case (state)

        IDLE: begin
          tx <= 1;
          if (write) begin
            shiftreg <= data;
            bits <= 8;
            state <= START;
          end
        end

        START: begin
          if (baudclk) begin
            tx <= 0;
            state <= DATA;
          end
        end

        DATA: begin
          if (baudclk) begin
            tx <= shiftreg[0];
            shiftreg <= shiftreg[7:1];
            bits <= bits - 1;
            if (bits == 1) state <= STOP;
          end
        end

        STOP: begin
          if (baudclk) begin
            tx <= 1;
            state <= IDLE;
          end
        end

      endcase
    end
endmodule


module uart_rx #(
    parameter CLK = 12000000,
    parameter BAUD = 115200
  ) (
  input wire clk,
  input wire rst,

  input wire rx,

  output reg [7:0] read_data,
  output reg read_ready
);

  parameter IDLE  = 2'd0;
  parameter START = 2'd1;
  parameter DATA  = 2'd2;
  parameter STOP  = 2'd3;

  localparam PERIOD = CLK / BAUD;
  localparam HALFPERIOD = PERIOD / 2;

  reg [3:0] bits;
  reg [1:0] state;
  reg [7:0] shiftreg;

  reg [15:0] timer;

  always @(posedge clk)
    if (rst) begin
      shiftreg <= 0;
      state <= IDLE;
      timer <= 0;
      read_ready <= 0;
    end else begin
      case (state)
        IDLE: begin
          // Wait for transition to low
          if (rx == 0) begin
            timer <= 0;
            read_ready <= 0;
            state <= START;
          end
        end

        START: begin
          timer <= timer + 1;
          if (timer == PERIOD - 1) begin
            timer <= 0;
            state <= DATA;
            bits <= 0;
            shiftreg <= 0;
          end
        end

        DATA: begin
          timer <= timer + 1;
          if (timer == PERIOD - 1) begin
            if (bits == 8) begin
              state <= STOP;
              read_ready <= 1;
              read_data <= shiftreg;
            end
            timer <= 0;
          end else if (timer == HALFPERIOD - 1) begin
            shiftreg <= {shiftreg[6:0], rx};
            bits <= bits + 1;
          end
        end

        STOP: begin
          if (rx == 1)
            state <= IDLE;
        end

      endcase
    end
endmodule

