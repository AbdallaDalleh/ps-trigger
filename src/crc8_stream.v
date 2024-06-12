//
// This module will encode proper CP_F frames as 8b-10b after calculating
// CRC8 for the status, control, address and data bytes.
//
module FrameEncoder
(
    input  wire       clk,
	input  wire       reset,
    input  wire [7:0] data_in,
	input  wire       is_control_byte,
	input  wire       is_crc_byte,
	input  wire       crc_reset,
    output wire [9:0] data_out
);

	wire [7:0] crc_byte;
	wire [7:0] crc_o;

	CRC8Generator #(
		.POLYNOMIAL(8'h07),
		.INITIAL(8'hFF)
	) crc8_0 (
		.clk_i(clk),
		.rst_i(crc_reset),
		.data_i(data_in),
		.data_valid_i(1'b1),
		.crc_o(crc_byte)
	);

	Encoder8b10b encoder (
		.clk(clk),
		.reset(reset),
		.KI(is_control_byte),
		.ena(1'b1),
		.datain(crc_o),
		.dataout(data_out)
	);

	assign crc_o = (is_crc_byte ? crc_byte : data_in);

endmodule