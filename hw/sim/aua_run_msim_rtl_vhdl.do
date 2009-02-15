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

vcom -93 -work work $path_to_calu_svn/AUA/hw/src/aua_types_de2.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/io/sc_dummy/src/sc_dummy.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/io/sc_uart/src/sc_uart.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/io/sc_uart/src/fifo.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/io/sc_de2_digits/src/sc_de2_digits.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/io/sc_de2_switches/src/sc_de2_switches.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/mmu/src/rom.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/reg/src/ram.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/caches/src/cache_ent.vhd
#vcom -93 -work work $path_to_calu_svn/AUA/hw/caches/src/cache_direct.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/caches/src/cache_null.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/mmu/src/mmu.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/if/src/if.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/reg/src/reg.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/id/src/id.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/ex/src/ex.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/alu/src/alu.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/src/aua_pll.vhd
vcom -93 -work work $path_to_calu_svn/AUA/hw/src/aua_top.vhd

vcom -93 -work work $path_to_calu_svn/AUA/hw/project/../sim/tb.vhd

vsim -t 1ps -L lpm -L altera -L altera_mf -L sgate -L cycloneii -L rtl_work -L work -voptargs="+acc" aua_tb

add wave		/aua_tb/aua1/clk
#~ add wave		/aua_tb/aua1/reset_pin
#~ add wave		/aua_tb/aua1/reset_sync
add wave		/aua_tb/aua1/reset 
#add wave -divider UI
#add wave		/aua_tb/switch_pins /aua_tb/led_pins /aua_tb/digit0_pins /aua_tb/digit1_pins /aua_tb/digit2_pins /aua_tb/digit3_pins /aua_tb/digit4_pins /aua_tb/digit5_pins
#add wave -divider SRAM
#add wave -hex	/aua_tb/sram_addr /aua_tb/sram_dq 
#add wave		/aua_tb/sram_we /aua_tb/sram_oe /aua_tb/sram_ub /aua_tb/sram_lb /aua_tb/sram_ce

add wave -divider IF
add wave -hex	/aua_tb/aua1/cmp_if/pc
add wave -hex	/aua_tb/aua1/cmp_if/pc_in
add wave		/aua_tb/aua1/cmp_if/branch
add wave -hex	/aua_tb/aua1/cmp_if/pc_nxt


#~ add wave -divider CACHE(direct-mapped)
#~ add wave -hex	/aua_tb/aua1/cmp_icache/test
#~ add wave -hex	/aua_tb/aua1/cmp_icache/testr
#~ add wave -hex	/aua_tb/aua1/cmp_icache/store
#~ add wave -uns	/aua_tb/aua1/cmp_icache/cur_word
#~ add wave -uns	/aua_tb/aua1/cmp_icache/cur_line
#~ add wave		/aua_tb/aua1/cmp_icache/in_cache

add wave -divider IF/MMU
add wave -hex	/aua_tb/aua1/cmp_mmu/instr_addr
add wave		/aua_tb/aua1/cmp_mmu/instr_valid
add wave -hex	/aua_tb/aua1/cmp_mmu/instr_data
add wave		/aua_tb/aua1/cmp_mmu/instr_enable

add wave -divider ID
add wave -hex	/aua_tb/aua1/cmp_id/opcode_in
add wave -hex	/aua_tb/aua1/cmp_id/pc_in
add wave -hex	/aua_tb/aua1/cmp_id/pc_out
add wave		/aua_tb/aua1/cmp_id/branch/brinstr
add wave		/aua_tb/aua1/cmp_id/branch/inv
add wave		/aua_tb/aua1/cmp_id/br_data_hz_nxt
add wave		/aua_tb/aua1/cmp_id/br_data_hz
add wave -hex	/aua_tb/aua1/cmp_id/opa_nxt
add wave -uns	/aua_tb/aua1/cmp_id/rega_in
add wave -hex	/aua_tb/aua1/cmp_id/vala
add wave -uns	/aua_tb/aua1/cmp_id/regb_in
add wave -hex	/aua_tb/aua1/cmp_id/valb
add wave -hex	/aua_tb/aua1/cmp_id/imm_in
add wave -hex	/aua_tb/aua1/cmp_id/opb_nxt
add wave -divider EX
add wave -hex	/aua_tb/aua1/cmp_ex/opcode
add wave -hex	/aua_tb/aua1/cmp_ex/opa
add wave -hex	/aua_tb/aua1/cmp_id/opb_out
add wave -hex	/aua_tb/aua1/cmp_ex/opb
#add wave		/aua_tb/aua1/cmp_ex/cmp_alu/carry
add wave -uns	/aua_tb/aua1/cmp_ex/dest_out
add wave -hex	/aua_tb/aua1/cmp_ex/result_out

add wave -divider REG-file
add wave -uns	/aua_tb/aua1/cmp_id/cmp_reg/rega
#add wave -hex	/aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/rdaddress
add wave -hex	/aua_tb/aua1/cmp_id/cmp_reg/vala
add wave -uns	/aua_tb/aua1/cmp_id/cmp_reg/regb
add wave -hex	/aua_tb/aua1/cmp_id/cmp_reg/valb
add wave -uns	/aua_tb/aua1/cmp_id/cmp_reg/regr
#add wave -hex	/aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/wraddress
add wave -hex	/aua_tb/aua1/cmp_id/cmp_reg/valr
#add wave -hex	/aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/altsyncram_component/memory/m_mem_data_a(1)
add wave -hex	/aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_a/altsyncram_component/memory/m_mem_data_a
#add wave -hex	/aua_tb/aua1/cmp_id/cmp_reg/cmp_ram_b/altsyncram_component/memory/m_mem_data_a

add wave -divider interstages
add wave 		/aua_tb/aua1/ex_locks 
add wave		/aua_tb/aua1/cmp_ex/ex_locks_nxt
add wave -dec	/aua_tb/aua1/lock_if
add wave -dec	/aua_tb/aua1/lock_id

add wave -divider IO
add wave		/aua_tb/aua1/cmp_mmu/ex_enable
add wave -hex	/aua_tb/aua1/cmp_mmu/ex_address
add wave -hex	/aua_tb/aua1/cmp_mmu/ex_wr_data
add wave -hex	/aua_tb/aua1/cmp_mmu/ex_rd_data
add wave -hex	/aua_tb/aua1/cmp_mmu/ex_opcode
add wave		/aua_tb/aua1/cmp_ex/mmu_done
add wave 		/aua_tb/aua1/cmp_mmu/mmu_state
#~ add wave -hex	/aua_tb/aua1/cmp_mmu/sc_addr
#~ add wave -hex	/aua_tb/aua1/cmp_mmu/sc_wr_data
#~ add wave -hex	/aua_tb/aua1/cmp_mmu/sc_rd_data
#~ add wave		/aua_tb/aua1/cmp_mmu/sc_rdy_cnt
#~ add wave		/aua_tb/aua1/cmp_mmu/sc_rd
#~ add wave		/aua_tb/aua1/cmp_mmu/sc_wr
add wave -hex	/aua_tb/aua1/cmp_mmu/rom_addr
add wave -hex	/aua_tb/aua1/cmp_mmu/rom_q
#~ add wave -hex	/aua_tb/aua1/mmuio_out.address
#~ add wave -hex	/aua_tb/aua1/mmuio_out.wr_data 
#~ add wave -hex	/aua_tb/aua1/mmuio_out.rd 
#~ add wave -hex	/aua_tb/aua1/mmuio_out.wr
#~ add wave -dec	/aua_tb/aua1/mmuio_in.rd_data
#~ add wave -hex	/aua_tb/aua1/mmuio_in.rdy_cnt
#~ add wave -hex	/aua_tb/aua1/sc_sel_reg
#~ add wave -hex	/aua_tb/aua1/sc_addr

#~ add wave -divider IO-dummy
#~ add wave -hex	/aua_tb/aua1/cmp_test/address
#~ add wave -hex	/aua_tb/aua1/cmp_test/wr_data
#~ add wave		/aua_tb/aua1/cmp_test/rd
#~ add wave		/aua_tb/aua1/cmp_test/wr
#~ add wave -hex	/aua_tb/aua1/cmp_test/rd_data
#~ add wave -uns	/aua_tb/aua1/cmp_test/rdy_cnt
#~ add wave -uns	/aua_tb/aua1/cmp_test/cycle_cnt
#~ add wave -uns	/aua_tb/aua1/cmp_test/cycle_cnt_nxt
#~ add wave -hex	/aua_tb/aua1/cmp_test/reg
#~ add wave -hex	/aua_tb/aua1/cmp_test/reg_nxt
#~ add wave -hex	/aua_tb/aua1/cmp_test/sc_out_nxt
#~ add wave		/aua_tb/aua1/cmp_test/state
#~ add wave		/aua_tb/aua1/cmp_test/state_nxt

#~ add wave -divider UART
#~ add wave -hex	/aua_tb/aua1/cmp_uart/address
#~ add wave -hex	/aua_tb/aua1/cmp_uart/wr_data
#~ add wave		/aua_tb/aua1/cmp_uart/rd
#~ add wave		/aua_tb/aua1/cmp_uart/wr
#~ add wave -hex	/aua_tb/aua1/cmp_uart/rd_data
#~ add wave -uns	/aua_tb/aua1/cmp_uart/rdy_cnt

view structure
view signals
run -all
