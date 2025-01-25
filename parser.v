module command_parser (
  input wire clk,
  input wire rst,

  input wire [7:0] data,
  input wire data_wr,
  output wire data_rdy,

  output wire outputs_wr,
  output wire [7:0] outputs_data
);

  reg [31:0] decode_buffer;
  reg [31:0] delay_counter;

  wire is_command = decode_buffer[31];
  wire is_delay_cmd = is_command && (decode_buffer[30] == 1'b1);
  wire is_output_cmd = is_command && (decode_buffer[30:29] == 2'b00);

  wire [7:0] output_value = {decode_buffer[8], decode_buffer[6:0]};
  assign outputs_wr = is_output_cmd;
  assign outputs_data = is_output_cmd ? output_value : 0;

  reg [31:0] delay_value;
  always @(*) begin
    delay_value = 0;
    if (is_delay_cmd)
      delay_value = {decode_buffer[29:24], 
                     decode_buffer[22:16], 
                     decode_buffer[14:8],
                     decode_buffer[6:0]};
    else if (is_output_cmd)
      delay_value = {decode_buffer[28:24], 
                     decode_buffer[22:16], 
                     decode_buffer[14:9]};
  end

  wire paused = (delay_counter != delay_value << 2);
  assign data_rdy = !paused;

  always @(posedge clk)
    if (rst) begin
      decode_buffer <= 0;
      delay_counter <= 0;
    end else
      if (data_wr && !paused) begin
        decode_buffer <= {decode_buffer[23:0], data};
        delay_counter <= 0;
      end else if (paused)
        delay_counter <= delay_counter + 1;



endmodule
