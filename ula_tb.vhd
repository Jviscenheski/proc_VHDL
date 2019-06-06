-- Universidade Tecnológica Federal do Paraná
-- Curso: Engenharia de Computação
-- Disciplina: Arquitetura e Organização de Computadores
-- Professor responsável: Juliano Mourão
-- Referente a: ULA - projeto de laboratório
-- Alunas: Caroline Rosa e Juliana Rodrigues
-- Curitiba, 25/04/2019

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA_tb2 is
end;

architecture a_ULA_tb2 of ULA_tb2 is
	component ULA
		port(ent1, ent2								: in unsigned (15 downto 0);
			 selOpcao								: in unsigned (2 downto 0);
			 saida									: out unsigned (15 downto 0)
			 --primeiroMaior, isZero					: out std_logic
	);
	end component;
	
	signal ent1, ent2, saida				: unsigned(15 downto 0);
	signal selOpcao							: unsigned(2 downto 0);
	--signal primeiroMaior, isZero			: std_logic;
	
	
	begin
		uut: ULA port map (ent1 => ent1,
						   ent2 => ent2,
						   selOpcao => selOpcao,
						   saida => saida);
						   --primeiroMaior => primeiroMaior,
						   --isZero => isZero);
	
	process
	begin
		ent1 <= "0000000000000001";
		ent2 <= "0000000000000010";
		selOpcao <= "000";		-- soma
		wait for 50 ns;
		ent1 <= "0000000000011111";
		ent2 <= "0000000000000010";
		selOpcao <= "001";		-- subtração com ent1>ent2
		wait for 50 ns;
		ent1 <= "0000000000011111";
		ent2 <= "0000000001111110";
		selOpcao <= "001";		-- subtração com ent1<ent2
		wait for 50 ns;
		ent1 <= "0000011000000001";
		ent2 <= "0000000000111010";
		selOpcao <= "010";		-- divisão
		wait for 50 ns;
		ent1 <= "1111111100000001";
		ent2 <= "0000111100000010";
		selOpcao <= "011";		-- ent1>ent2 - True
		wait for 50 ns;
		ent1 <= "0000000000000001";
		ent2 <= "0000111100000010";
		selOpcao <= "011";		-- ent1>ent2 - False
		wait for 50 ns;
		ent1 <= "0000000000110001";
		ent2 <= "0000000011000000";
		selOpcao <= "100";		-- ent2>ent1 - True
		wait for 50 ns;
		ent1 <= "1111111100000001";
		ent2 <= "0000111100000010";
		selOpcao <= "100";		-- ent2>ent1 - Fale
		wait for 50 ns;
		ent1 <= "0011011000110001";
		ent2 <= "0011011000110001";
		selOpcao <= "101";		-- ent1=ent2 - True
		wait for 50 ns;
		ent1 <= "0000000000000000";
		ent2 <= "0000000011000000";
		selOpcao <= "101";		-- ent1=ent2 - False
		wait for 50 ns;	
		ent1 <= "0000000000000110";
		ent2 <= "0000000000001000";
		selOpcao <= "001";		-- subtração com ent1>ent2
		wait for 50 ns;
		wait;
	end process;
end architecture;
		
		
						   
	