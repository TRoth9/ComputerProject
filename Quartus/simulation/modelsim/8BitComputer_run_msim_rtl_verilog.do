transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/tom/Documents/8bit\ Computer/Quartus {/home/tom/Documents/8bit Computer/Quartus/MemAddReg.v}
vlog -vlog01compat -work work +incdir+/home/tom/Documents/8bit\ Computer/Quartus {/home/tom/Documents/8bit Computer/Quartus/ProgramCounter.v}
vlog -vlog01compat -work work +incdir+/home/tom/Documents/8bit\ Computer/Quartus {/home/tom/Documents/8bit Computer/Quartus/Accumulator.v}
vlog -vlog01compat -work work +incdir+/home/tom/Documents/8bit\ Computer/Quartus {/home/tom/Documents/8bit Computer/Quartus/AddSubtract.v}
vlog -vlog01compat -work work +incdir+/home/tom/Documents/8bit\ Computer/Quartus {/home/tom/Documents/8bit Computer/Quartus/BUS.v}
vlog -vlog01compat -work work +incdir+/home/tom/Documents/8bit\ Computer/Quartus {/home/tom/Documents/8bit Computer/Quartus/BRegister.v}
vlog -vlog01compat -work work +incdir+/home/tom/Documents/8bit\ Computer/Quartus {/home/tom/Documents/8bit Computer/Quartus/EEPROM.v}
vlog -sv -work work +incdir+/home/tom/Documents/8bit\ Computer/Quartus {/home/tom/Documents/8bit Computer/Quartus/main.sv}

vlog -vlog01compat -work work +incdir+/home/tom/Documents/8bit\ Computer/Quartus/testbenches {/home/tom/Documents/8bit Computer/Quartus/testbenches/EEPROM_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  EEPROM_tb

add wave *
view structure
view signals
run -all
