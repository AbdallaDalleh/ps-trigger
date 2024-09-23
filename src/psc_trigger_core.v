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
	output wire trigger_out
);

	wire       load_register;
	wire [7:0] tx_byte;
	wire [9:0] encoder_out;
	wire       trigger_signal;
    wire       reset_signal;
    wire       clk_50;
	wire       clk_10;
	wire       clk_1;
	wire       is_control_byte;
	wire       is_crc_byte;
	wire       crc_reset;

    reg        evr_trigger_neg;
    
	assign clk_50      = clk;
    assign trigger_out = evr_trigger;
    
	altpll_50_10 pll_0 (
        .inclk0(clk),
        .c0(clk_10),
        .c1(clk_1)
    );

	psc_logic_clock clock_logic (
		.clk_in(clk_10),
		.reset(reset_signal),
		.clk_out(clk_10_logic)
	);
	RisingEdgeDetector detector_neg (
		.clk(clk_10),
		.signal(reset),
		.out(reset_signal)
	);
		
	RisingEdgeDetector detector0 (
		.clk(clk_1), 
		.signal(~evr_trigger),
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


