`default_nettype none

/*
 * A 256 byte long ROM to hold the CRC table
 */
module crc8_table #(
    parameter POLYNOMIAL=8'h07
) (
    input wire clk_i,
    input wire [7:0] addr_i,
    output wire [7:0] value_o
);
    function [7:0] calculate_table_entry(input [7:0] table_index);
        integer bit_num, actual_polynomial, table_entry;
        begin
            // Add the implied 1 to the beginning of the polynomial
            actual_polynomial = {23'b0, 1'b1, POLYNOMIAL[7:0]};
			
            // Divide table_index by the actual polynomial using polynomial divison
            table_entry = {24'b0, table_index};
			
            for (bit_num = 0; bit_num < 8; bit_num = bit_num + 1) begin
                table_entry = {23'b0, table_entry[7:0], 1'b0};
                if (table_entry[8]) begin
                    table_entry = table_entry ^ actual_polynomial;
                end
            end
            calculate_table_entry = table_entry[7:0];
        end
    endfunction

    // Instantiate a ROM
    reg [7:0] rom [0:255];
    reg [7:0] rom_data_out;
    wire rom_en;
    assign rom_en = 1;
    always @(posedge clk_i) begin
        if (rom_en) begin
            rom_data_out <= rom[addr_i];
        end
    end
    assign value_o = rom_data_out;

    // Fill the ROM with the CRC table for this polynomial
    integer i;
    initial begin
        for (i = 0; i < 256; i = i+1) begin
            // Fill in the table
            rom[i] = calculate_table_entry(i[7:0]);
        end
    end

// If doing formal verification, ensure that the table always holds the expected values, i.e. is read-only. This is
// required for a proof by induciton.
`ifdef FORMAL
    integer f;
    always @(*)
        for (f = 0; f < 256; f = f + 1)
            assert(rom[f] == calculate_table_entry(f));
`endif
endmodule

`default_nettype wire
