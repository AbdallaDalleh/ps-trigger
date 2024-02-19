vlog -vlog01compat -work work +incdir+D:/FPGA/PSC_Trigger {D:/FPGA/PSC_Trigger/top.v}

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

add wave reset
add wave clk
add wave trigger0.pll_clock
add wave trigger0.pll_locked
# add wave trigger0.counter
add wave trigger0.tx_counter
add wave tx_output
add wave trigger0.tx_done
add wave evr_trigger
add wave trigger0.tx_trigger_packet[7:0]
add wave trigger0.tx_idle_packet[7:0]
run -all
