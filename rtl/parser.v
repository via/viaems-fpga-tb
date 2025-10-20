module command_parser (
  input wire clk,
  input wire rst,

  input wire [7:0] data,
  input wire data_wr,
  output wire data_rdy,

  output wire outputs_wr,
  output wire [7:0] outputs_data,

  output wire adc_wr,
  output wire [2:0] adc_sel,
  output wire [11:0] adc_value_1,
  output wire [11:0] adc_value_2,

  output wire start_cmd,
  output wire stop_cmd,
);

  reg [31:0] decode_buffer;
  reg [26:0] delay_counter;

  wire is_command = decode_buffer[31] && 
                    !decode_buffer[23] &&
                    !decode_buffer[15] &&
                    !decode_buffer[7];
  wire is_adc_cmd = is_command && (decode_buffer[30] == 1'b0);
  wire is_delay_cmd = is_command && (decode_buffer[30:28] == 3'b101);
  wire is_output_cmd = is_command && (decode_buffer[30:28] == 3'b100);

  assign start_cmd = is_command && (decode_buffer[31:0] == 32'hF0000000);
  assign stop_cmd = is_command && (decode_buffer[31:0] == 32'hF0000001);

  wire [7:0] output_value = {decode_buffer[8], decode_buffer[6:0]};
  assign outputs_wr = is_output_cmd;
  assign outputs_data = is_output_cmd ? output_value : 0;

  assign adc_wr = is_adc_cmd;
  assign adc_sel = decode_buffer[29:27];
  assign adc_value_1 = {decode_buffer[26:24],
                        decode_buffer[22:16],
                        decode_buffer[14:13]};
  assign adc_value_2 = {decode_buffer[12:8],
                        decode_buffer[6:0]};

  reg [26:0] delay_value;
  always @(*) begin
    delay_value = 0;
    if (is_delay_cmd)
      delay_value = {decode_buffer[27:24], 
                     decode_buffer[22:16], 
                     decode_buffer[14:8],
                     decode_buffer[6:0]};
    else if (is_output_cmd)
      delay_value = {decode_buffer[27:24], 
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
