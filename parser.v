module command_parser (
  input wire clk,
  input wire rst,

  input wire [7:0] data,
  input wire data_wr,
  output reg data_rdy,

  output reg cmd_rdy,
  input wire cmd_ack,

  output reg cmd_delay,
  output reg [15:0] cmd_delay_value,

  output reg cmd_output,
  output reg [7:0] cmd_output_value
);

  reg [31:0] decode_buffer;

  wire byte1_is_cmd = decode_buffer[31];
  wire byte2_is_cmd = decode_buffer[23];
  wire byte3_is_cmd = decode_buffer[15];

  always @(posedge clk)
    if (rst)
      decode_buffer <= 0;
    else
      if (data_wr) begin
        decode_buffer <= {decode_buffer[23:0], data};
        cmd_rdy <= byte2_is_cmd; // Byte1 about to become a command
      end else 
        cmd_rdy <= 0;


  always @(*) begin
    cmd_delay = 0;
    cmd_delay_value = 0;
    cmd_output = 0;
    cmd_output_value = 0;

    if (decode_buffer[31:30] == 2'b10) begin // DELAY
        cmd_delay = 1;
        cmd_delay_value = byte2_is_cmd ? 
          decode_buffer[29:24] : // Single byte delay
          {decode_buffer[29:24], decode_buffer[22:16]}; // Dual byte
    end

    if (decode_buffer[31:28] == 4'b1100) begin // OUTPUT
        cmd_output = 1;
        cmd_output_value = byte2_is_cmd ? 
          decode_buffer[27:24] : // Single byte delay
          {decode_buffer[27:24], decode_buffer[20:16]}; // Dual byte
    end

  end

endmodule
