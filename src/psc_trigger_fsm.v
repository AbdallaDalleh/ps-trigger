
module psc_trigger_fsm (

	input  wire       clk,
	input  wire       reset,
	input  wire       trigger_pulse,
	output wire       is_trigger,
	output reg  [3:0] tx_counter

);

	parameter state_load_idle    = 3'b001;
	parameter state_load_trigger = 3'b011;
	parameter state_tx_wait      = 3'b110;
	
	localparam TX_BYTE_COUNT = 4'd10;
	
	reg  [2:0] state = state_load_idle;
	reg  [2:0] next_state;
	wire       tx_done;  

	assign is_trigger = (state == state_load_trigger);
	assign tx_done    = (tx_counter == TX_BYTE_COUNT) ? 1'b1 : 1'b0;

	always @(posedge clk or negedge reset) begin
		if(~reset) begin
			state      <= state_load_idle;
			tx_counter <= 4'd0;
		end
		else begin
			tx_counter <= (tx_counter == TX_BYTE_COUNT) ? 4'd0 : tx_counter + 4'd1;
			state      <= next_state;
		end
	end

	always @(state, trigger_pulse, tx_done) begin
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
				if(tx_done)
					next_state <= state_load_idle;
				else
					next_state <= state_load_trigger;
					
			default:
				next_state <= state_load_idle;
			
		endcase
	end

endmodule
