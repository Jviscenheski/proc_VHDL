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

entity ULA is
	port(ent1, ent2	: in unsigned (7 downto 0);
		 selOpcao	: in unsigned (7 downto 0);			-- operação que será realizada pela ULA, vem do Ucontrol
		 saida		: out unsigned(7 downto 0);
		 Bmaior		: out std_logic
	);
end entity;

architecture a_ULA of ULA is 
begin
	
    saida <= ent1+ent2 when selOpcao="11011011" else 	-- add
			 ent1-ent2 when selOpcao="11010000" else	-- sub
			 ent2	   when selOpcao="01011110" else	-- MOVA A,valor
			 --ent1 	   when selOpcao="11010111" else	-- valor pra armazenar na RAM (STORE)
			 "00000000";
			 
	Bmaior <= '1' when ent1 < ent2 and selOpcao="00100111" else
			  '0';
end architecture;

			  
			 
			 
			 


