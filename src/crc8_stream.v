
module crc8_stream #(parameter POLYNOMIAL=8'h07)
(
    input  wire clk,
	input  wire reset,
    input  wire [7:0] data_i,
    output wire [7:0] crc_o,
	output wire [3:0] byte_counter
);

	reg [3:0] prev_counter;
	wire crc_reset;
	reg  [3:0] counter = 4'hf;
	wire [7:0] crc_byte;
	wire is_crc_byte;

	crc8 #(
		.POLYNOMIAL(8'h07),
		.INITIAL(8'hFF)
	) crc8_0 (
		.clk_i(clk),
		.rst_i(crc_reset),
		.data_i(data_i),
		.data_valid_i(1'b1),
		.crc_o(crc_byte)
	);

	assign is_crc_byte = (counter == 4'h7);
	assign crc_reset   = (counter == 4'hf && prev_counter == 4'hf) || (counter == 4'h0 && prev_counter == 4'h9);
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			counter <= 4'hf;
			prev_counter <= 4'hf;
		end
		else begin
			counter <= counter + 4'b1;
			prev_counter <= counter;
			if (counter == 4'b1001)
				counter <= 4'b0;
		end
	end

	assign crc_o = is_crc_byte ? crc_byte : data_i;
	assign byte_counter = counter;

endmodule