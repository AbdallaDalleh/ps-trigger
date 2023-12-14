module Shift_register_p_s #(parameter WIDTH = 100)
(
	input  wire clk,
	input  wire load,
	input  wire [WIDTH - 1:0] data_in,
	output wire data_out,
	output wire done
);

	reg [WIDTH - 1:0] data;
	reg [7:0] counter = 8'b0;
	
	assign done     = (counter == 8'd99);
	assign data_out = data[0];
	
	always @(posedge clk) begin
		if(load) begin
			data    <= data_in;
			counter <= 8'b0;
		end
		else begin
			data     <= {data[0], data[WIDTH - 1:1]};
			counter  <= counter + 8'b1;
		end
	end

endmodule