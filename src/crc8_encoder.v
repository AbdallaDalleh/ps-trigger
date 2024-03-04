
module crc8_encoder (
	
	input        clk,
	input        reset,
	input  [7:0] data_in,
	output [9:0] data_out
);

	wire [7:0] crc_o;
	wire [3:0] counter;
	wire KI;

	crc8_stream #(
		.POLYNOMIAL(8'h07)
	) crc_stream0 (
		.clk(clk),
		.reset(reset),
		.data_i(data_in),
		.crc_o(crc_o),
		.byte_counter(counter)
	);
	
	enc_8b10b encoder0 (
		.clk(clk),
		.reset(reset),
		.ena(1'b1),
		.KI(KI),
		.datain(crc_o),
		.dataout(data_out)
	);
	
	assign KI = (counter == 4'h0 || counter == 4'b1001);
	// assign KI = 1'b1;

endmodule
