
//
// A standard 10-bit circular shift register
//
module ShiftRegister (

	input  wire       clk,
	input  wire       load,
	input  wire [9:0] data_in,
	output wire       data_out
);

	reg [9:0] data;
	wire      data_out_ela;

	always @(posedge clk or posedge load) begin
		if (load)
			data <= data_in;
		else
			data <= {data[8:0], data[9]};
	end
	
	assign data_out = ~data[0];
	assign data_out_ela = ~data[0];

endmodule
