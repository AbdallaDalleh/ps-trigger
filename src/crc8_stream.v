
module FrameEncoder
(
    input  wire clk,
	input  wire reset,
    input  wire [7:0] data_in,
	input  wire [3:0] counter,
    output wire [9:0] data_out
);

	reg [3:0] prev_counter;
	wire crc_reset;
	wire [7:0] crc_byte;
	wire [7:0] crc_o;
	wire is_crc_byte;
	wire KI;

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
		.KI(KI),
		.ena(1'b1),
		.datain(crc_o),
		.dataout(data_out)
	);

	assign KI          = (counter == 4'h0 || counter == 4'b1001);
	assign is_crc_byte = (counter == 4'h8);
	assign crc_reset   = (counter == 4'h0);
	assign crc_o       = (is_crc_byte ? crc_byte : data_in);

endmodule