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

entity maquina2estados is
	port( clock  	   : in  std_logic;
		  reset 	   : in  std_logic;
		  estado	   : out unsigned(1 downto 0)
	);
end entity;

architecture a_maquina2estados of maquina2estados is
	signal estado_s : unsigned(1 downto 0);
	
begin
	process(clock,reset) 
	begin
		if reset='1' then
			estado_s <= "00";
		elsif rising_edge(clock) then
			if estado_s="01" then
				estado_s <= "00";
			else
				estado_s <= estado_s+1;
			end if;
		end if;
	end process;
	
	estado <= estado_s;
	
end architecture;


