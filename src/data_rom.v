
module data_rom (

	input  wire [3:0] address,
	input  wire       is_trigger,
	output reg  [7:0] data

);

	parameter SOP = 8'b001_11100;
	parameter EOP = 8'b101_11100;

	reg [7:0] rom [0:9];
	
	always @(*) begin
		case (address)
			4'b0000: data <= SOP;
			4'b0001: data <= 8'h00;
			4'b0010: data <= (is_trigger ? 8'h70 : 8'h40);
			4'b0011: data <= 8'h00;
			4'b0100: data <= 8'h0;
			4'b0101: data <= 8'h0;
			4'b0110: data <= 8'h0;
			4'b0111: data <= 8'h0;
			4'b1000: data <= 8'h0;
			4'b1001: data <= EOP;
			
			default: data <= 8'bxxxx_xxxx;
		endcase
	end

endmodule