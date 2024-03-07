
module data_rom (

	input  wire [3:0] address,
	input  wire       is_trigger,
	output reg  [7:0] data

);

	parameter SOP = 8'b001_11100;
	parameter EOP = 8'b101_11100;
	
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

//	reg [7:0] trigger_packet [0:9];
//	reg [7:0] idle_packet    [0:9];
//	initial begin
//		trigger_packet[0] = SOP;
//		trigger_packet[1] = 8'h00; // Status
//		trigger_packet[2] = 8'h70; // Address 0
//		trigger_packet[3] = 8'h00; // Address 1
//		trigger_packet[4] = 8'h0;  // Data
//		trigger_packet[5] = 8'h0;  // Data
//		trigger_packet[6] = 8'h0;  // Data
//		trigger_packet[7] = 8'h0;  // Data
//		trigger_packet[8] = 8'h0;  // CRC
//		trigger_packet[9] = EOP;
//
//		idle_packet[0] = SOP;
//		idle_packet[1] = 8'h00; // Status
//		idle_packet[2] = 8'h40; // Address 0
//		idle_packet[3] = 8'h00; // Address 1
//		idle_packet[4] = 8'h0;  // Data
//		idle_packet[5] = 8'h0;  // Data
//		idle_packet[6] = 8'h0;  // Data
//		idle_packet[7] = 8'h0;  // Data
//		idle_packet[8] = 8'h0;  // CRC
//		idle_packet[9] = EOP;
//	end