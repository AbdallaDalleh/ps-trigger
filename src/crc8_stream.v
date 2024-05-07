
module crc8_stream #(parameter POLYNOMIAL=8'h07)
(
	input  wire clk,
	input  wire reset,
	input  wire [7:0] data_i,
	output wire [7:0] crc_o,
	output wire [3:0] byte_counter
);

	localparam TX_BYTE_COUNT = 4'd9;

	wire crc_reset;
	reg  [3:0] counter;
	wire [7:0] crc_byte;
	wire is_crc_byte;

	crc8_core #(
		.POLYNOMIAL(8'h07),
		.INITIAL(8'hFF)
	) crc8_0 (
		.clk_i(clk),
		.rst_i(crc_reset),
		.data_i(data_i),
		.data_valid_i(1'b1),
		.crc_o(crc_byte)
	);

	assign is_crc_byte = (counter == 4'h8);
	assign crc_reset   = (counter == 4'h0);
	always @(posedge clk or negedge reset) begin
		if (~reset) begin
			counter <= 4'h0;
		end
		else begin
			counter <= counter + 4'b1;
			if (counter == TX_BYTE_COUNT)
				counter <= 4'b0;
		end
	end

	assign crc_o = is_crc_byte ? crc_byte : data_i;
	assign byte_counter = counter;

endmodule
