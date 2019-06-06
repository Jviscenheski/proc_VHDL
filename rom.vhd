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
		0 => "0101111001110000",
		1 => "1101101100011110",
		2 => "0100111001100111",
		3 => "0101111001110000",
		4 => "0100111000110111",
		
		5 => "0100111001000111",
		
		6 => "0101111001110000",
		7 => "1101101110000011",
		8 => "1101101110000100",
		9 => "0100111001000111",
		
		10 => "0101111001110000",
		11 => "0100111001110011",
		12 => "1101101100000001",
		13 => "0100111000110111",
		
		14 => "0010011101100110",
		
		15 => "0100111001010100",
		
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

	