
module PSC_Trigger
(

	input  wire clk,
	input  wire reset,
	input  wire evr_trigger,
	output wire psc_output,
	output wire pll_clock
);

	reg  [2:0]  state;
	reg  [2:0]  next_state;
	reg  [99:0] tx_trigger_packet = 100'h6666666666666666666666666;
	reg  [99:0] tx_idle_packet    = 100'h5555555555555555555555555;
	reg  [3:0]  counter = 4'hF;
	reg  [7:0]  tx_counter = 8'b0;
	reg         div_clock = 1'b1;
	
	wire [99:0] tx_packet;
	wire        load;
	// wire        pll_clock;
	wire        tx_done;

	// parameter state_idle      = 3'b000;
	// parameter state_tx        = 3'b010;
	parameter state_load_idle = 3'b001;
	parameter state_load_tx   = 3'b011;
	parameter state_tx_wait   = 3'b110;
	parameter WIDTH = 100;

	altpll_50_10 pll_0 ( .inclk0(clk), .c0(pll_clock) );
//	assign pll_clock = div_clock;
//	always @(posedge clk) begin
//		counter <= counter + 4'b0001;
//		if(counter == 4'b0010) begin
//			counter   <= 4'b0;
//			div_clock <= ~div_clock;
//		end
//	end
	
	always @(posedge pll_clock) begin
		
		tx_idle_packet    <= {tx_idle_packet[0], tx_idle_packet[WIDTH - 1:1]};
		tx_trigger_packet <= {tx_trigger_packet[0], tx_trigger_packet[WIDTH - 1:1]};
		tx_counter        <= tx_counter + 8'b1;
		if(tx_counter == 8'd99)
			tx_counter <= 8'd0;

	end
		
	always @(posedge pll_clock or negedge reset) begin
		if(~reset)
			state <= state_load_idle;
		else
			state <= next_state;
		
	end
	
	always @(state, evr_trigger, tx_done) begin
		case(state)
			state_load_idle:
				if(evr_trigger)
					next_state <= state_tx_wait;
				else
					next_state <= state_load_idle;
					
			state_tx_wait:
				if(tx_done)
					next_state <= state_load_tx;
				else
					next_state <= state_tx_wait;
			
			state_load_tx:
				if(tx_done)
					next_state <= state_load_idle;
				else
					next_state <= state_load_tx;
					
			default:
				next_state <= state_load_idle;
			
		endcase
	end
	
	assign tx_done = tx_counter == 8'd99;
	assign psc_output = (state == state_load_tx ? tx_trigger_packet[0] : tx_idle_packet[0]);
	
//	Shift_register_p_s reg0 (
//		.clk(pll_clock),
//		.load(load),
//		.data_in(tx_packet),
//		.data_out(psc_output),
//		.done(tx_done)
//	);

//	always @(posedge pll_clock or negedge reset) begin
//		if(~reset)
//			state <= state_load_idle;
//		else
//			state <= next_state;
//	end
//
//	always @(state, evr_trigger, tx_done) begin
//		case (state)
//			state_load_idle: next_state <= state_idle;
//
//			state_idle:
//				if(evr_trigger)
//					next_state <= state_tx_wait;
//				else
//					next_state <= state_idle;
//			
//			state_tx_wait:
//				if(tx_done)
//					next_state <= state_load_tx;
//				else
//					next_state <= state_tx_wait;
//			
//			state_load_tx: next_state <= state_tx;
//
//			state_tx:
//				if(tx_done)
//					next_state <= state_load_idle;
//				else
//					next_state <= state_tx;
//		endcase
//	end
//
//	assign load = state == state_load_tx || state == state_load_idle;
//	assign tx_packet = 
//		(state == state_load_idle) || 
//		(state == state_idle) ? tx_idle_packet : tx_trigger_packet;

endmodule
