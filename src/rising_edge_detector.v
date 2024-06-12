
//
// A module to detect the arrival of a rising edge of the input signal.
//
module RisingEdgeDetector (
	
	input  clk,
	input  signal,
	output out
	
);
	
	reg signal_delay;
	
	always @(posedge clk)
		signal_delay <= signal;
	
	assign out = signal & ~signal_delay;

endmodule
