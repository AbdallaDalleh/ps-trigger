vlog -vlog01compat -work work +incdir+D:/FPGA/PSC_Trigger {D:/FPGA/PSC_Trigger/src/top.v}

vsim -t 1ns \
	 -L altera_ver \
	 -L lpm_ver \
	 -L sgate_ver \
	 -L altera_mf_ver \
	 -L altera_lnsim_ver \
	 -L cycloneive_ver \
	 -L rtl_work -L work \
	 -voptargs="+acc" \
	 top

# add wave clk
add wave reset
add wave evr_trigger
add wave trigger0.trigger_signal
# add wave trigger0.clk_10
# add wave trigger0.clk_1
add wave trigger0.tx_byte
# add wave trigger0.encoder0.crc_stream0.crc8_0.crc_o
add wave trigger0.encoder0.crc_stream0.crc_o
add wave trigger0.encoder_out
add wave trigger0.tx_done
add wave trigger0.tx_counter
# add wave trigger0.encoder0.KI
# add wave trigger0.tx_counter
# add wave trigger0.encoder0.crc_stream0.counter
# add wave trigger0.encoder0.crc_stream0.is_crc_byte
# add wave trigger0.encoder0.crc_stream0.crc_reset
run -all
