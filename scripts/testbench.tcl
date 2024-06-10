vlog -vlog01compat \
	 -work work \
	 +incdir+C:/psc-trigger/src \
	 {C:/psc-trigger/src/clock_divider.v}

vlog -vlog01compat \
	 -work work \
	 +define+__SIM__ \
	 +incdir+C:/psc-trigger/src \
	 {C:/psc-trigger/src/psc_trigger_core.v}

vlog -vlog01compat \
	 -work work \
	 +incdir+C:/psc-trigger \
	 +define+__SIM__ \
	 {C:/psc-trigger/src/top.v} \

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
add wave trigger0.clk_1
add wave reset
add wave trigger0.tx_byte
add wave trigger0.trigger_signal
add wave trigger0.encoder0.crc_byte
add wave trigger0.encoder_out
add wave tx_output
add wave trigger0.clk_10

run -all

# add wave trigger0.clk_10_logic
# add wave trigger0.reset_signal
# add wave trigger0.load_register
# add wave trigger0.rom0.data
# add wave trigger0.tx_byte
# add wave trigger0.reg0.data
# add wave trigger0.encoder0.encoder0.datain
# add wave trigger0.reg0.data_in
# add wave clk
# add wave trigger0.tx_done
# add wave trigger0.tx_counter
# add wave trigger0.encoder0.KI
# add wave trigger0.tx_counter
# add wave trigger0.encoder0.crc_stream0.counter
# add wave trigger0.encoder0.crc_stream0.is_crc_byte
# add wave trigger0.encoder0.crc_stream0.crc_reset