
module PSC_Trigger
(
	input  wire clk,
	input  wire reset,
	input  wire evr_trigger,
	output wire psc_output
);

	wire [3:0] tx_counter;
	wire [7:0] tx_byte;
	wire [9:0] encoder_out;
	wire       trigger_signal;
	wire       clk_10;
	wire       clk_1;
	wire       load_register;
	wire       is_trigger;

	altpll_50_10 pll_0 (
		.inclk0(clk),
		.c0(clk_10),
		.c1(clk_1)
	);
	
	positive_edge_detector detector0 (
		.clk(clk_1), 
		.signal(evr_trigger),
		.out(trigger_signal)
	);

	positive_edge_detector detector1 (
		.clk(clk),
		.signal(clk_1),
		.out(load_register)
	);
	
	crc8_encoder encoder0 (
		.clk(clk_1),
		.reset(reset),
		.data_in(tx_byte),
		.data_out(encoder_out)
	);
	
	shift_register reg0 (
		.clk(clk_10),
		.load(load_register),
		.data_in(encoder_out),
		.data_out(psc_output)
	);

	data_rom rom0 (
		.address(tx_counter),
		.is_trigger(is_trigger),
		.data(tx_byte)
	);
	
	trigger_fsm fsm0 (
		.clk(clk_1),
		.reset(reset),
		.trigger_pulse(trigger_signal),
		.is_trigger(is_trigger),
		.tx_counter(tx_counter)
	);

endmodule


