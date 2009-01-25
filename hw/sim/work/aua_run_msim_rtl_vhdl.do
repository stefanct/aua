transcript on
if ![file isdirectory vhdl_libs] {
	file mkdir vhdl_libs
}


set path_to_quartus d:/quartus

# where is the "AUA" dir?
set path_to_calu_svn H:/Documents/uni/calu/svn



vlib vhdl_libs/lpm
vmap lpm vhdl_libs/lpm
vcom -93 -work lpm $path_to_quartus/eda/sim_lib/220pack.vhd
vcom -93 -work lpm  $path_to_quartus/eda/sim_lib/220model.vhd

vlib vhdl_libs/altera
vmap altera vhdl_libs/altera
vcom -93 -work altera  $path_to_quartus/eda/sim_lib/altera_primitives_components.vhd
vcom -93 -work altera $path_to_quartus/eda/sim_lib/altera_primitives.vhd

vlib vhdl_libs/altera_mf
vmap altera_mf vhdl_libs/altera_mf
vcom -93 -work altera_mf $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
vcom -93 -work altera_mf $path_to_quartus/eda/sim_lib/altera_mf.vhd

vlib vhdl_libs/sgate
vmap sgate vhdl_libs/sgate
vcom -93 -work sgate $path_to_quartus/eda/sim_lib/sgate_pack.vhd
vcom -93 -work sgate $path_to_quartus/eda/sim_lib/sgate.vhd

vlib vhdl_libs/cycloneii
vmap cycloneii vhdl_libs/cycloneii
vcom -93 -work cycloneii $path_to_quartus/eda/sim_lib/cycloneii_atoms.vhd
vcom -93 -work cycloneii $path_to_quartus/eda/sim_lib/cycloneii_components.vhd

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work $path_to_calu_svn/AUA/hw/src/aua_types.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/io/digits/src/digits.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/mmu/src/rom.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/io/switches/src/switches.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/reg/src/ram.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/caches/src/cache_ent.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/caches/src/cache_null.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/mmu/src/mmu.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/if/src/if.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/reg/src/reg.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/id/src/id.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/ex/src/ex.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/alu/src/alu.vhd
#vcom -93 -work work $path_to_calu_svn/AUA/hw/src/aua_top_ent.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/src/aua_top.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/src/aua_de2_config.vhd

vcom -93 -work work $path_to_calu_svn/AUA/hw/project/../sim/tb.vhd

vsim -t 1ps -L lpm -L altera -L altera_mf -L sgate -L cycloneii -L rtl_work -L work -voptargs="+acc" aua_tb

add wave sim:/aua_tb/clk sim:/aua_tb/reset_pin sim:/aua_tb/switch_pins sim:/aua_tb/led_pins sim:/aua_tb/digit0_pins sim:/aua_tb/digit1_pins sim:/aua_tb/digit2_pins sim:/aua_tb/digit3_pins sim:/aua_tb/digit4_pins sim:/aua_tb/digit5_pins
add wave -hex sim:/aua_tb/sram_addr sim:/aua_tb/sram_dq 
add wave sim:/aua_tb/sram_we sim:/aua_tb/sram_oe sim:/aua_tb/sram_ub sim:/aua_tb/sram_lb sim:/aua_tb/sram_ce
add wave -divider IF/MMU
add wave -hex {sim:/aua_tb/aua1/cmp_mmu/instr_addr }
add wave -hex {sim:/aua_tb/aua1/cmp_mmu/instr_data } 
add wave {sim:/aua_tb/aua1/cmp_mmu/instr_valid }
view structure
view signals
run -all
