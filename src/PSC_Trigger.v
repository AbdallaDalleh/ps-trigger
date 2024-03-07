
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

	reg [2:0] state = state_load_idle;
	reg [2:0] next_state;
	reg [3:0] tx_counter;

	wire [7:0] tx_byte;
	wire [9:0] encoder_out;
	wire       trigger_signal;
	wire       clk_10;
	wire       clk_1;
	wire       tx_done;
	wire       load_register;
	wire       is_trigger;

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

	positive_edge_detector detector1 (
		.clk(clk),
		.signal(clk_1),
		.out(load_register)
	);
	
	crc8_encoder encoder0 (
		.clk(clk_1),
		.reset(reset),
		.data_in(tx_byte),
		.data_out(encoder_out)
	);
	
	shift_register reg0 (
		.clk(clk_10),
		.load(load_register),
		.data_in(encoder_out),
		.data_out(psc_output)
	);

	data_rom rom0 (
		.address(tx_counter),
		.is_trigger(is_trigger),
		.data(tx_byte)
	);

	// wire [7:0] idle_byte;
	// wire [7:0] trigger_byte;
	// assign idle_byte    = idle_packet[tx_counter];
	// assign trigger_byte = trigger_packet[tx_counter];
	// assign tx_byte      = (state == state_load_trigger ? trigger_byte : idle_byte);
	
	assign is_trigger = (state == state_load_trigger);
	assign tx_done    = (tx_counter == 4'd9) ? 1'b1 : 1'b0;
	
	always @(posedge clk_1 or posedge reset) begin
		if(reset) begin
			state      <= state_load_idle;
			tx_counter <= 4'd0;
		end
		else begin
			tx_counter <= (tx_counter == 4'd9) ? 4'd0 : tx_counter + 4'd1;
			state      <= next_state;
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

endmodule


