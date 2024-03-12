
module encoder_8b10b (

	input wire clk,
	input wire reset,
	input wire [7:0] datain,
	input wire KI,
	output wire [9:0] dataout

);

	wire       current_rd;
	wire       next_rd;
	wire [9:0] data_code;
	wire [9:0] control_code;
	
	encoder_8b10b_rom data (
		.data_in(datain),
		.current_rd(current_rd),
		.KI(KI),
		.code(dataout),
		.next_rd(next_rd)
	);
	
	encoder_8b10b_fsm fsm0 (
		.clk(clk),
		.reset(reset),
		.next_rd(next_rd),
		.current_rd(current_rd)
	);	

endmodule
