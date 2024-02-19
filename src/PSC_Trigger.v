
module PSC_Trigger
(
	input  wire clk,
	input  wire reset,
	input  wire evr_trigger,
	output wire psc_output,
	output wire tx_done,
	output wire pll_clock
);

	parameter state_load_idle = 3'b001;
	parameter state_load_trigger   = 3'b011;
	parameter state_tx_wait   = 3'b110;
	parameter WIDTH = 100;
	
	reg  [2:0]  state = state_load_idle;
	reg  [2:0]  next_state;
	reg  [WIDTH - 1:0] trigger_packet = 100'hFF00FF00FF00FF00FF00FF00F;
	reg  [WIDTH - 1:0] idle_packet    = 100'hC0C0C0C0C0C0C0C0C0C0C0C0C;
	reg  [7:0]  tx_counter = 8'b0;

	reg  trigger_bit;
	reg  idle_bit;
	// wire tx_done;
	wire pll_locked;

	wire trigger_signal;

	// wire pll_clock;
	altpll_50_10 pll_0 ( .inclk0(clk), .c0(pll_clock), .locked(pll_locked) );
	
	positive_edge_detector detector0 (
		.clk(pll_clock), 
		.signal(evr_trigger),
		.out(trigger_signal)
	);

	always @(posedge pll_clock or negedge reset) begin
		if(~reset) begin
			state      <= state_load_idle;
			tx_counter <= 8'd0;
		end
		else begin
			tx_counter  <= (tx_counter == 8'd99) ? 8'd0 : tx_counter + 8'b1;
			state       <= next_state;
			idle_bit    <= idle_packet[WIDTH - tx_counter - 1];
			trigger_bit <= trigger_packet[WIDTH - tx_counter - 1];
			
//			if (evr_trigger == 1'b0) begin
//				trigger_signal <= 1'b1;
//			end
//			
//			if (trigger_signal == 1'b1)
//				trigger_signal <= 1'b0;
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

	assign psc_output = (state == state_load_trigger ? trigger_bit : idle_bit);
	assign tx_done = (tx_counter == 8'd0) ? 1'b1 : 1'b0;

endmodule


