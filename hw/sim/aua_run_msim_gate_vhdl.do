#set path_to_quartus d:/quartus
#set path_to_quartus C:/Programme/altera/80sp1/quartus

# where is the "AUA" dir?
#set path_to_calu_svn H:/Documents/uni/calu/svn
#set path_to_calu_svn H:/uni/calu

restart -f
transcript on
if ![file isdirectory vhdl_libs] {
	file mkdir vhdl_libs
}

vlib vhdl_libs/cycloneii
vmap cycloneii ./vhdl_libs/cycloneii
vcom -93 -work cycloneii $path_to_quartus/eda/sim_lib/cycloneii_atoms.vhd
vcom -93 -work cycloneii $path_to_quartus/eda/sim_lib/cycloneii_components.vhd

if {[file exists gate_work]} {
	vdel -lib gate_work -all
}
vlib gate_work
vmap work gate_work

vcom -93 -work work $path_to_calu_svn/AUA/hw/src/aua_types.vhd

vcom -93 -work work $path_to_calu_svn/AUA/hw/sim/work/aua.vho

vcom -93 -work work $path_to_calu_svn/AUA/hw/sim/tb.vhd

vsim -t 1ps +transport_int_delays +transport_path_delays -sdftyp /aua1=aua_vhd.sdo -L cycloneii -L gate_work -L work -voptargs="+acc" aua_tb

#~ add wave *


add wave /aua_tb/clk /aua_tb/reset_pin 
add wave /aua_tb/aua1/\\cmp_if|dest\\
#~ #add wave -divider UI
#~ #add wave /aua_tb/switch_pins /aua_tb/led_pins /aua_tb/digit0_pins /aua_tb/digit1_pins /aua_tb/digit2_pins /aua_tb/digit3_pins /aua_tb/digit4_pins /aua_tb/digit5_pins
#~ #add wave -divider SRAM
#~ #add wave -hex /aua_tb/sram_addr /aua_tb/sram_dq 
#~ #add wave /aua_tb/sram_we /aua_tb/sram_oe /aua_tb/sram_ub /aua_tb/sram_lb /aua_tb/sram_ce
#~ 
#~ add wave -divider IF
#~ add wave -hex /aua_tb/aua1/cmp_if/pc
#~ add wave -hex /aua_tb/aua1/cmp_if/pc_in
#~ add wave /aua_tb/aua1/cmp_if/branch
#~ add wave -hex /aua_tb/aua1/cmp_if/pc_nxt
#~ 
#~ 
#~ add wave -divider IF/MMU
#~ add wave -hex /aua_tb/aua1/cmp_mmu/instr_addr
#~ add wave -hex /aua_tb/aua1/cmp_mmu/instr_data
#~ add wave /aua_tb/aua1/cmp_mmu/instr_valid
#~ 
#~ add wave -divider ID
#~ add wave -hex /aua_tb/aua1/cmp_id/opcode
#~ add wave -hex /aua_tb/aua1/cmp_id/pc
#~ add wave -dec /aua_tb/aua1/cmp_id/rega
#~ add wave -hex /aua_tb/aua1/cmp_id/vala
#~ add wave -dec /aua_tb/aua1/cmp_id/regb
#~ add wave -hex /aua_tb/aua1/cmp_id/valb
#~ add wave -dec /aua_tb/aua1/cmp_id/imm
#~ 
#~ add wave -divider EX
#~ add wave -hex /aua_tb/aua1/cmp_ex/opcode
#~ add wave -hex /aua_tb/aua1/cmp_ex/opa
#~ add wave -hex /aua_tb/aua1/cmp_ex/opb
#~ add wave /aua_tb/aua1/cmp_ex/cmp_alu/carry
#~ add wave -dec /aua_tb/aua1/cmp_ex/dest_out
#~ add wave -hex /aua_tb/aua1/cmp_ex/result_out
#~ 
#~ add wave -divider REG-file
#~ add wave -dec /aua_tb/aua1/cmp_id/cmp_reg/rega
#~ #add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/rdaddress
#~ add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/vala
#~ add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/vala_ram
#~ add wave -dec /aua_tb/aua1/cmp_id/cmp_reg/regb
#~ add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/valb
#~ add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/valb_ram
#~ add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/regr
#~ #add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/wraddress
#~ add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/valr
#~ add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/altsyncram_component/memory/m_mem_data_a(1)
#~ add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/altsyncram_component/memory/m_mem_data_a
#~ add wave -hex /aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_b/altsyncram_component/memory/m_mem_data_a
#~ 
#~ add wave -divider interstages
#~ add wave -dec /aua_tb/aua1/id_rega_in 
#~ add wave -dec /aua_tb/aua1/id_regb_in 
#~ add wave -dec /aua_tb/aua1/exid_dest
#~ add wave -hex /aua_tb/aua1/exid_result
#~ 
#~ 

view structure
view signals
run -all
