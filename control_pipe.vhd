library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_pipe is
port(
	carry, zero: in std_logic;
	valid2: in std_logic;
	IF_ID_opcode_bits: in std_logic_vector(3 downto 0);
	cz_bits : in std_logic_vector(1 downto 0);
	eq_T1_T2 : in std_logic;
	reset: in std_logic;
	IF_ID_Rs1, IF_ID_Rs2: in std_logic_vector(2 downto 0);
	ID_EX_opcode_bits: in std_logic_vector(15 downto 0);
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
end control_pipe;

architecture behave of control_pipe is
type op_code_store is (ADD, ADZ, ADC, ADI, NDU, NDC, NDZ, LHI, LW, SW, LM, SM, BEQ, JAL, JLR, NOP);
signal IF_ID_opcode, ID_EX_opcode : op_code_store;
signal FTB: std_logic := '0';

begin
op_code_assign: process (IF_ID_opcode,ID_EX_opcode,cz_bits)
begin
if	(IF_ID_opcode_bits = "0000" and cz_bits ="00") then IF_ID_opcode <= add;
elsif	(IF_ID_opcode_bits = "0000" and cz_bits ="10") then IF_ID_opcode <= adc;
elsif	((IF_ID_opcode_bits = "0000") and (cz_bits ="01")) then IF_ID_opcode <= adz;
elsif	((IF_ID_opcode_bits = "0010") and (cz_bits ="00")) then IF_ID_opcode <= ndu;
elsif	((IF_ID_opcode_bits = "0010") and (cz_bits ="10")) then IF_ID_opcode <= ndc;
elsif	((IF_ID_opcode_bits = "0010") and (cz_bits ="01")) then IF_ID_opcode <= ndz;
elsif  (IF_ID_opcode_bits = "0001") then IF_ID_opcode <= adi;
elsif  (IF_ID_opcode_bits = "0011") then IF_ID_opcode <= lhi;
elsif  (IF_ID_opcode_bits = "0100") then IF_ID_opcode <= lw; 
elsif  (IF_ID_opcode_bits = "0101") then IF_ID_opcode <= sw;
elsif  (IF_ID_opcode_bits = "0110") then IF_ID_opcode <= lm;
elsif  (IF_ID_opcode_bits = "0111") then IF_ID_opcode <= sm;
elsif  (IF_ID_opcode_bits = "1100") then IF_ID_opcode <= beq;
elsif  (IF_ID_opcode_bits = "1000") then IF_ID_opcode <= jal;
elsif  (IF_ID_opcode_bits = "1001") then IF_ID_opcode <= jlr;
elsif  (IF_ID_opcode_bits = "1111") then IF_ID_opcode <= nop;
end if;
if	(ID_EX_opcode_bits = "0000" and cz_bits ="00") then ID_EX_opcode <= add;
elsif	(ID_EX_opcode_bits = "0000" and cz_bits ="10") then ID_EX_opcode <= adc;
elsif	((ID_EX_opcode_bits = "0000") and (cz_bits ="01")) then ID_EX_opcode <= adz;
elsif	((ID_EX_opcode_bits = "0010") and (cz_bits ="00")) then ID_EX_opcode <= ndu;
elsif	((ID_EX_opcode_bits = "0010") and (cz_bits ="10")) then ID_EX_opcode <= ndc;
elsif	((ID_EX_opcode_bits = "0010") and (cz_bits ="01")) then ID_EX_opcode <= ndz;
elsif  (ID_EX_opcode_bits = "0001") then ID_EX_opcode <= adi;
elsif  (ID_EX_opcode_bits = "0011") then ID_EX_opcode <= lhi;
elsif  (ID_EX_opcode_bits = "0100") then ID_EX_opcode <= lw; 
elsif  (ID_EX_opcode_bits = "0101") then ID_EX_opcode <= sw;
elsif  (ID_EX_opcode_bits = "0110") then ID_EX_opcode <= lm;
elsif  (ID_EX_opcode_bits = "0111") then ID_EX_opcode <= sm;
elsif  (ID_EX_opcode_bits = "1100") then ID_EX_opcode <= beq;
elsif  (ID_EX_opcode_bits = "1000") then ID_EX_opcode <= jal;
elsif  (ID_EX_opcode_bits = "1001") then ID_EX_opcode <= jlr;
elsif  (ID_EX_opcode_bits = "1111") then ID_EX_opcode <= nop;
end if;
end process op_code_assign;

output_signals: process(carry,zero,valid2,IF_ID_opcode_bits,cz_bits,eq_T1_T2,reset,IF_ID_Rs1,IF_ID_Rs2,ID_EX_opcode_bits,
	ID_EX_valid2,ID_EX_RegWrite,ID_EX_Rd,EX_MEM_RegWrite,EX_MEM_Rd,MEM_WB_RegWrite,MEM_WB_Rd)
begin

IF_ID_en <= '1';

if(IF_ID_opcode=add) then
	PC_en <= '1';
	C_en <= '1';
	Z_en <= '1';
	RegWrite <= '1';
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=adc) then
	PC_en <= '1';
	C_en <= '1' and carry;
	Z_en <= '1' and carry;
	RegWrite <= '1' and carry;
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=adz) then
	PC_en <= '1';
	C_en <= '1' and zero;
	Z_en <= '1' and zero;
	RegWrite <= '1' and zero;
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=adi) then
	PC_en <= '1';
	C_en <= '1';
	Z_en <= '1';
	RegWrite <= '1';
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "001";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "01";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=ndu) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '1';
	RegWrite <= '1';
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=ndc) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '1' and carry;
	RegWrite <= '1' and carry;
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=ndz) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '1' and zero;
	RegWrite <= '1' and zero;
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=adc) then
	PC_en <= '1';
	C_en <= '1' and carry;
	Z_en <= '1' and carry;
	RegWrite <= '1' and carry;
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=lhi) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '1';
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "10";
	Rf_a3_mux <= "10";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=lw) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '1';
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "001";
	ALU1_mux <= "111";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "01";
	Rf_a3_mux <= "10";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=sw) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '0';
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "001";
	ALU1_mux <= "111";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '1';
end if;

if(IF_ID_opcode=lm) then
	PC_en <= not valid2;
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '1';
	PC_mux <= "00";
	if (valid2='1') then IR_mux <= "01"; else IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "111";
	if (FTB='0') then ALU1_mux <= "001"; else ALU1_mux <= "000";
	if (FTB='0') then T1_mux <= "001"; else T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "01";
	Rf_a3_mux <= "11";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=sm) then
	PC_en <= not valid2;
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '0';
	PC_mux <= "00";
	if (valid2='1') then IR_mux <= "01"; else IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '1';
	ALU2_mux <= "111";
	if (FTB='0') then ALU1_mux <= "001"; else ALU1_mux <= "000";
	if (FTB='0') then T1_mux <= "001"; else T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '1';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '1';
end if;

if(IF_ID_opcode=beq) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '0';
	if (eq_T1_T2='1') then PC_mux <= "01"; else PC_mux <= "00";
	if (eq_T1_T2='1') then IR_mux <= "10"; else IR_mux <= "00";
	BALU2_mux <= '1';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=jal) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '1';
	PC_mux <= "01";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "11";
	Rf_a3_mux <= "10";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=jlr) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '1';
	PC_mux <= "10";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "11";
	Rf_a3_mux <= "10";
	MemWrite <= '0';
end if;

if(IF_ID_opcode=nop) then
	PC_en <= '1';
	C_en <= '0';
	Z_en <= '0';
	RegWrite <= '0';
	PC_mux <= "00";
	IR_mux <= "00";
	BALU2_mux <= '0';
	Rf_a2_mux <= '0';
	ALU2_mux <= "000";
	ALU1_mux <= "000";
	T1_mux <= "000";
	T2_mux <= "000";
	mem_data_in_mux <= '0';
	Rf_d3_mux <= "00";
	Rf_a3_mux <= "00";
	MemWrite <= '0';
end if;

--Hazard conditions
--Make difference between ALU1 and T1

if ((ID_EX_RegWrite='1') and (IF_ID_Rs1=ID_EX_Rd) and (ID_EX_opcode/=lw)) then
	if (ID_EX_opcode=jal or ID_EX_opcode=jlr) then 
		ALU1_mux <= "010";
		T1_mux <= "010";
	elsif (ID_EX_opcode=lhi) then 
		ALU1_mux <= "011";
		T1_mux <= "011";
	else
		ALU1_mux <= "100";
		T1_mux <= "100";
	end if;
end if;



end process;
end behave;