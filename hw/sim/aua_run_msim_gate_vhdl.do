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

vcom -93 -work work $path_to_calu_svn/AUA/hw/src/aua_types_de2.vhd

vcom -93 -work work $path_to_calu_svn/AUA/hw/sim/work/aua.vho

vcom -93 -work work $path_to_calu_svn/AUA/hw/sim/tb_gate.vhd

vsim -t 1ps +transport_int_delays +transport_path_delays -sdftyp /aua1=aua_vhd.sdo -L cycloneii -L gate_work -L work -voptargs="+acc" aua_tb

add wave /aua_tb/*

view structure
view signals
run -all
