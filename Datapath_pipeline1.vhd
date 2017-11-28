library std;
use std.standard.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.componentsRISC.all;
--------------------------------------------------

entity datapath is 
	port ( 
		clk : in std_logic;
		reset: in std_logic;
		
		--mem_data_output: in std_logic_vector(15 downto 0);
		
		carry, zero: out std_logic;
		RF_a3_in_dut: out std_logic_vector(2 downto 0);
		valid: out std_logic;
		op_code_bits: out std_logic_vector(3 downto 0);
		cz_bits : out std_logic_vector(1 downto 0);
		eq_T1_T2: out std_logic;
		ALU_data_out_dut, mem_data_out_dut, RF_d1_out_dut, RF_d2_out_dut,RF_d3_in_dut: out std_logic_vector(15 downto 0);
		IR_data_out_dut: out std_logic_vector(15 downto 0)
		---mem_data_input, mem_add_input: out std_logic_vector(15 downto 0)
		);
end entity;

architecture behave of datapath is
	signal RF_a3_in,RF_a2_in,PE_out: std_logic_vector(2 downto 0):="000";
	signal : std_logic_vector(3 downto 0):="0000";
	signal : std_logic_vector(1 downto 0):="00";
	signal : std_logic:='0';
	signal SE10_out,SE7_out,RF_d2_out,RF_d1_out,RF_d3_in,IF_ID_PC_out,IF_ID_IR_out,IF_ID_IR_in,Dec_out,Imem_data_out,RF_d2_out,Balu_out,Palu_out,PC_in,PC_out,Palu_out: std_logic_vector(15 downto 0):="0000000000000000";
	signal : std_logic_vector(15 downto 0);

begin

	PC_mux: mux4_16
	port map(
		IN3=> "0000000000000000",
		IN2=> RF_d2_out,
		IN1=> Balu_out,
		IN0=> Palu_out, 
		s=> ,
		OUTPUT=> PC_in);

	PC: dregister
	port map(
		DIN=>PC_in,
		clk=> clk,
		reset=> reset,
		en=>
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
        wbar=> ,
        addrin=> PC_out );

    IR_mux: mux4_16
	port map(
		IN3=> "0000000000000000",
		IN2=> "1111000000000000",
		IN1=> Dec_out,
		IN0=> Imem_data_out, 
		s=> ,
		OUTPUT=> IF_ID_IR_in);

	--------------------------------------------------------------------
	IF_ID_IR: dregister
	port map(
		DIN=>IF_ID_IR_in,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>IF_ID_IR_out);

	IF_ID_PC: dregister
	port map(
		DIN=>Palu_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>IF_ID_PC_out);
	-------------------------------------------------------------------

	RF_a2_mux: mux2_3  
	port map (
		IN1=> PE_out,
		IN0=> IF_ID_IR_out(8 downto 6), 
		s=> ,
		OUTPUT=> RF_a2_in);

	RF: register_file  
	port map (
		a1=> IF_ID_IR_out(11 downto 9),   --a2 a1 to read the data
		a2=> RF_a2_in,
		a3=> RF_a3_in,   --a3 is the address where data to be written 
		d3=> RF_d3_in,        -- d3 is the daata to write 
		wr=>  ,   
		d1=> RF_d1_out, 
		d2=> RF_d2_out,
		reset=> reset,
		clk=> clock);

	PE: priority   
	port map (
		INPUT=>IF_ID_IR_out(8 downto 0), 
		output=> PE_out,
		valid2=> valid2);

	IR_dec: ir_decoder 
	port map (
		s=> PE_out,
		IR=> IF_ID_IR_out(8 downto 0), 
		new_IR=> Dec_out);

	SE7: SgnExtd7
	port map(
		IN1 => IF_ID_IR_out(8 downto 0),
		OUTPUT1 => SE7_out);
	
	SE10: SgnExtd10
	port map(
		IN1 => IF_ID_IR_out(5 downto 0),
		OUTPUT1 => SE10_out);

signal RF_a3_in,RF_a2_in,PE_out: std_logic_vector(2 downto 0):="000";
	signal : std_logic_vector(3 downto 0):="0000";
	signal : std_logic_vector(1 downto 0):="00";
	signal : std_logic:='0';
	signal Mem_WB_RF_D3_in,Mem_WB_RF_D3_out,SE10_out,SE7_out,RF_d2_out,RF_d1_out,RF_d3_in,IF_ID_PC_out,IF_ID_IR_out,IF_ID_IR_in,Dec_out,
			Imem_data_out,RF_d2_out,Balu_out,Palu_out,PC_in,PC_out,Palu_out: std_logic_vector(15 downto 0):="0000000000000000";
	signal : std_logic_vector(15 downto 0);
	
	ALU_1_mux: mux8_16
	port map (
		IN7=> RF_d2_out,
		IN6=> Mem_WB_RF_D3_out,
		IN5=> Mem_WB_RF_D3_in,
		IN4=> ALU_out,
		IN3=> EX_LS7_out,
		IN2=> ID_EX_PC_out,
		IN1=> ALU_out,
		IN0=> RF_d1_out,
		s=> ,
		OUTPUT=> ID_EX_ALU1_in);

	T1_mux: mux8_16
	port map (
		IN7=> "0000000000000000",
		IN6=> Mem_WB_RF_D3_out,
		IN5=> Mem_WB_RF_D3_in,
		IN4=> ALU_out,
		IN3=> EX_LS7_out,
		IN2=> ID_EX_PC_out,
		IN1=> ALU_out,
		IN0=> RF_d1_out, 
		s=> ,
		OUTPUT=> ID_EX_T1_in);

	ALU_2_mux: mux8_16
	port map (
		IN7=> "0000000000000001",
		IN6=> Mem_WB_RF_D3_out,
		IN5=> Mem_WB_RF_D3_in,
		IN4=> ALU_out,
		IN3=> EX_LS7_out,
		IN2=> ID_EX_PC_out,
		IN1=> SE10_out,
		IN0=> RF_d2_out, 
		s=> ,
		OUTPUT=> ID_EX_ALU2_in);

	T2_mux: mux8_16
	port map (
		IN7=> "0000000000000000",
		IN6=> "0000000000000000",
		IN5=> Mem_WB_RF_D3_out,
		IN4=> Mem_WB_RF_D3_in,
		IN3=> ALU_out,
		IN2=> EX_LS7_out,
		IN1=> ID_EX_PC_out,
		IN0=> RF_d2_out,
		s=> ,
		OUTPUT=> ID_EX_T2_in);

	Balu2_mux: mux2_16 
	port map (
		IN1=> SE10_out,
		IN0=> SE7_out, 
		s=> ,
		OUTPUT=> Balu2_mux_out);

	Balu: alu_adder
	port map(
		D1=>IF_ID_PC_out,
		D2=>Balu2_mux_out,
		OUTPUT=> Balu_out);

	--------------------------------------------------------------------
	ID_EX_IR: dregister
	port map(
		DIN=>IF_ID_IR_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>ID_EX_IR_out);

	ID_EX_PC: dregister
	port map(
		DIN=>IF_ID_PC_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>ID_EX_PC_out);

	ID_EX_PE: dregister
	port map(
		DIN=>PE_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>ID_EX_PE_out);

	ID_EX_ALU1: dregister
	port map(
		DIN=>ID_EX_ALU1_in,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>ID_EX_ALU1_out);

	ID_EX_ALU2: dregister
	port map(
		DIN=>ID_EX_ALU2_in,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>ID_EX_ALU2_out);

	ID_EX_T1: dregister
	port map(
		DIN=>ID_EX_T1_in,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>ID_EX_T1_out);

	ID_EX_ALU2: dregister
	port map(
		DIN=>ID_EX_T2_in,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>ID_EX_T2_out);
	-------------------------------------------------------------------

	ALU_main: alu   
	port map( 
		X=> ID_EX_ALU1_out,
		Y=> ID_EX_ALU2_out,
		op_code_bits => ,                 -- write opcode, ALU to be modified
		cz_bits=> cz_bits_signal, 
		OUTPUT_ALU=> ALU_out,
		carry_ALU =>carry_ALU_out,
		zero_ALU=>zero_ALU_out);

	C: dflipflop  
	port map (DIN=> carry_ALU_out, 
		  clk=> clock,
		  reset=> reset,
		  en=> carry_enable,
		  DOUT=> carry);
		  
	Z: dflipflop  
	port map (DIN=> zero_in, 
		  clk=> clock,
		  reset=> reset,
		  en=> cz_en(0),
		  DOUT=> zero);

	LS7_2:  LeftShift
	port map(
		IN1 => ID_EX_IR_out(8 downto 0),
		OUTPUT1 => EX_LS7_out);

	--------------------------------------------------------------------
	EX_MEM_IR: dregister
	port map(
		DIN=>ID_EX_IR_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>EX_MEM_IR_out);

	EX_MEM_PC: dregister
	port map(
		DIN=>ID_EX_PC_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>EX_MEM_PC_out);

	EX_MEM_PE: dregister
	port map(
		DIN=>ID_EX_PE_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>EX_MEM_PE_out);


	EX_MEM_ALUout: dregister
	port map(
		DIN=>ALU_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>EX_MEM_ALU_out);

	EX_MEM_T1: dregister
	port map(
		DIN=>ID_EX_T1_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>EX_MEM_T1_out);

	EX_MEM_T2: dregister
	port map(
		DIN=>ID_EX_T2_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>EX_MEM_T2_out);
	-------------------------------------------------------------------

	DMEM_Din_mux: mux2_16 
	port map (
		IN1=> EX_MEM_T1_out,
		IN0=> EX_MEM_T2_out, 
		s=> ,
		OUTPUT=> DMEM_Data_in);

	DMEM: memory   
    generic map (data_width=> 16, addr_width=> 16)
    port map(
    	din=> DMEM_Data_in,
        dout=> DMEM_Data_out,
        rbar=> '0',
        wbar=> ,
        addrin=> EX_MEM_ALUout);

    LS7: LeftShift
	port map(
		IN1 => EX_MEM_IR_out(8 downto 0),
		OUTPUT1 => LS7_out);

    IR_mux: mux4_16
	port map(
		IN3=> EX_MEM_PC_out,
		IN2=> LS7_out,
		IN1=> DMEM_Data_out,
		IN0=> EX_MEM_ALUout, 
		s=> ,
		OUTPUT=> Mem_WB_RF_D3_in);

	--------------------------------------------------------------------
	MEM_WB_IR: dregister
	port map(
		DIN=>EX_MEM_IR_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>MEM_WB_IR_out);

	Mem_WB_RF_D3: dregister
	port map(
		DIN=>Mem_WB_RF_D3_in,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>RF_d3_in);

	MEME_WB_PE: dregister
	port map(
		DIN=>EX_MEM_PE_out,
		clk=> clk,
		reset=> reset,
		en=>
		DOUT=>MEM_WB_PE_out);
	------------------------------------------------------------------

	RF_A3_mux: mux4_3
	port map(
		IN3=> MEM_WB_PE_out,
		IN2=> MEM_WB_IR_out(11 downto 9),
		IN1=> MEM_WB_IR_out(8 downto 6),
		IN0=> MEM_WB_IR_out(5 downto 0), 
		s=> ,
		OUTPUT=> RF_a3_in);

end behave;