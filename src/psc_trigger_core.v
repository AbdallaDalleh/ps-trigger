//
// Top-level module.
//
module psc_trigger
(
	input  wire clk,
	input  wire reset,
	input  wire evr_trigger,
	output wire psc_output,
	output wire clk_10_logic,
	output wire load_register
);

	// wire       load_register;
	wire [7:0] tx_byte;
	wire [9:0] encoder_out;
	wire       trigger_signal;
	wire       clk_10;
	wire       clk_1;
	wire       is_trigger;
	wire       status_byte_done;
	wire       is_control_byte;
	wire       is_crc_byte;
	wire       crc_reset;
	
	`ifdef __SIM__
	
	ClockDivider #(.FACTOR(1))  div_2   (.clk_in(clk), .clk_out(clk_50));
	ClockDivider #(.FACTOR(5))  div_10  (.clk_in(clk), .clk_out(clk_10));
	ClockDivider #(.FACTOR(50)) div_100 (.clk_in(clk), .clk_out(clk_1));
	
	`else

	wire clk_50;
	assign clk_50 = clk;
	altpll_50_10 pll_0 (.inclk0(clk), .c0(clk_10), .c1(clk_1) );

	`endif
	
//	wire reset_signal;
//	psc_logic_clock clock_logic (
//		.clk_in(clk_10),
//		.reset(reset_signal),
//		.clk_out(clk_10_logic)
//	);
	assign clk_10_logic = clk_10;

//	psc_trigger_rising_edge detector_neg (
//		.clk(clk_10),
//		.signal(reset),
//		.out(reset_signal)
//	);
	
	reg evr_trigger_neg;
	always @(posedge clk_1)
		evr_trigger_neg <= ~evr_trigger;
		
	RisingEdgeDetector detector0 (
		.clk(clk_1), 
		.signal(evr_trigger_neg),
		.out(trigger_signal)
	);

	RisingEdgeDetector detector1 (
		.clk(clk_50),
		.signal(clk_1),
		.out(load_register)
	);
	
	FrameEncoder encoder0 (
	
		// Inputs
		.clk(clk_1),
		.reset(reset),
		.data_in(tx_byte),
		.data_out(encoder_out),
		.is_control_byte(is_control_byte),
		.is_crc_byte(is_crc_byte),
		
		// Outputs
		.crc_reset(crc_reset)
	);
	
	ShiftRegister reg0 (
		.clk(clk_10),
		.load(load_register),
		.data_in(encoder_out),
		.data_out(psc_output)
	);

	TriggerController fsm0 (
	
		// Inputs
		.clk(clk_1),
		.reset(reset),
		.trigger_pulse(trigger_signal),
		
		// Outputs
		.data(tx_byte),
		.is_control_byte(is_control_byte),
		.is_crc_byte(is_crc_byte),
		.crc_reset(crc_reset)
	);

endmodule


