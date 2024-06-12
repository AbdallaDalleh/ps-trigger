//
// This module controls which frame to send (idle or trigger frame) based
// on the value of the input trigger_pulse.
// 
//  trigger_pulse = 0 => Idle.
//  trigger_pulse = 1 => Trigger.
//
// It also outputs control signals to the encoder to detect control and CRC
// bytes as well as resetting the CRC8 generator.
//
module TriggerController (

	input  wire       clk,
	input  wire       reset,
	input  wire       trigger_pulse,
	output wire [7:0] data,
    output wire       is_control_byte,
	output wire       is_crc_byte,
	output wire       crc_reset

);

	// Local constants
	localparam state_load_idle    = 3'b001;
	localparam state_load_trigger = 3'b011;
	localparam state_tx_wait      = 3'b110;
    localparam SOP                = 8'h3C;
	localparam EOP                = 8'hBC;
	localparam FRAME_LENGTH       = 4'd9;

	// FSM and ROM Registers
	reg [2:0] state = state_load_idle;
	reg [2:0] next_state;
	reg [7:0] status_byte_counter;
	reg [7:0] rom_byte;
	reg [3:0] tx_counter;

	// Wires
	wire tx_done;
	wire status_byte_done;
	wire is_trigger;

	// Frame Data ROM
    always @(*) begin
        case (tx_counter)
			4'b0000: rom_byte <= SOP;

			// Status byte
			4'b0001: rom_byte <= (is_trigger ? status_byte_counter : 8'h00);

			4'b0010: rom_byte <= (is_trigger ? 8'h30 : 8'h00); // Control byte (Address 1)
			4'b0011: rom_byte <= 8'h00; // Address 0
			4'b0100: rom_byte <= 8'h00; // uint32_t data
			4'b0101: rom_byte <= 8'h00;
			4'b0110: rom_byte <= 8'h00;
			4'b0111: rom_byte <= 8'h00;
			4'b1000: rom_byte <= 8'h00; // CRC8 placeholder
			4'b1001: rom_byte <= EOP;

			default: rom_byte <= 8'bxxxx_xxxx;
		endcase
    end

	// FSM control signals.
	assign status_byte_done = (status_byte_counter == 8'hff);
	assign is_trigger       = (state == state_load_trigger);
	assign tx_done          = (tx_counter == FRAME_LENGTH);

	// Output control.
    assign data             = rom_byte;
	assign is_control_byte  = (tx_counter == 4'h0 || tx_counter == 4'b1001);
	assign is_crc_byte      = (tx_counter == 4'h8);
	assign crc_reset        = (tx_counter == 4'h0);
	
	// Asynchronous counter to iterate over the status byte.
	always @(posedge clk or posedge trigger_pulse) begin
		if (trigger_pulse)
			status_byte_counter <= 8'h0;
		else begin
			if (tx_counter == 4'b0000)
				status_byte_counter <= status_byte_counter + 8'h1;
		end
	end
	
	// Main FSM logic
	always @(posedge clk or negedge reset) begin
		if(~reset) begin
			state      <= state_load_idle;
			tx_counter <= 4'd0;
		end
		else begin
			tx_counter <= (tx_counter == FRAME_LENGTH) ? 4'd0 : tx_counter + 4'd1;
			state      <= next_state;
		end
	end

	always @(state, trigger_pulse, tx_done, status_byte_done) begin
		case(state)
			state_load_idle:
				if(trigger_pulse)
					next_state <= state_tx_wait;
				else
					next_state <= state_load_idle;

			state_tx_wait:
				if(tx_done)
					next_state <= state_load_trigger;
				else
					next_state <= state_tx_wait;

			state_load_trigger:
				if(tx_done && status_byte_done == 1'b1)
					next_state <= state_load_idle;
				else
					next_state <= state_load_trigger;
					
			default:
				next_state <= state_load_idle;
			
		endcase
	end

endmodule
