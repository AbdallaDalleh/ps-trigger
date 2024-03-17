module psc_logic_clock (
	input  wire clk_in,
	input  wire reset,
	output wire clk_out
);

	reg is_reset = 1'b0;
	reg clk      = 1'b0;
	
	assign clk_out = clk;
	always @(clk_in or reset) begin
		if (reset)
			is_reset <= 1'b1;
		else begin
			if (is_reset)
				clk <= clk_in;
			else
				clk <= 1'b0;
		end
	end

endmodule