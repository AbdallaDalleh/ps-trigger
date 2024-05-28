
module psc_trigger_data_rom (

	input  wire       clk,
	input  wire       reset,
	input  wire [3:0] address,
	input  wire       is_trigger_state,
	output reg  [7:0] data,
	output wire       status_byte_done

);

	localparam SOP = 8'h3C;
	localparam EOP = 8'hBC;
	
	reg [7:0] status_byte_counter;
	
	assign status_byte_done = (status_byte_counter == 8'hff);
	
	always @(posedge clk or posedge reset) begin
		if (reset)
			status_byte_counter <= 8'h0;
		else begin
			if (address == 4'b0001)
				status_byte_counter <= status_byte_counter + 8'h1;
		end
	end
	
	always @(*) begin
		case (address)
			4'b0000: data <= SOP;
			
			// Status byte
			// 4'b0001: data <= (is_trigger_state ? 8'h01 : 8'h00);
			4'b0001: data <= (is_trigger_state ? status_byte_counter : 8'h00);
			
			// Control byte (Address 1)
			4'b0010: data <= (is_trigger_state ? 8'h30 : 8'h00);
			
			// Address 0
			4'b0011: data <= 8'h00;
			
			// uint32_t data
			4'b0100: data <= 8'h00;
			4'b0101: data <= 8'h00;
			4'b0110: data <= 8'h00;
			4'b0111: data <= 8'h00;
			
			// CRC8 placeholder
			4'b1000: data <= 8'h00;
			
			4'b1001: data <= EOP;
			
			default: data <= 8'bxxxx_xxxx;
		endcase
	end

endmodule
