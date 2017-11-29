library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsRISC.all;
--------------------------------------------------

entity combined is 
	port ( 
		clk : in std_logic;
		reset: in std_logic);
end entity;

architecture behave of combined is
	signal RF_a2_in,PE_out,ID_EX_RD_out,EX_MEM_RD_out,MEM_WB_RD_out,ID_EX_Rd_in,ALU2_mux,ALU1_mux,T1_mux,T2_mux: std_logic_vector(2 downto 0) :="000";
	signal Rf_d3_mux,ID_EX_Rf_d3_mux_out,EX_MEM_Rf_d3_mux_out,PC_mux,IR_mux,Rf_a3_mux: std_logic_vector(1 downto 0):="00";
	signal carry_ALU_out,zero_ALU_out,valid2_signal,ID_EX_valid2_out,ID_EX_RegWrite_out,EX_MEM_RegWrite_out,
			MEM_WB_RegWrite_out,ID_EX_C_en_out,ID_EX_Z_en_out,ID_EX_mem_mux_out,EX_MEM_mem_mux_out,ID_EX_MemWrite_out,
			EX_MEM_MemWrite_out,C_en,Z_en,mem_data_in_mux,MemWrite,PC_en,IF_ID_en,RegWrite,BALU2_mux,Rf_a2_mux: std_logic:='0';
	signal ID_EX_ALU1_in,ID_EX_ALU2_in,ID_EX_T1_in,ID_EX_T2_in,ID_EX_IR_out,ID_EX_PC_out,ID_EX_ALU1_out,
			ID_EX_ALU2_out,ID_EX_T1_out,ID_EX_T2_out,EX_LS7_out,ALU_out,SE10_out,SE7_out,LS7_out,RF_d2_out,RF_d1_out,
			RF_d3_in,Imem_data_out,Balu_out,Palu_out,PC_in,PC_out,Balu2_mux_out,DMEM_Data_in,DMEM_Data_out,
			EX_MEM_ALUout,EX_MEM_IR_out,EX_MEM_PC_out,EX_MEM_T1_out,EX_MEM_T2_out,Mem_WB_RF_D3_in,Mem_WB_RF_D3_out,
			MEM_WB_IR_out,IF_ID_PC_out,IF_ID_IR_out,IF_ID_IR_in,Dec_out: std_logic_vector(15 downto 0):="0000000000000000";
	signal MemWrite_bar: std_logic:='1';

	signal carry,zero,eq_T1_T2_signal: std_logic:='0';
	signal IF_ID_Rs1,IF_ID_Rs2: std_logic_vector(2 downto 0):="000";

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
	
begin

	PC_mux_comp: mux4_16
	port map(
		IN3=> "0000000000000000",
		IN2=> RF_d2_out,
		IN1=> Balu_out,
		IN0=> Palu_out, 
		s=> PC_mux,
		OUTPUT=> PC_in);

	PC: dregister_PC
	port map(
		DIN=>PC_in,
		clk=> clk,
		reset=> reset,
		en=>PC_en,
		DOUT=>PC_out);
	
	Palu: alu_adder
	port map(
		D1=>PC_out,
		D2=>"0000000000000001",
		OUTPUT=> Palu_out);

	IMEM: memory   
    generic map (data_width=> 16, addr_width=> 16)
    port map(
    	din=> PC_out,
        dout=> Imem_data_out,
        rbar=> '0',
        wbar=> '1',
        addrin=> PC_out );

    IR_mux_comp: mux4_16
	port map(
		IN3=> "0000000000000000",
		IN2=> "1111000000000000",
		IN1=> Dec_out,
		IN0=> Imem_data_out, 
		s=> IR_mux,
		OUTPUT=> IF_ID_IR_in);

	-----------------------------IF/ID---------------------------------------
	IF_ID_IR: dregister
	port map(
		DIN=>IF_ID_IR_in,
		clk=> clk,
		reset=> reset,
		en=> IF_ID_en,
		DOUT=>IF_ID_IR_out);

	IF_ID_PC: dregister
	port map(
		DIN=>Palu_out,
		clk=> clk,
		reset=> reset,
		en=>IF_ID_en,
		DOUT=>IF_ID_PC_out);
	-------------------------------------------------------------------

	RF_a2_mux_comp: mux2_3  
	port map (
		IN1=> PE_out,
		IN0=> IF_ID_IR_out(8 downto 6), 
		s=> RF_a2_mux,
		OUTPUT=> RF_a2_in);

	RF_a3_mux_comp: mux4_3
	port map(
		IN3=> PE_out,
		IN2=> IF_ID_IR_out(11 downto 9),
		IN1=> IF_ID_IR_out(8 downto 6),
		IN0=> IF_ID_IR_out(5 downto 3), 
		s=> RF_a3_mux,
		OUTPUT=> ID_EX_Rd_in);

	RF: register_file  
	port map (
		a1=> IF_ID_IR_out(11 downto 9),   --a2 a1 to read the data
		a2=> RF_a2_in,
		a3=> MEM_WB_RD_out,   --a3 is the address where data to be written 
		d3=> Mem_WB_RF_D3_out,      -- d3 is the daata to write 
		wr=> MEM_WB_RegWrite_out,   
		d1=> RF_d1_out, 
		d2=> RF_d2_out,
		reset=> reset,
		clk=> clk);

	eq_T1_T2_signal <= '1' when ID_EX_T2_in = ID_EX_T1_in else '0';

	PE: priority   
	port map (
		INPUT=>IF_ID_IR_out(8 downto 0), 
		output=> PE_out,
		valid2=> valid2_signal);

	IR_dec: ir_decoder 
	port map (
		s=> PE_out,
		IR=> IF_ID_IR_out, 
		new_IR=> Dec_out);

	SE7: SgnExtd7
	port map(
		IN1 => IF_ID_IR_out(8 downto 0),
		OUTPUT1 => SE7_out);
	
	SE10: SgnExtd10
	port map(
		IN1 => IF_ID_IR_out(5 downto 0),
		OUTPUT1 => SE10_out);
	
	ALU_1_mux_comp: mux8_16 
	port map (
		IN7=> RF_d2_out,
		IN6=> Mem_WB_RF_D3_out,
		IN5=> Mem_WB_RF_D3_in,
		IN4=> ALU_out,
		IN3=> EX_LS7_out,
		IN2=> ID_EX_PC_out,
		IN1=> ALU_out,
		IN0=> RF_d1_out, 
		s=> ALU1_mux,
		OUTPUT=> ID_EX_ALU1_in);

	T1_mux_comp: mux8_16 
	port map (
		IN7=> "0000000000000000",
		IN6=> Mem_WB_RF_D3_out,
		IN5=> Mem_WB_RF_D3_in,
		IN4=> ALU_out,
		IN3=> EX_LS7_out,
		IN2=> ID_EX_PC_out,
		IN1=> ALU_out,
		IN0=> RF_d1_out, 
		s=> T1_mux,
		OUTPUT=> ID_EX_T1_in);

	ALU_2_mux_comp: mux8_16 
	port map (
		IN7=> "0000000000000001",
		IN6=> Mem_WB_RF_D3_out,
		IN5=> Mem_WB_RF_D3_in,
		IN4=> ALU_out,
		IN3=> EX_LS7_out,
		IN2=> ID_EX_PC_out,
		IN1=> SE10_out,
		IN0=> RF_d2_out, 
		s=> ALU2_mux,
		OUTPUT=> ID_EX_ALU2_in);

	T2_mux_comp: mux8_16 
	port map (
		IN7=> "0000000000000000",
		IN6=> Mem_WB_RF_D3_out,
		IN5=> Mem_WB_RF_D3_in,
		IN4=> ALU_out,
		IN3=> EX_LS7_out,
		IN2=> ID_EX_PC_out,
		IN1=> "0000000000000000",
		IN0=> RF_d2_out,
		s=> T2_mux,
		OUTPUT=> ID_EX_T2_in);

	Balu2_mux_comp: mux2_16 
	port map (
		IN1=> SE10_out,
		IN0=> SE7_out, 
		s=> Balu2_mux,
		OUTPUT=> Balu2_mux_out);

	Balu: alu_adder
	port map(
		D1=>IF_ID_PC_out,
		D2=>Balu2_mux_out,
		OUTPUT=> Balu_out);

	---------------------------------ID/EX-----------------------------------
	ID_EX_IR: dregister
	port map(
		DIN=>IF_ID_IR_out,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>ID_EX_IR_out);

	ID_EX_PC: dregister
	port map(
		DIN=>IF_ID_PC_out,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>ID_EX_PC_out);

	ID_EX_ALU1: dregister
	port map(
		DIN=>ID_EX_ALU1_in,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>ID_EX_ALU1_out);

	ID_EX_ALU2: dregister
	port map(
		DIN=>ID_EX_ALU2_in,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>ID_EX_ALU2_out);

	ID_EX_T1: dregister
	port map(
		DIN=>ID_EX_T1_in,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>ID_EX_T1_out);

	ID_EX_T2: dregister
	port map(
		DIN=>ID_EX_T2_in,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>ID_EX_T2_out);

	ID_EX_valid2_flop: dflipflop
	port map(
		DIN=> valid2_signal, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> ID_EX_valid2_out);

	ID_EX_RegWrite_flop: dflipflop
	port map(
		DIN=> RegWrite, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> ID_EX_RegWrite_out);
		
	ID_EX_C_en_flop: dflipflop
	port map(
		DIN=> C_en, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> ID_EX_C_en_out);

	ID_EX_Z_en_flop: dflipflop
	port map(
		DIN=> Z_en, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> ID_EX_Z_en_out);

--mem data mux
	ID_EX_mem_mux_flop: dflipflop
	port map(
		DIN=> mem_data_in_mux, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> ID_EX_mem_mux_out);

	ID_EX_MemWrite_flop: dflipflop
	port map(
		DIN=> MemWrite, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> ID_EX_MemWrite_out);

	ID_EX_Rf_d3_mux_flop: dflipflop_2
	port map(
		DIN=> Rf_d3_mux, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> ID_EX_Rf_d3_mux_out);

	ID_EX_RD_flop: dflipflop_3
	port map(
		DIN=> ID_EX_Rd_in,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>ID_EX_RD_out);
	------------------------------EX-------------------------------------

	ALU_main: alu   
	port map( 
		X=> ID_EX_ALU1_out,
		Y=> ID_EX_ALU2_out,
		op_code_bits => ID_EX_IR_out(15 downto 12),                 -- write opcode, ALU to be modified
		cz_bits=> ID_EX_IR_out(1 downto 0), 
		OUTPUT_ALU=> ALU_out,
		carry_ALU =>carry_ALU_out,
		zero_ALU=>zero_ALU_out);

	C: dflipflop  
	port map (DIN=> carry_ALU_out, 
		  clk=> clk,
		  reset=> reset,
		  en=> ID_EX_C_en_out,
		  DOUT=> carry);
		  
	Z: dflipflop  
	port map (DIN=> zero_ALU_out, 
		  clk=> clk,
		  reset=> reset,
		  en=> ID_EX_Z_en_out,
		  DOUT=> zero);

	LS7_2:  LeftShift
	port map(
		IN1 => ID_EX_IR_out(8 downto 0),
		OUTPUT1 => EX_LS7_out);

	-----------------------------------EX/MEM---------------------------------
	EX_MEM_IR: dregister
	port map(
		DIN=>ID_EX_IR_out,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>EX_MEM_IR_out);

	EX_MEM_PC: dregister
	port map(
		DIN=>ID_EX_PC_out,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>EX_MEM_PC_out);

	EX_MEM_ALUout_reg: dregister
	port map(
		DIN=>ALU_out,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>EX_MEM_ALUout);

	EX_MEM_T1: dregister
	port map(
		DIN=>ID_EX_T1_out,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>EX_MEM_T1_out);

	EX_MEM_T2: dregister
	port map(
		DIN=>ID_EX_T2_out,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>EX_MEM_T2_out);

	EX_MEM_RegWrite_flop: dflipflop
	port map(
		DIN=> ID_EX_RegWrite_out, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> EX_MEM_RegWrite_out);

	EX_MEM_RD_flop: dflipflop_3
	port map(
		DIN=>ID_EX_RD_out,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>EX_MEM_RD_out);

	Ex_Mem_mem_mux_flop: dflipflop
	port map(
		DIN=> ID_EX_mem_mux_out, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> EX_MEM_mem_mux_out);

	Ex_Mem_MemWrite_flop: dflipflop
	port map(
		DIN=> ID_EX_MemWrite_out, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> EX_MEM_MemWrite_out);

	EX_Mem_Rf_d3_mux_flop: dflipflop_2
	port map(
		DIN=> ID_EX_Rf_d3_mux_out, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> EX_MEM_Rf_d3_mux_out);
	------------------------------------------------Mem-----------------------------

	DMEM_Din_mux: mux2_16 
	port map (
		IN1=> EX_MEM_T2_out,
		IN0=> EX_MEM_T1_out, 
		s=> EX_MEM_mem_mux_out,
		OUTPUT=> DMEM_Data_in);

	MemWrite_bar<= (not EX_MEM_MemWrite_out);

	DMEM: memory   
    generic map (data_width=> 16, addr_width=> 16)
    port map(
    	din=> DMEM_Data_in,
        dout=> DMEM_Data_out,
        rbar=> '0',
        wbar=> MemWrite_bar,
        addrin=> EX_MEM_ALUout);

    LS7: LeftShift
	port map(
		IN1 => EX_MEM_IR_out(8 downto 0),
		OUTPUT1 => LS7_out);

    RF_d3_mux_comp: mux4_16
	port map(
		IN3=> EX_MEM_PC_out,
		IN2=> LS7_out,
		IN1=> DMEM_Data_out,
		IN0=> EX_MEM_ALUout, 
		s=> EX_MEM_Rf_d3_mux_out,
		OUTPUT=> Mem_WB_RF_D3_in);

	--------------------------------MEM/WB------------------------------------
	Mem_WB_RF_D3: dregister
	port map(
		DIN=>Mem_WB_RF_D3_in,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>Mem_WB_RF_D3_out);

	MEM_WB_RD_flop: dflipflop_3
	port map(
		DIN=>EX_MEM_RD_out,
		clk=> clk,
		reset=> reset,
		en=>'1',
		DOUT=>MEM_WB_RD_out);

	MEM_WB_RegWrite_flop: dflipflop
	port map(
		DIN=> EX_MEM_RegWrite_out, 
		clk=> clk,
		reset=> reset,
		en=> '1',
		DOUT=> MEM_WB_RegWrite_out);
	--------------------------------------------------------------------

	

	---------------------------------------------------------------------
	control: control_pipe
	port map(
	clk => clk,
	carry => carry,
	zero => zero,
	valid2 => valid2_signal,
	IF_ID_opcode_bits => IF_ID_IR_out(15 downto 12),
	cz_bits => IF_ID_IR_out(1 downto 0),
	eq_T1_T2 => eq_T1_T2_signal,
	reset => reset,
	IF_ID_Rs1 => IF_ID_Rs1,
	IF_ID_Rs2 => IF_ID_Rs2,
	ID_EX_opcode_bits => ID_EX_IR_out(15 downto 12),
	ID_EX_valid2 => ID_EX_valid2_out,
	ID_EX_RegWrite => ID_EX_RegWrite_out,
	ID_EX_Rd => ID_EX_Rd_out,
	EX_MEM_RegWrite => EX_MEM_RegWrite_out,
	EX_MEM_Rd => EX_MEM_Rd_out,
	MEM_WB_RegWrite => MEM_WB_RegWrite_out,
	MEM_WB_Rd => MEM_WB_Rd_out,

	PC_en => PC_en,
	IF_ID_en => IF_ID_en,
	C_en => C_en,
	Z_en => Z_en,
	RegWrite => RegWrite,
	PC_mux => PC_mux,
	IR_mux => IR_mux,
	BALU2_mux => Balu2_mux,
	Rf_a2_mux => Rf_a2_mux,
	ALU2_mux => ALU2_mux,
	ALU1_mux => ALU1_mux,
	T1_mux => T1_mux,
	T2_mux => T2_mux,
	mem_data_in_mux => mem_data_in_mux,
	Rf_d3_mux => Rf_d3_mux,
	Rf_a3_mux => Rf_a3_mux,
	MemWrite => MemWrite);


	IF_ID_Rs1 <= IF_ID_IR_out(11 downto 9);
	IF_ID_Rs2 <= RF_a2_in;

end behave;
