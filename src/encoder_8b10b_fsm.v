module encoder_8b10b_fsm (

	input  wire clk,
	input  wire reset,
	input  wire next_rd,
	output wire current_rd
	
);

	parameter state_rd_negative = 1'b0;
	parameter state_rd_positive = 1'b1;
	parameter rd_same = 1'b0;
	parameter rd_flip = 1'b1;

	reg state;
	reg next_state;

	always @(posedge clk or posedge reset) begin
		if(reset)
			state <= state_rd_negative;
		else
			state <= next_state;
	end
	
	always @(state, next_rd) begin
		case (state)
			state_rd_negative:
				next_state <= (next_rd == rd_same) ? state_rd_negative : state_rd_positive;
			
			state_rd_positive:
				next_state <= (next_rd == rd_same) ? state_rd_positive : state_rd_negative;
		endcase
	end
	
	assign current_rd = state;

endmodule