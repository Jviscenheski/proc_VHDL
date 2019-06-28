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

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is
	component processador
		port (clk_geral			: in std_logic;						-- parâmetros necessários
			  rst_grl			: in std_logic;						-- parâmetros necessários
			  dataROM			: out unsigned(15 downto 0);			-- instrução que vem da ROM
			  proxEndereco		: out unsigned(7 downto 0);			-- habilita atualizacao do PC
			  saidaBancoA		: out unsigned(7 downto 0);
			  saidaBancoB		: out unsigned(7 downto 0);
			  saidaULA			: out unsigned(7 downto 0);
			  -- pinos de teste
			  chosenRegTESTE	: out unsigned(3 downto 0);
			  regAUCONTROL		: out unsigned(3 downto 0);
			  regBUCONTROL		: out unsigned(3 downto 0);
			  state				: out unsigned(1 downto 0);
			  valorEscrito		: out unsigned(7 downto 0);
			  entradaRegABanco	: out unsigned(3 downto 0);
			  entradaRegBBanco	: out unsigned(3 downto 0);
			  operacaoULATESTE	: out unsigned(7 downto 0); 
			  ehEndereco		: out std_logic;
			  entradaAULATESTE	: out unsigned(7 downto 0);
			  entradaBULATESTE	: out unsigned(7 downto 0);
			  branch_delt 		: out unsigned(3 downto 0);
			  endFinal  		: out unsigned(7 downto 0);
			  memToReg			: out unsigned(1 downto 0);
			  dado_inRAM		: out unsigned(7 downto 0);		  
			  dado_outRAM		: out unsigned(7 downto 0);
			  address_RAM		: out unsigned(7 downto 0)	
		);
	end component;
	
	signal write_en, clk_geral, rst_grl, ehEndereco					: std_logic;
	signal dataROM						  	  													: unsigned(15 downto 0);
	signal proxEndereco, saidaBancoA, saidaBancoB, saidaULA, valorEscrito, operacaoULATESTE, entradaAULATESTE, entradaBULATESTE 	: unsigned(7 downto 0);
	
	-- sinais de teste
	signal chosenRegTESTE, regAUCONTROL, regBUCONTROL, entradaRegABanco, entradaRegBBanco		: unsigned(3 downto 0);
	signal state, memToReg											: unsigned(1 downto 0);
	signal branch_delt : unsigned(3 downto 0);
	signal endFinal, dado_outRAM, dado_inRAM, address_RAM: unsigned(7 downto 0);
	
	begin
	
	uut: processador port map ( clk_geral => clk_geral,
								rst_grl => rst_grl,
								dataROM => dataROM,
								proxEndereco => proxEndereco,
								saidaBancoA => saidaBancoA,
								saidaBancoB => saidaBancoB,
								saidaULA => saidaULA,
								chosenRegTESTE => chosenRegTESTE,
								regAUCONTROL => regAUCONTROL,
								regBUCONTROL => regBUCONTROL,
								state => state,
								valorEscrito => valorEscrito,
								entradaRegABanco => entradaRegABanco,
								entradaRegBBanco => entradaRegBBanco, 
								operacaoULATESTE => operacaoULATESTE, 
								ehEndereco => ehEndereco,
								entradaBULATESTE => entradaBULATESTE,
								entradaAULATESTE => entradaAULATESTE,
								branch_delt => branch_delt,
								endFinal => endFinal,
								dado_inRAM => dado_inRAM,
								dado_outRAM	=> dado_outRAM,
								address_RAM => address_RAM,
								memToReg => memToReg);
								
	process
	begin
		clk_geral <= '0';
		wait for 50 ns;
		clk_geral <= '1';
		wait for 50 ns;
	end process;
	
	process
	begin
		rst_grl <= '1';
		wait for 100 ns;
		rst_grl <= '0';
		wait;
	end process;
	
end architecture;