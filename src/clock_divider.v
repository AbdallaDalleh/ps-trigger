
//
// A clock divder to simulate the PLL divider function.
//
module ClockDivider #(
	parameter FACTOR = 8'b0000_0101
)(
	input  wire clk_in,
	output wire clk_out
);

	reg       clk = 1'b1;
	reg [7:0] counter = 8'b0;
	
	assign clk_out = clk;
	always @(posedge clk_in) begin
		counter <= counter + 8'b1;
		if (counter == FACTOR) begin
			counter <= 8'b1;
			clk <= ~clk;
		end
	end

endmodule