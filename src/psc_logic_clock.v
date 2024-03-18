module psc_logic_clock (
	input  wire clk_in,
	input  wire reset,
	output wire clk_out
);

	reg is_reset = 1'b0;
	
	assign clk_out = clk_in & is_reset;
	always @(posedge reset) begin
		if (reset)
			is_reset <= 1'b1;
	end

endmodule