
`timescale 1 ns / 1 ns

module top;

	reg  clk = 1'b1;
	reg  reset = 1'b0;
	reg  evr_trigger = 1'b0;
	wire tx_output;
	wire pll_clock;
	
	PSC_Trigger trigger0 (
		.clk(clk),
		.reset(reset),
		.evr_trigger(evr_trigger),
		.psc_output(tx_output)
	);
	
	always @(clk) #10 clk <= ~clk;
	
	initial fork
		#300 reset = 1'b1;
		#1020 reset = 1'b0;
//		#13080 evr_trigger = 1'b1;
//		#13100 evr_trigger = 1'b0;
	join
	
	initial #20000 $stop;

endmodule