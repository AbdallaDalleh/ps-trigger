
module PSC_Trigger
(
	input  wire clk,
	input  wire reset,
	input  wire evr_trigger,
	output wire psc_output
);

	parameter WIDTH = 100;
	parameter SOP   = 8'b001_11100;
	parameter EOP   = 8'b101_11100;
	parameter state_load_idle    = 3'b001;
	parameter state_load_trigger = 3'b011;
	parameter state_tx_wait      = 3'b110;

	reg [2:0]  state = state_load_idle;
	reg [2:0]  next_state;
	reg [7:0]  tx_counter = 8'b0;

//	reg [7:0]  trigger_packet_status;
//	reg [7:0]  trigger_packet_address_1;
//	reg [7:0]  trigger_packet_address_0;
//	reg [31:0] trigger_packet_data;
//	reg [7:0]  trigger_packet_crc;
//
//	reg [7:0]  idle_packet_status;
//	reg [7:0]  idle_packet_address_1;
//	reg [7:0]  idle_packet_address_0;
//	reg [31:0] idle_packet_data;
//	reg [7:0]  idle_packet_crc;

//	wire [79:0] w_trigger_packet;
//	wire [79:0] w_idle_packet;

	reg [7:0] trigger_packet [0:9];
	reg [7:0] idle_packet [0:9];
	
	initial begin
		trigger_packet[0] = SOP;
		trigger_packet[1] = 8'h00;   // Status
		trigger_packet[2] = 8'h70;   // Address 0
		trigger_packet[3] = 8'h00;   // Address 1
		trigger_packet[4] = 8'h0; // Data
		trigger_packet[5] = 8'h0; // Data
		trigger_packet[6] = 8'h0; // Data
		trigger_packet[7] = 8'h0; // Data
		trigger_packet[8] = 8'h0;    // CRC
		trigger_packet[9] = EOP;
		
		idle_packet[0] = SOP;
		idle_packet[1] = 8'h00;   // Status
		idle_packet[2] = 8'h40;   // Address 0
		idle_packet[3] = 8'h00;   // Address 1
		idle_packet[4] = 8'h0; // Data
		idle_packet[5] = 8'h0; // Data
		idle_packet[6] = 8'h0; // Data
		idle_packet[7] = 8'h0; // Data
		idle_packet[8] = 8'h0;    // CRC
		idle_packet[9] = EOP;
	end
	
	//reg  [99:0] trigger_packet_enc = 100'hFF00FF00FF00FF00FF00FF00F;
	//reg  [99:0] idle_packet_enc    = 100'hC0C0C0C0C0C0C0C0C0C0C0C0C;

	reg  [7:0] idle_byte;
	reg  [7:0] trigger_byte;
	wire [7:0] tx_byte;
	wire [9:0] encoder_out;
	reg [9:0] encoder_value;
	wire trigger_signal;

	wire clk_10;
	wire clk_1;
	wire tx_done;
	
	altpll_50_10 pll_0 (
		.inclk0(clk),
		.c0(clk_10),
		.c1(clk_1)
	);
	
	positive_edge_detector detector0 (
		.clk(clk_1), 
		.signal(evr_trigger),
		.out(trigger_signal)
	);

	always @(posedge clk_1 or posedge reset) begin
		if(reset) begin
			state      <= state_load_idle;
			tx_counter <= 8'd0;
		end
		else begin
			tx_counter   <= (tx_counter == 8'd10) ? 8'd0 : tx_counter + 8'd1;
			state        <= next_state;
			idle_byte    <= idle_packet[tx_counter];
			trigger_byte <= trigger_packet[tx_counter];
		end
	end

	always @(state, trigger_signal, tx_done) begin
		case(state)
			state_load_idle:
				if(trigger_signal)
					next_state <= state_tx_wait;
				else
					next_state <= state_load_idle;
					
			state_tx_wait:
				if(tx_done)
					next_state <= state_load_trigger;
				else
					next_state <= state_tx_wait;
			
			state_load_trigger:
				if(tx_done)
					next_state <= state_load_idle;
				else
					next_state <= state_load_trigger;
					
			default:
				next_state <= state_load_idle;
			
		endcase
	end

	assign tx_byte = (state == state_load_trigger ? trigger_byte : idle_byte);
	assign tx_done = (tx_counter == 8'd0) ? 1'b1 : 1'b0;
	
	crc8_encoder encoder0 (
		.clk(clk_1),
		.reset(reset),
		.data_in(tx_byte),
		.data_out(encoder_out)
	);
	
	shift_register reg0 (
		.clk(clk_10),
		.load(tx_done),
		.data_in(encoder_out),
		.data_out(psc_output)
	);

endmodule


