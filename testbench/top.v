
`timescale 1 ns / 1 ns

module top;

	reg  clk = 1'b1;
	reg  reset = 1'b1;
	reg  evr_trigger = 1'b1;
	wire tx_output;
	wire trigger_out;
	wire clk_10;
	
	psc_trigger trigger0 (
		.clk(clk),
		.reset(reset),
		.evr_trigger(evr_trigger),
		.psc_output(tx_output),
		.trigger_out(trigger_out),
		.clk_10_logic(clk_10)
	);
	
	`ifdef __SIM__
	always @(clk) #5 clk <= ~clk;
	`else
	always @(clk) #10 clk <= ~clk;
	`endif
	
	initial fork
		#3000 reset = 1'b0;
		#4000 reset = 1'b1;
		
		#15000 evr_trigger = 1'b0;
		#21000 evr_trigger = 1'b1;
		
		#150000 evr_trigger = 1'b0;
		#156000 evr_trigger = 1'b1;
	join
	
	initial #300000 $stop;

endmodule
