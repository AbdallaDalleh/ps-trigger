
vlog -vlog01compat \
	 -work work \
	 +incdir+C:/psc-trigger/src \
	 {C:/psc-trigger/src/clock_divider.v}

vlog -vlog01compat \
	 -work work \
	 +define+__SIMX__ \
	 +incdir+C:/psc-trigger/src \
	 {C:/psc-trigger/src/psc_trigger_core.v}
	 
vlog -vlog01compat \
	 -work work \
	 +incdir+C:/psc-trigger \
	 +define+__SIMX__ \
	 {C:/psc-trigger/testbench/top.v} \

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

add wave trigger0.clk_1
add wave reset
add wave trigger0.tx_byte
add wave trigger0.encoder_out
add wave trigger0.encoder_lsb_out
add wave trigger0.trigger_signal
add wave trigger0.psc_output

run -all
