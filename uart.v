
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
  reg [15:0] baudtimer;

  wire baudtimer_done = (baudtimer == (CLK / BAUD) - 1);

  assign ready = (state == IDLE) || (state == STOP);

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
            baudtimer <= 0;
          end
        end

        START: begin
          baudtimer <= baudtimer + 1;
          tx <= 0;
          if (baudtimer_done) begin
            state <= DATA;
            baudtimer <= 0;
          end
        end

        DATA: begin
          baudtimer <= baudtimer + 1;
          tx <= shiftreg[0];
          if (baudtimer_done) begin
            shiftreg <= {1'b0, shiftreg[7:1]};
            baudtimer <= 0;

            bits = bits - 1;
            if (bits == 0) state <= STOP;
          end
        end

        STOP: begin
          tx <= 1;
          baudtimer <= baudtimer + 1;
          if (baudtimer_done) begin
            state <= IDLE;
            // allow a transition straight to start bit
            if (write) begin
              shiftreg <= data;
              bits <= 8;
              state <= START;
              baudtimer <= 0;
            end
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

  output reg [7:0] data,
  output reg read_ready,
  input wire read_ack
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

      if (read_ready && read_ack)
        read_ready <= 0;

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
              data <= shiftreg;
            end
            timer <= 0;
          end else if (timer == HALFPERIOD - 1) begin
            shiftreg <= {rx, shiftreg[7:1]};
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

