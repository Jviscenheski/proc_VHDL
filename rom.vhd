-- Universidade Tecnológica Federal do Paraná
-- Curso: Engenharia de Computação
-- Disciplina: Arquitetura e Organização de Computadores
-- Professor responsável: Juliano Mourão
-- Referente a: Condicionais e Desvios
-- Alunas: Caroline Rosa e Juliana Rodrigues
-- Curitiba, 31/05/2019

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom is 
	port( clock    : in std_logic;
		  endereco : in unsigned(7 downto 0);
		  dado     : out unsigned(15 downto 0)
	);
end entity;

architecture a_rom of rom is
	type mem is array (0 to 127) of unsigned (15 downto 0);
	constant conteudo_rom : mem := (
		-- endereco => conteudo
		0 => "1101101100000000",
		1 => "1101101100000101",
		2 => "0100111000110111",
		
		--3 => "110110110000000",
		3 => "0101111001110000",
		--3 => "1101101100000010",
		4 => "1101101100001000",
		5 => "0100111001000111",
		
		--6 => "1101101100000000",
		6 => "0101111001110000",
		7 => "1101101110000100",
		8 => "1101101110000011",
		9 => "0100111001010111",
		
		10 => "1101011010000101",
		11 => "1101000010000001",
		12 => "0100111001010111",
		
		13 => "1101110000010100",
		
		14 => "0000000000000000",
		15 => "0000000000000000",
		16 => "0000000000000000",
		17 => "0000000000000000",
		18 => "0000000000000000",
		19 => "0000000000000000",
		20 => "0000000000000000",
		21 => "0000000000000000",
		22 => "0000000000000000",
		23 => "0000000000000000",
		
		24 => "0100111000110101",
		
		25 => "1101110000000110",	
		
		-- abaixo: casos omissos => (zero em todos os bits)
		others => (others=>'0')
	);

begin
	process(clock)
	begin
		if(rising_edge(clock)) then
			dado <= conteudo_rom(to_integer(endereco));
		end if;
	end process;
end architecture;

	