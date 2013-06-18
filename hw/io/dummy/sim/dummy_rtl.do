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

vlib vhdl_libs/lpm
vmap lpm vhdl_libs/lpm
vcom -93 -work lpm $path_to_quartus/eda/sim_lib/220pack.vhd
vcom -93 -work lpm  $path_to_quartus/eda/sim_lib/220model.vhd

vlib vhdl_libs/altera
vmap altera vhdl_libs/altera
vcom -93 -work altera  $path_to_quartus/eda/sim_lib/altera_primitives_components.vhd
vcom -93 -work altera $path_to_quartus/eda/sim_lib/altera_primitives.vhd

#~ vlib vhdl_libs/altera_mf
#~ vmap altera_mf vhdl_libs/altera_mf
#~ vcom -93 -work altera_mf $path_to_quartus/eda/sim_lib/altera_mf_components.vhd
#~ vcom -93 -work altera_mf $path_to_quartus/eda/sim_lib/altera_mf.vhd

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
vcom -93 -work work $path_to_calu_svn/AUA/hw/io/dummy/src/sc_dummy.vhd

vcom -93 -work work $path_to_calu_svn/AUA/hw/io/dummy/sim/dummy_tb.vhd

vsim -t 1ps -L lpm -L altera -L altera_mf -L sgate -L cycloneii -L rtl_work -L work -voptargs="+acc" dummy_tb

add wave -hex	/dummy_tb/sc_test_slave1/sc_base_addr
add wave 		/dummy_tb/sc_test_slave1/clk
add wave 		/dummy_tb/sc_test_slave1/reset
add wave -divider SIMPCON
add wave -hex 	/dummy_tb/sc_test_slave1/address
add wave 		/dummy_tb/sc_test_slave1/rd
add wave -hex	/dummy_tb/sc_test_slave1/wr_data
add wave 		/dummy_tb/sc_test_slave1/wr
add wave -hex	/dummy_tb/sc_test_slave1/rd_data
add wave 		/dummy_tb/sc_test_slave1/rdy_cnt
add wave -divider INTERNAL
add wave -uns	/dummy_tb/sc_test_slave1/cycle_cnt_nxt
add wave -uns	/dummy_tb/sc_test_slave1/cycle_cnt
add wave -uns	/dummy_tb/sc_test_slave1/ready_nxt
add wave -uns	/dummy_tb/sc_test_slave1/ready
add wave -hex	/dummy_tb/sc_test_slave1/reg_nxt
add wave -hex	/dummy_tb/sc_test_slave1/reg
add wave -hex	/dummy_tb/sc_test_slave1/sc_out_nxt
add wave -hex	/dummy_tb/sc_test_slave1/sc_out
add wave 		/dummy_tb/sc_test_slave1/state_nxt
add wave 		/dummy_tb/sc_test_slave1/state

#add wave		/dummy_tb/clk /dummy_tb/aua1/reset 
##add wave -divider UI
##add wave		/dummy_tb/switch_pins /dummy_tb/led_pins /dummy_tb/digit0_pins /dummy_tb/digit1_pins /dummy_tb/digit2_pins /dummy_tb/digit3_pins /dummy_tb/digit4_pins /dummy_tb/digit5_pins
##add wave -divider SRAM
##add wave -hex	/dummy_tb/sram_addr /dummy_tb/sram_dq 
##add wave		/dummy_tb/sram_we /dummy_tb/sram_oe /dummy_tb/sram_ub /dummy_tb/sram_lb /dummy_tb/sram_ce

#add wave -divider IF
#add wave -hex	/dummy_tb/aua1/cmp_if/pc
#add wave -hex	/dummy_tb/aua1/cmp_if/pc_in
#add wave		/dummy_tb/aua1/cmp_if/branch
#add wave -hex	/dummy_tb/aua1/cmp_if/pc_nxt


#add wave -divider IF/MMU
#add wave -hex	/dummy_tb/aua1/cmp_mmu/instr_addr
#add wave -hex	/dummy_tb/aua1/cmp_mmu/instr_data
#add wave		/dummy_tb/aua1/cmp_mmu/instr_valid

#add wave -divider ID
#add wave -hex	/dummy_tb/aua1/cmp_id/opcode_in
#add wave -hex	/dummy_tb/aua1/cmp_id/pc_in
#add wave -dec	/dummy_tb/aua1/cmp_id/rega_in
#add wave -hex	/dummy_tb/aua1/cmp_id/vala
#add wave -dec	/dummy_tb/aua1/cmp_id/regb_in
#add wave -hex	/dummy_tb/aua1/cmp_id/valb
#add wave -dec	/dummy_tb/aua1/cmp_id/imm_in

#add wave -divider EX
#add wave -hex	/dummy_tb/aua1/cmp_ex/opcode
#add wave -hex	/dummy_tb/aua1/cmp_ex/opa
#add wave -hex	/dummy_tb/aua1/cmp_ex/opb
##add wave		/dummy_tb/aua1/cmp_ex/cmp_alu/carry
#add wave -dec	/dummy_tb/aua1/cmp_ex/dest_out
#add wave -hex	/dummy_tb/aua1/cmp_ex/result_out

#add wave -divider REG-file
#add wave -dec	/dummy_tb/aua1/cmp_id/cmp_reg/rega
##add wave -hex	/dummy_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/rdaddress
#add wave -hex	/dummy_tb/aua1/cmp_id/cmp_reg/vala
#add wave -dec	/dummy_tb/aua1/cmp_id/cmp_reg/regb
#add wave -hex	/dummy_tb/aua1/cmp_id/cmp_reg/valb
#add wave -hex	/dummy_tb/aua1/cmp_id/cmp_reg/regr
##add wave -hex	/dummy_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/wraddress
#add wave -hex	/dummy_tb/aua1/cmp_id/cmp_reg/valr
##add wave -hex	/dummy_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/altsyncram_component/memory/m_mem_data_a(1)
#add wave -hex	/dummy_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/altsyncram_component/memory/m_mem_data_a
##add wave -hex	/dummy_tb/aua1/cmp_id/cmp_reg/cmp_ram_b/altsyncram_component/memory/m_mem_data_a

#add wave -divider interstages
#add wave 		/dummy_tb/aua1/ex_locks 
#add wave		/dummy_tb/aua1/cmp_ex/ex_locks_nxt
##add wave -dec	/dummy_tb/aua1/lock_if
##add wave -dec	/dummy_tb/aua1/lock_id

#add wave -divider IO
#add wave -hex	/dummy_tb/aua1/cmp_mmu/ex_address
#add wave -hex	/dummy_tb/aua1/cmp_mmu/ex_wr_data
#add wave		/dummy_tb/aua1/cmp_mmu/ex_enable
#add wave -hex	/dummy_tb/aua1/cmp_mmu/ex_opcode
#add wave -hex	/dummy_tb/aua1/cmp_mmu/sc_addr
#add wave -hex	/dummy_tb/aua1/cmp_mmu/sc_wr_data
#add wave		/dummy_tb/aua1/cmp_mmu/sc_rd
#add wave		/dummy_tb/aua1/cmp_mmu/sc_wr
#add wave -hex	/dummy_tb/aua1/cmp_test/rd_data
#add wave -hex	/dummy_tb/aua1/cmp_test/wr_data
#add wave -hex	/dummy_tb/aua1/cmp_test/rd
#add wave -hex	/dummy_tb/aua1/cmp_mmu/sc_rd_data
#add wave		/dummy_tb/aua1/cmp_ex/mmu_done
#add wave -hex	/dummy_tb/aua1/cmp_mmu/ex_rd_data
#add wave		/dummy_tb/aua1/cmp_mmu/sc_rdy_cnt
#add wave 		/dummy_tb/aua1/cmp_mmu/sc_rd_state
#add wave -hex	/dummy_tb/aua1/mmuio_out.address
#add wave -hex	/dummy_tb/aua1/mmuio_out.wr_data 
#add wave -hex	/dummy_tb/aua1/mmuio_out.rd 
#add wave -hex	/dummy_tb/aua1/mmuio_out.wr
#add wave -dec	/dummy_tb/aua1/mmuio_in.rd_data
#add wave -hex	/dummy_tb/aua1/mmuio_in.rdy_cnt
#add wave -hex	/dummy_tb/aua1/sc_sel_reg
#add wave -hex	/dummy_tb/aua1/sc_addr

#add wave -divider IO-dummy
#add wave -hex /dummy_tb/aua1/cmp_test/address
#add wave -hex /dummy_tb/aua1/cmp_test/wr_data
#add wave /dummy_tb/aua1/cmp_test/rd
#add wave /dummy_tb/aua1/cmp_test/wr
#add wave -hex /dummy_tb/aua1/cmp_test/rd_data
#add wave -uns /dummy_tb/aua1/cmp_test/rdy_cnt
#add wave -uns /dummy_tb/aua1/cmp_test/cycle_cnt
#add wave -uns /dummy_tb/aua1/cmp_test/cycle_cnt_nxt
#add wave -hex /dummy_tb/aua1/cmp_test/reg
#add wave -hex /dummy_tb/aua1/cmp_test/reg_nxt
#add wave -hex /dummy_tb/aua1/cmp_test/sc_out_nxt
#add wave /dummy_tb/aua1/cmp_test/state
#add wave /dummy_tb/aua1/cmp_test/state_nxt

view structure
view signals
run -all
