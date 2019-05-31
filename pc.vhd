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

entity pc is
	port( clock  	    : in  std_logic;
		  write_enable  : in  std_logic;
		  reset			: in  std_logic;
		  entrada	    : in  unsigned(7 downto 0);
		  saida		    : out unsigned(7 downto 0)
	);
end entity;

architecture a_pc of pc is

	signal registro, entrada_S : unsigned(7 downto 0);    -- registro é o que sai do PC e entrada_S é o que vai entrar em entrada.. é o mesmo sinal
	
begin
	process(clock,write_enable) -- aciona se mudar algum destes parâmetros
	begin
		if reset='1' then
			registro <= "00000000";
		elsif write_enable='1' then
			if rising_edge(clock) then
				registro <= entrada;									-- atualiza a saída a cada borda de subida do clock
				
			end if;
		end if;
	end process;
	
	saida <= registro;			-- saída real recebe o signal interno criado para manipulação
	
end architecture;	