restart -f
transcript on
if ![file isdirectory vhdl_libs] {
	file mkdir vhdl_libs
}


#set path_to_quartus d:/quartus

# where is the "AUA" dir?
#set path_to_calu_svn H:/Documents/uni/calu/svn



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

add wave /aua_tb/clk /aua_tb/reset_pin 
#add wave -divider UI
#add wave /aua_tb/switch_pins /aua_tb/led_pins /aua_tb/digit0_pins /aua_tb/digit1_pins /aua_tb/digit2_pins /aua_tb/digit3_pins /aua_tb/digit4_pins /aua_tb/digit5_pins
#add wave -divider SRAM
#add wave -hex /aua_tb/sram_addr /aua_tb/sram_dq 
#add wave /aua_tb/sram_we /aua_tb/sram_oe /aua_tb/sram_ub /aua_tb/sram_lb /aua_tb/sram_ce

add wave -divider IF
add wave -hex /aua_tb/aua1/cmp_if/pc
add wave -hex /aua_tb/aua1/cmp_if/pc_in
add wave /aua_tb/aua1/cmp_if/branch
add wave -hex /aua_tb/aua1/cmp_if/pc_nxt


add wave -divider IF/MMU
add wave -hex /aua_tb/aua1/cmp_mmu/instr_addr
add wave -hex /aua_tb/aua1/cmp_mmu/instr_data
add wave -hex /aua_tb/aua1/cmp_mmu/cmp_rom/q
add wave /aua_tb/aua1/cmp_mmu/instr_valid

add wave -divider ID
add wave -hex /aua_tb/aua1/cmp_id/opcode
add wave -hex /aua_tb/aua1/cmp_id/pc
add wave -dec /aua_tb/aua1/cmp_id/rega
add wave -dec /aua_tb/aua1/cmp_id/regb
add wave -dec /aua_tb/aua1/cmp_id/imm

add wave -divider EX
add wave -hex /aua_tb/aua1/cmp_ex/opcode
add wave -hex /aua_tb/aua1/cmp_ex/opa
add wave -hex /aua_tb/aua1/cmp_ex/opb
add wave -dec /aua_tb/aua1/cmp_ex/dest


add wave -divider REG-file
add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/altsyncram_component/memory/m_mem_data_a
#add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/altsyncram_component/memory/m_mem_data_b # always X?
add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_b/altsyncram_component/memory/m_mem_data_a
#add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_b/altsyncram_component/memory/m_mem_data_b # always X?


view structure
view signals
run -all
