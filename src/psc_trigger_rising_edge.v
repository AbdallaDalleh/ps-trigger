module psc_trigger_rising_edge (
	
	input  clk,
	input  signal,
	output out
	
);
	
	reg signal_delay;
	
	always @(posedge clk)
		signal_delay <= signal;
	
	assign out = signal & ~signal_delay;

endmodule
