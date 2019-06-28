-- Universidade Tecnológica Federal do Paraná
-- Curso: Engenharia de Computação
-- Disciplina: Arquitetura e Organização de Computadores
-- Professor responsável: Juliano Mourão
-- Referente a: Memória de Dados
-- Alunas: Caroline Rosa e Juliana Rodrigues
-- Curitiba, 17/06/2019

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
 port( clk 		: in std_logic;
	   wr_en 	: in std_logic;
	   endereco : in unsigned(7 downto 0);
	   dado_in 	: in unsigned(7 downto 0);
	   dado_out : out unsigned(7 downto 0)
 );
end entity;
	
architecture a_ram of ram is
	type mem is array (0 to 255) of unsigned(7 downto 0);
	signal conteudo_ram : mem;
begin
	process(clk,wr_en)	
	begin
		if rising_edge(clk) then
			if wr_en='1' then
				conteudo_ram(to_integer(endereco)) <= dado_in;
			end if;
		end if;
	end process;
	dado_out <= conteudo_ram(to_integer(endereco));
end architecture;
