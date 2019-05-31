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

entity reg8 is
	port( clock  	   : in  std_logic;
		  reset 	   : in  std_logic;
		  clock_enable : in  std_logic;
		  entrada	   : in  unsigned(7 downto 0);
		  saida		   : out unsigned(7 downto 0)
	);
end entity;

architecture a_reg8 of reg8 is
	signal registro : unsigned(7 downto 0);
	
begin
	process(clock,reset,clock_enable) --aciona se mudar algum
	begin
		if reset='1' then
			registro <= "00000000";
		elsif clock_enable='1' then
			if rising_edge(clock) then
				registro <= entrada;
			end if;
		end if;
	end process;
	
	saida <= registro;
	
end architecture;

