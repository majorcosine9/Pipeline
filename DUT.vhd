library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsRISC.all;
--------------------------------------------------

entity DUT is 
	port ( 
		clk : in std_logic;
		reset: in std_logic);
end entity;

architecture DUTWrap of DUT is

	component control_pipe is
	port(
	clk: in std_logic;
	carry, zero: in std_logic;
	valid2: in std_logic;
	IF_ID_opcode_bits: in std_logic_vector(3 downto 0);
	cz_bits : in std_logic_vector(1 downto 0);
	eq_T1_T2 : in std_logic;
	reset: in std_logic;
	IF_ID_Rs1, IF_ID_Rs2: in std_logic_vector(2 downto 0);
	ID_EX_opcode_bits: in std_logic_vector(3 downto 0);
	ID_EX_valid2: in std_logic;
	ID_EX_RegWrite: in std_logic;
	ID_EX_Rd: in std_logic_vector(2 downto 0);
	EX_MEM_RegWrite: in std_logic;
	EX_MEM_Rd: in std_logic_vector(2 downto 0);
	MEM_WB_RegWrite: in std_logic;
	MEM_WB_Rd: in std_logic_vector(2 downto 0);

	PC_en: out std_logic;
	IF_ID_en: out std_logic;
	C_en: out std_logic;
	Z_en: out std_logic;
	RegWrite: out std_logic;
	PC_mux: out std_logic_vector(1 downto 0);
	IR_mux: out std_logic_vector(1 downto 0);
	BALU2_mux: out std_logic;
	Rf_a2_mux: out std_logic;
	ALU2_mux: out std_logic_vector(2 downto 0);
	ALU1_mux: out std_logic_vector(2 downto 0);
	T1_mux: out std_logic_vector(2 downto 0);
	T2_mux: out std_logic_vector(2 downto 0);
	mem_data_in_mux: out std_logic;
	Rf_d3_mux: out std_logic_vector(1 downto 0);
	Rf_a3_mux: out std_logic_vector(1 downto 0);
	MemWrite: out std_logic
	);
	end component;

	component datapath is 
	port ( 
		clk : in std_logic;
		reset: in std_logic;

		PC_en:    in std_logic;
		IF_ID_en: in std_logic;
		C_en:  in std_logic;
		Z_en: in std_logic;
		RegWrite: in std_logic;
		PC_mux: in std_logic_vector(1 downto 0);
		IR_mux: in std_logic_vector(1 downto 0);
		BALU2_mux: in std_logic;
		Rf_a2_mux: in std_logic;
		ALU2_mux: in std_logic_vector(2 downto 0);
		ALU1_mux: in std_logic_vector(2 downto 0);
		T1_mux: in std_logic_vector(2 downto 0);
		T2_mux: in std_logic_vector(2 downto 0);
		mem_data_in_mux: in std_logic;
		Rf_d3_mux: in std_logic_vector(1 downto 0);
		Rf_a3_mux: in std_logic_vector(1 downto 0);
		MemWrite: in std_logic;
		
		--mem_data_output: in std_logic_vector(15 downto 0);
		
		carry, zero: out std_logic;
		valid2: out std_logic;
		IF_ID_opcode_bits:out std_logic_vector(3 downto 0);
		cz_bits : out std_logic_vector(1 downto 0);
		eq_T1_T2 : out std_logic;
		IF_ID_Rs1, IF_ID_Rs2: out std_logic_vector(2 downto 0);
		ID_EX_opcode_bits: out std_logic_vector(3 downto 0);
		ID_EX_valid2: out std_logic;
		ID_EX_RegWrite: out std_logic;
		ID_EX_Rd: out std_logic_vector(2 downto 0);
		EX_MEM_RegWrite: out std_logic;
		EX_MEM_Rd: out std_logic_vector(2 downto 0);
		MEM_WB_RegWrite: out std_logic;
		MEM_WB_Rd: out std_logic_vector(2 downto 0);
		
		PC_reg_in,PC_reg_out: out std_logic_vector(15 downto 0));
	end component;

	signal  PC_en_s:     std_logic;
	signal	IF_ID_en_s:  std_logic;
	signal	C_en_s:  std_logic;
	signal	Z_en_s:  std_logic;
	signal	RegWrite_s:  std_logic;
	signal	PC_mux_s:  std_logic_vector(1 downto 0);
	signal	IR_mux_s:  std_logic_vector(1 downto 0);
	signal	BALU2_mux_s:  std_logic;
	signal	Rf_a2_mux_s:  std_logic;
	signal	ALU2_mux_s:  std_logic_vector(2 downto 0);
	signal	ALU1_mux_s:  std_logic_vector(2 downto 0);
	signal	T1_mux_s:  std_logic_vector(2 downto 0);
	signal	T2_mux_s:  std_logic_vector(2 downto 0);
	signal	mem_data_in_mux_s: std_logic;
	signal	Rf_d3_mux_s:  std_logic_vector(1 downto 0);
	signal	Rf_a3_mux_s:  std_logic_vector(1 downto 0);
	signal	MemWrite_s:  std_logic;
		
		--mem_data_output: in std_logic_vector(15 downto 0);
		
	signal	carry_s, zero_s: std_logic;
	signal	valid2_s: std_logic;
	signal	IF_ID_opcode_bits_s: std_logic_vector(3 downto 0);
	signal	cz_bits_s:   std_logic_vector(1 downto 0);
	signal	eq_T1_T2_s:   std_logic;
	signal	IF_ID_Rs1_s, IF_ID_Rs2_s:   std_logic_vector(2 downto 0);
	signal	ID_EX_opcode_bits_s:   std_logic_vector(3 downto 0);
	signal	ID_EX_valid2_s:   std_logic;
	signal	ID_EX_RegWrite_s:   std_logic;
	signal	ID_EX_Rd_s:   std_logic_vector(2 downto 0);
	signal	EX_MEM_RegWrite_s:   std_logic;
	signal	EX_MEM_Rd_s:   std_logic_vector(2 downto 0);
	signal	MEM_WB_RegWrite_s:   std_logic;
	signal	MEM_WB_Rd_s:   std_logic_vector(2 downto 0);
	
	signal   PC_reg_in_s,PC_reg_out_s: std_logic_vector(15 downto 0);

begin
	
	control: control_pipe
	port map(
	clk => clk,
	reset => reset,
	carry => carry_s,
	zero => zero_s,
	valid2 => valid2_s,
	IF_ID_opcode_bits => IF_ID_opcode_bits_s,
	cz_bits => cz_bits_s,
	eq_T1_T2 => eq_T1_T2_s,
	IF_ID_Rs1 => IF_ID_Rs1_s,
	IF_ID_Rs2 => IF_ID_Rs2_s,
	ID_EX_opcode_bits => ID_EX_opcode_bits_s,
	ID_EX_valid2 => ID_EX_valid2_s,
	ID_EX_RegWrite => ID_EX_RegWrite_s,
	ID_EX_Rd => ID_EX_Rd_s,
	EX_MEM_RegWrite => EX_MEM_RegWrite_s,
	EX_MEM_Rd => EX_MEM_Rd_s,
	MEM_WB_RegWrite => MEM_WB_RegWrite_s,
	MEM_WB_Rd => MEM_WB_Rd_s,

	PC_en => PC_en_s,
	IF_ID_en => IF_ID_en_s,
	C_en => C_en_s,
	Z_en => Z_en_s,
	RegWrite => RegWrite_s,
	PC_mux => PC_mux_s,
	IR_mux => IR_mux_s,
	BALU2_mux => BALU2_mux_s,
	Rf_a2_mux => Rf_a2_mux_s,
	ALU2_mux => ALU2_mux_s,
	ALU1_mux => ALU1_mux_s,
	T1_mux => T1_mux_s,
	T2_mux => T2_mux_s,
	mem_data_in_mux => mem_data_in_mux_s,
	Rf_d3_mux => Rf_d3_mux_s,
	Rf_a3_mux => Rf_a3_mux_s,
	MemWrite => MemWrite_s );

	data: datapath
	port map(
	clk => clk,
	reset => reset,
	carry => carry_s,
	zero => zero_s,
	valid2 => valid2_s,
	IF_ID_opcode_bits => IF_ID_opcode_bits_s,
	cz_bits => cz_bits_s,
	eq_T1_T2 => eq_T1_T2_s,
	IF_ID_Rs1 => IF_ID_Rs1_s,
	IF_ID_Rs2 => IF_ID_Rs2_s,
	ID_EX_opcode_bits => ID_EX_opcode_bits_s,
	ID_EX_valid2 => ID_EX_valid2_s,
	ID_EX_RegWrite => ID_EX_RegWrite_s,
	ID_EX_Rd => ID_EX_Rd_s,
	EX_MEM_RegWrite => EX_MEM_RegWrite_s,
	EX_MEM_Rd => EX_MEM_Rd_s,
	MEM_WB_RegWrite => MEM_WB_RegWrite_s,
	MEM_WB_Rd => MEM_WB_Rd_s,

	PC_en => PC_en_s,
	IF_ID_en => IF_ID_en_s,
	C_en => C_en_s,
	Z_en => Z_en_s,
	RegWrite => RegWrite_s,
	PC_mux => PC_mux_s,
	IR_mux => IR_mux_s,
	BALU2_mux => BALU2_mux_s,
	Rf_a2_mux => Rf_a2_mux_s,
	ALU2_mux => ALU2_mux_s,
	ALU1_mux => ALU1_mux_s,
	T1_mux => T1_mux_s,
	T2_mux => T2_mux_s,
	mem_data_in_mux => mem_data_in_mux_s,
	Rf_d3_mux => Rf_d3_mux_s,
	Rf_a3_mux => Rf_a3_mux_s,
	MemWrite => MemWrite_s,
		
		PC_reg_in=> PC_reg_in_s,
		PC_reg_out=> PC_reg_out_s);
	
	


end DUTWrap;