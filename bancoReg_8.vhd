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


entity bancoReg_8 is
	port( readRegA  	: in unsigned(3 downto 0);				-- recebe o registrador que será lido
		  readRegB		: in unsigned(3 downto 0);				-- recebe o outro registrador que será lido
		  valueR		: in unsigned(7 downto 0);				-- dado que será escrito em um registrador
		  chosenReg		: in unsigned(3 downto 0);				-- registrador que receberá valueR
		  wr_enable		: in std_logic;							-- habilita escrita em um registrador
		  clock_geral	: in std_logic;							-- estabelece o clock que controlorá o banco de registradores
		  rst_geral		: in std_logic;							-- estabelece reset geral na rapaziada
		  outRegA		: out unsigned(7 downto 0);				-- valor do registrador recebido em readRegA
		  outRegB		: out unsigned(7 downto 0)				-- valor do registrador recebeido em readRegB
	);
end entity;

architecture a_bancoReg_8 of bancoReg_8 is
	component reg8
		port( clock  	   : in  std_logic;
			  reset 	   : in  std_logic;
			  clock_enable : in  std_logic;
			  entrada	   : in  unsigned(7 downto 0);
			  saida		   : out unsigned(7 downto 0)
	);
	end component;
	
	signal inReg0, inReg1, inReg2, inReg3, inReg4, inReg5, inReg6, inReg7			: unsigned(7 downto 0);
	signal outReg0, outReg1, outReg2, outReg3, outReg4, outReg5, outReg6, outReg7	: unsigned(7 downto 0);
	
	begin
		
		-- atribuição de cada registrador
		
		reg0: reg8 port map(clock=>clock_geral, clock_enable=>wr_enable, reset=>rst_geral, entrada=>inReg0, saida=>outReg0);
		reg1: reg8 port map(clock=>clock_geral, clock_enable=>wr_enable, reset=>rst_geral, entrada=>inReg1, saida=>outReg1);
		reg2: reg8 port map(clock=>clock_geral, clock_enable=>wr_enable, reset=>rst_geral, entrada=>inReg2, saida=>outReg2);
		reg3: reg8 port map(clock=>clock_geral, clock_enable=>wr_enable, reset=>rst_geral, entrada=>inReg3, saida=>outReg3);
		reg4: reg8 port map(clock=>clock_geral, clock_enable=>wr_enable, reset=>rst_geral, entrada=>inReg4, saida=>outReg4);
		reg5: reg8 port map(clock=>clock_geral, clock_enable=>wr_enable, reset=>rst_geral, entrada=>inReg5, saida=>outReg5);
		reg6: reg8 port map(clock=>clock_geral, clock_enable=>wr_enable, reset=>rst_geral, entrada=>inReg6, saida=>outReg6);
		reg7: reg8 port map(clock=>clock_geral, clock_enable=>wr_enable, reset=>rst_geral, entrada=>inReg7, saida=>outReg7);
		
		
		-- para escrever em algum registrador
		
		inReg0 <= "00000000" when chosenReg ="0000" and wr_enable='1' else			-- reg0 não pode ser alterado de forma alguma!
				  outReg0;
		inReg1 <= valueR when chosenReg ="0001" and wr_enable='1' else			
				  outReg1;
		inReg2 <= valueR when chosenReg ="0010" and wr_enable='1' else			
				  outReg2;
		inReg3 <= valueR when chosenReg ="0011" and wr_enable='1' else			
				  outReg3;
		inReg4 <= valueR when chosenReg ="0100" and wr_enable='1' else			
				  outReg4;
		inReg5 <= valueR when chosenReg ="0101" and wr_enable='1' else			
				  outReg5;
		inReg6 <= valueR when chosenReg ="0110" and wr_enable='1' else			
				  outReg6;
		inReg7 <= valueR when chosenReg ="0111" and wr_enable='1' else			
				  outReg7;		
		
		-- atribuição das saídas do bloco
		
		outRegA <= outReg0 when readRegA = "0000" else
				   outReg1 when readRegA = "0001" else
				   outReg2 when readRegA = "0010" else
				   outReg3 when readRegA = "0011" else
				   outReg4 when readRegA = "0100" else
				   outReg5 when readRegA = "0101" else
				   outReg6 when readRegA = "0110" else
				   outReg7 when readRegA = "0111" else
				   "00000000";
				   
		outRegB <= outReg0 when readRegB = "0000" else
				   outReg1 when readRegB = "0001" else
				   outReg2 when readRegB = "0010" else
				   outReg3 when readRegB = "0011" else
				   outReg4 when readRegB = "0100" else
				   outReg5 when readRegB = "0101" else
				   outReg6 when readRegB = "0110" else
				   outReg7 when readRegB = "0111" else
				   "00000000";
		
end architecture;
	
	
	