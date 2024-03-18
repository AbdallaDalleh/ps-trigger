
module psc_trigger
(
	input  wire clk,
	input  wire reset,
	input  wire evr_trigger,
	output wire psc_output,
	output wire clk_10_logic,
	output wire load_register
);

	wire [3:0] tx_counter;
	wire [7:0] tx_byte;
	wire [9:0] encoder_out;
	wire       trigger_signal;
	wire       clk_10;
	wire       clk_1;
	// wire       load_register;
	wire       is_trigger;
	
	`ifdef X
	
	psc_trigger_clock_divider #(.FACTOR(1)) div_2 (
		.clk_in(clk),
		.clk_out(clk_50)
	);
	psc_trigger_clock_divider #(.FACTOR(5)) div_10 (
		.clk_in(clk),
		.clk_out(clk_10)
	);
	psc_trigger_clock_divider #(.FACTOR(50)) div_100 (
		.clk_in(clk),
		.clk_out(clk_1)
	);
	
	`else

	wire clk_50;
	assign clk_50 = clk;
	altpll_50_10 pll_0 (.inclk0(clk), .c0(clk_10) );
	altpll_50_1  pll_1 (.inclk0(clk), .c0(clk_1) );

	`endif
	
	wire reset_signal;
	psc_logic_clock clock_logic (
		.clk_in(clk_10),
		.reset(reset_signal),
		.clk_out(clk_10_logic)
	);

	psc_trigger_rising_edge detector_neg (
		.clk(clk_10),
		.signal(reset),
		.out(reset_signal)
	);

	psc_trigger_rising_edge detector0 (
		.clk(clk_1), 
		.signal(evr_trigger),
		.out(trigger_signal)
	);

	psc_trigger_rising_edge detector1 (
		.clk(clk_50),
		.signal(clk_1),
		.out(load_register)
	);
	
	crc8_encoder encoder0 (
		.clk(clk_1),
		.reset(reset),
		.data_in(tx_byte),
		.data_out(encoder_out)
	);
	
	psc_trigger_shift_register reg0 (
		.clk(clk_10),
		.load(load_register),
		.data_in(encoder_out),
		.data_out(psc_output)
	);

	psc_trigger_data_rom rom0 (
		.address(tx_counter),
		.is_trigger(is_trigger),
		.data(tx_byte)
	);
	
	psc_trigger_fsm fsm0 (
		.clk(clk_1),
		.reset(reset),
		.trigger_pulse(trigger_signal),
		.is_trigger(is_trigger),
		.tx_counter(tx_counter)
	);

endmodule


