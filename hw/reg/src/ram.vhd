-- megafunction wizard: %RAM: 3-PORT%
-- GENERATION: STANDARD
-- VERSION: WM1.0
-- MODULE: alt3pram 

-- ============================================================
-- File Name: ram.vhd
-- Megafunction Name(s):
-- 			alt3pram
--
-- Simulation Library Files(s):
-- 			altera_mf
-- ============================================================
-- ************************************************************
-- THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
--
-- 8.0 Build 231 07/10/2008 SP 1 SJ Web Edition
-- ************************************************************


--Copyright (C) 1991-2008 Altera Corporation
--Your use of Altera Corporation's design tools, logic functions 
--and other software and tools, and its AMPP partner logic 
--functions, and any output files from any of the foregoing 
--(including device programming or simulation files), and any 
--associated documentation or information are expressly subject 
--to the terms and conditions of the Altera Program License 
--Subscription Agreement, Altera MegaCore Function License 
--Agreement, or other applicable license agreement, including, 
--without limitation, that your use is for the sole purpose of 
--programming logic devices manufactured by Altera and sold by 
--Altera or its authorized distributors.  Please refer to the 
--applicable agreement for further details.


LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY ram IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress_a		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		rdaddress_b		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		wraddress		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		wren		: IN STD_LOGIC  := '1';
		qa		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		qb		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END ram;


ARCHITECTURE SYN OF ram IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (15 DOWNTO 0);



	COMPONENT alt3pram
	GENERIC (
		indata_aclr		: STRING;
		indata_reg		: STRING;
		intended_device_family		: STRING;
		lpm_type		: STRING;
		outdata_aclr_a		: STRING;
		outdata_aclr_b		: STRING;
		outdata_reg_a		: STRING;
		outdata_reg_b		: STRING;
		ram_block_type		: STRING;
		rdaddress_aclr_a		: STRING;
		rdaddress_aclr_b		: STRING;
		rdaddress_reg_a		: STRING;
		rdaddress_reg_b		: STRING;
		rdcontrol_aclr_a		: STRING;
		rdcontrol_aclr_b		: STRING;
		rdcontrol_reg_a		: STRING;
		rdcontrol_reg_b		: STRING;
		width		: NATURAL;
		widthad		: NATURAL;
		write_aclr		: STRING;
		write_reg		: STRING
	);
	PORT (
			qa	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			outclock	: IN STD_LOGIC ;
			qb	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			wren	: IN STD_LOGIC ;
			inclock	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			rdaddress_a	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			wraddress	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			rdaddress_b	: IN STD_LOGIC_VECTOR (4 DOWNTO 0)
	);
	END COMPONENT;

BEGIN
	qa    <= sub_wire0(15 DOWNTO 0);
	qb    <= sub_wire1(15 DOWNTO 0);

	alt3pram_component : alt3pram
	GENERIC MAP (
		indata_aclr => "OFF",
		indata_reg => "INCLOCK",
		intended_device_family => "Cyclone II",
		lpm_type => "alt3pram",
		outdata_aclr_a => "OFF",
		outdata_aclr_b => "OFF",
		outdata_reg_a => "OUTCLOCK",
		outdata_reg_b => "OUTCLOCK",
		ram_block_type => "M4K",
		rdaddress_aclr_a => "OFF",
		rdaddress_aclr_b => "OFF",
		rdaddress_reg_a => "INCLOCK",
		rdaddress_reg_b => "INCLOCK",
		rdcontrol_aclr_a => "OFF",
		rdcontrol_aclr_b => "OFF",
		rdcontrol_reg_a => "UNREGISTERED",
		rdcontrol_reg_b => "UNREGISTERED",
		width => 16,
		widthad => 5,
		write_aclr => "OFF",
		write_reg => "INCLOCK"
	)
	PORT MAP (
		outclock => clock,
		wren => wren,
		inclock => clock,
		data => data,
		rdaddress_a => rdaddress_a,
		wraddress => wraddress,
		rdaddress_b => rdaddress_b,
		qa => sub_wire0,
		qb => sub_wire1
	);



END SYN;

-- ============================================================
-- CNX file retrieval info
-- ============================================================
-- Retrieval info: PRIVATE: BlankMemory NUMERIC "1"
-- Retrieval info: PRIVATE: CLRdata NUMERIC "0"
-- Retrieval info: PRIVATE: CLRqa NUMERIC "0"
-- Retrieval info: PRIVATE: CLRqb NUMERIC "0"
-- Retrieval info: PRIVATE: CLRrdaddress_a NUMERIC "0"
-- Retrieval info: PRIVATE: CLRrdaddress_b NUMERIC "0"
-- Retrieval info: PRIVATE: CLRrren_a NUMERIC "0"
-- Retrieval info: PRIVATE: CLRrren_b NUMERIC "0"
-- Retrieval info: PRIVATE: CLRwrite NUMERIC "0"
-- Retrieval info: PRIVATE: Clock NUMERIC "0"
-- Retrieval info: PRIVATE: INIT_FILE_LAYOUT STRING "PORT_A"
-- Retrieval info: PRIVATE: INIT_TO_SIM_X NUMERIC "0"
-- Retrieval info: PRIVATE: INTENDED_DEVICE_FAMILY STRING "Cyclone II"
-- Retrieval info: PRIVATE: JTAG_ENABLED NUMERIC "0"
-- Retrieval info: PRIVATE: JTAG_ID STRING "NONE"
-- Retrieval info: PRIVATE: MAXIMUM_DEPTH NUMERIC "0"
-- Retrieval info: PRIVATE: MIFfilename STRING ""
-- Retrieval info: PRIVATE: RAM_BLOCK_TYPE NUMERIC "2"
-- Retrieval info: PRIVATE: REGdata NUMERIC "1"
-- Retrieval info: PRIVATE: REGqa NUMERIC "1"
-- Retrieval info: PRIVATE: REGqb NUMERIC "1"
-- Retrieval info: PRIVATE: REGrdaddress_a NUMERIC "1"
-- Retrieval info: PRIVATE: REGrdaddress_b NUMERIC "1"
-- Retrieval info: PRIVATE: REGrren_a NUMERIC "0"
-- Retrieval info: PRIVATE: REGrren_b NUMERIC "0"
-- Retrieval info: PRIVATE: REGwrite NUMERIC "1"
-- Retrieval info: PRIVATE: SYNTH_WRAPPER_GEN_POSTFIX STRING "1"
-- Retrieval info: PRIVATE: WidthAddr NUMERIC "5"
-- Retrieval info: PRIVATE: WidthData NUMERIC "16"
-- Retrieval info: PRIVATE: enable NUMERIC "0"
-- Retrieval info: PRIVATE: rden_a NUMERIC "0"
-- Retrieval info: PRIVATE: rden_b NUMERIC "0"
-- Retrieval info: CONSTANT: INDATA_ACLR STRING "OFF"
-- Retrieval info: CONSTANT: INDATA_REG STRING "INCLOCK"
-- Retrieval info: CONSTANT: INTENDED_DEVICE_FAMILY STRING "Cyclone II"
-- Retrieval info: CONSTANT: LPM_TYPE STRING "alt3pram"
-- Retrieval info: CONSTANT: OUTDATA_ACLR_A STRING "OFF"
-- Retrieval info: CONSTANT: OUTDATA_ACLR_B STRING "OFF"
-- Retrieval info: CONSTANT: OUTDATA_REG_A STRING "OUTCLOCK"
-- Retrieval info: CONSTANT: OUTDATA_REG_B STRING "OUTCLOCK"
-- Retrieval info: CONSTANT: RAM_BLOCK_TYPE STRING "M4K"
-- Retrieval info: CONSTANT: RDADDRESS_ACLR_A STRING "OFF"
-- Retrieval info: CONSTANT: RDADDRESS_ACLR_B STRING "OFF"
-- Retrieval info: CONSTANT: RDADDRESS_REG_A STRING "INCLOCK"
-- Retrieval info: CONSTANT: RDADDRESS_REG_B STRING "INCLOCK"
-- Retrieval info: CONSTANT: RDCONTROL_ACLR_A STRING "OFF"
-- Retrieval info: CONSTANT: RDCONTROL_ACLR_B STRING "OFF"
-- Retrieval info: CONSTANT: RDCONTROL_REG_A STRING "UNREGISTERED"
-- Retrieval info: CONSTANT: RDCONTROL_REG_B STRING "UNREGISTERED"
-- Retrieval info: CONSTANT: WIDTH NUMERIC "16"
-- Retrieval info: CONSTANT: WIDTHAD NUMERIC "5"
-- Retrieval info: CONSTANT: WRITE_ACLR STRING "OFF"
-- Retrieval info: CONSTANT: WRITE_REG STRING "INCLOCK"
-- Retrieval info: USED_PORT: clock 0 0 0 0 INPUT NODEFVAL clock
-- Retrieval info: USED_PORT: data 0 0 16 0 INPUT NODEFVAL data[15..0]
-- Retrieval info: USED_PORT: qa 0 0 16 0 OUTPUT NODEFVAL qa[15..0]
-- Retrieval info: USED_PORT: qb 0 0 16 0 OUTPUT NODEFVAL qb[15..0]
-- Retrieval info: USED_PORT: rdaddress_a 0 0 5 0 INPUT NODEFVAL rdaddress_a[4..0]
-- Retrieval info: USED_PORT: rdaddress_b 0 0 5 0 INPUT NODEFVAL rdaddress_b[4..0]
-- Retrieval info: USED_PORT: wraddress 0 0 5 0 INPUT NODEFVAL wraddress[4..0]
-- Retrieval info: USED_PORT: wren 0 0 0 0 INPUT VCC wren
-- Retrieval info: CONNECT: @data 0 0 16 0 data 0 0 16 0
-- Retrieval info: CONNECT: qa 0 0 16 0 @qa 0 0 16 0
-- Retrieval info: CONNECT: qb 0 0 16 0 @qb 0 0 16 0
-- Retrieval info: CONNECT: @wraddress 0 0 5 0 wraddress 0 0 5 0
-- Retrieval info: CONNECT: @rdaddress_a 0 0 5 0 rdaddress_a 0 0 5 0
-- Retrieval info: CONNECT: @rdaddress_b 0 0 5 0 rdaddress_b 0 0 5 0
-- Retrieval info: CONNECT: @wren 0 0 0 0 wren 0 0 0 0
-- Retrieval info: CONNECT: @inclock 0 0 0 0 clock 0 0 0 0
-- Retrieval info: CONNECT: @outclock 0 0 0 0 clock 0 0 0 0
-- Retrieval info: LIBRARY: altera_mf altera_mf.altera_mf_components.all
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram.inc FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram.cmp TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram.bsf FALSE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram_inst.vhd TRUE
-- Retrieval info: GEN_FILE: TYPE_NORMAL ram_syn.v TRUE
-- Retrieval info: LIB_FILE: altera_mf