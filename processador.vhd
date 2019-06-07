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

entity processador is
	port (write_en			: in std_logic;						-- parâmetros necessários
		  clk_geral			: in std_logic;						-- parâmetros necessários
		  rst_grl			: in std_logic;						-- parâmetros necessários
		  dataROM			: out unsigned(15 downto 0);		-- instrução que vem da ROM
		  proxEndereco		: out unsigned(7 downto 0);			-- atualizacao do PC
		  saidaBancoA		: out unsigned(7 downto 0);
		  saidaBancoB		: out unsigned(7 downto 0);
		  saidaULA			: out unsigned(7 downto 0);
		  ---- pinos de teste
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
		  entradaBULATESTE	: out unsigned(7 downto 0)
	);
end;

architecture a_processador of processador is
	component bancoReg_8
		port(readRegA  			: in unsigned(3 downto 0);				-- recebe o registrador que será lido
			 readRegB		: in unsigned(3 downto 0);				-- recebe o outro registrador que será lido
			 valueR			: in unsigned(7 downto 0);				-- dado que será escrito em um registrador
			 chosenReg		: in unsigned(3 downto 0);				-- registrador que receberá valueR
			 wr_enable		: in std_logic;							-- habilita escrita em um registrador
			 clock_geral	: in std_logic;							-- estabelece o clock que controlorá o banco de registradores
			 rst_geral		: in std_logic;							-- estabelece reset geral na rapaziada
			 outRegA		: out unsigned(7 downto 0);				-- valor do registrador recebido em readRegA
			 outRegB		: out unsigned(7 downto 0)				-- valor do registrador recebeido em readRegB
	);
	end component;
	
	component ULA
		port(ent1, ent2		: in unsigned (7 downto 0);
			 selOpcao		: in unsigned (7 downto 0);					-- operação que será realizada pela ULA, vem do Ucontrol
			 saida			: out unsigned (7 downto 0);
			 Bmaior			: out std_logic
	);
	end component;
	
	component rom
		port(clock    	: in std_logic;
			 endereco 	: in unsigned(7 downto 0);
			 dado     	: out unsigned(15 downto 0)
	);
	end component;
	
	component pc
		port(clock  	    	: in  std_logic;
			 write_enable  	: in  std_logic;
			 reset			: in  std_logic;
			 entrada	    : in  unsigned(7 downto 0);
			 saida		    : out unsigned(7 downto 0)
	);
	end component;	
	
	component maquina3estados
		port(clock  	   	: in  std_logic;
			 reset 	   		: in  std_logic;
			 estado	   		: out unsigned(1 downto 0)
	);
	end component;
	
	component maquina2estados
		port(clock  	   	: in  std_logic;
			 reset 	   		: in  std_logic;
			 estado	   		: out unsigned(1 downto 0)
	);
	end component;
	
	component ucontrol
		port ( clock_geral	 	: in std_logic;
		   wr_enable	   	: in std_logic;
		   reset_geral	 	: in std_logic;
		   stateMachine2	: in unsigned(1 downto 0);
		   commandFromROM	: in unsigned(15 downto 0);
		   --returnFromULA	: in unsigned(7 downto 0);
		   jump_enable		: out std_logic;
		   instrucao		: out unsigned(7 downto 0);					-- opcode
		   valor			: out unsigned(7 downto 0);					-- literal que será somado ao valor de um registrador, por exemplo
		   enderecoA		: out unsigned(3 downto 0);					-- A eh DESTINO
		   enderecoB		: out unsigned(3 downto 0);					-- B eh FONTE
		   chosenRegister	: out unsigned(3 downto 0);				
		   jump_adress 		: out unsigned(7 downto 0);
		   isAddress		: out std_logic;
		   branch_delta		: out unsigned(3 downto 0);
		   branch_enable	: out std_logic
	);
	end component;
	
	signal valorRegA, valorRegB						: unsigned(7 downto 0);					-- sinais de saída do banco de registrador
	signal entradaAULA, entradaBULA					: unsigned(7 downto 0);					-- sinais de entrada da ULA
	signal regA, regB, regEscolhido					: unsigned(3 downto 0);					-- saída da ucontrol, indica o endereço do registrador que precisa ser lido
	signal regAbanco, regBbanco, escolhidoBanco		: unsigned(3 downto 0);					-- entradas do banco de registradores
	signal valorLiteral, valorSaidaUCONTROL			: unsigned(7 downto 0);					-- valor a ser armazenado no registrador escolhido, sai da ucontrol
	signal valorInBanco								: unsigned(7 downto 0);					-- sinal que entra no banco de registradores
	signal operacaoULA, resultULA, inFromULA		: unsigned(7 downto 0);					-- saída da ucontrol, com base no opcode e a entrada da ucontrol com resultado da ULA
	signal j_enable, b_enable, indicaEndereco,Bmaior: std_logic;							-- saída da ucontrol, indica se o opcode é uma instrução de jump
	signal operacaoUCONTROL							: unsigned(7 downto 0);
	signal stateMachine3_s, outMaq3					: unsigned(1 downto 0);					-- resultado da máquina de estados de 3 estados
	signal stateMachine2_s, outMaq2					: unsigned(1 downto 0);
	signal entradaPC, saidaPC, entradaROM			: unsigned(7 downto 0);	
	signal comandoUCONTROL							: unsigned(15 downto 0);
	signal dataROM_s								: unsigned(15 downto 0);				-- informação da ROM
	signal proxEndereco_s, jumpAddres				: unsigned(7 downto 0);					-- próximo endereço, atualização do PC
	signal branch_delta								: unsigned(3 downto 0);
	
	begin
	
	bancoReg: bancoReg_8 port map(readRegA => regAbanco,
								  readRegB => regBbanco,
								  valueR => valorLiteral,
								  chosenReg => regEscolhido,
								  wr_enable => write_en,
								  clock_geral => clk_geral,
								  rst_geral => rst_grl,
								  outRegA => valorRegA,
								  outRegB => valorRegB);
						
	ULAObj: ULA port map( ent1 => entradaAULA,
						  ent2 => entradaBULA,
						  selOpcao => operacaoULA,
					      saida => resultULA,
						  Bmaior => Bmaior);
								
	romObj: rom port map( clock => clk_geral,
						  endereco => entradaROM,
						  dado => dataROM_s);
	
	pcObj: pc port map(clock => clk_geral,
					   write_enable => write_en,
					   reset => rst_grl,
					   entrada => entradaPC,
					   saida => saidaPC);
					   
	maquina3bj: maquina3estados port map(clock => clk_geral,
										 reset => rst_grl,
										 estado => outMaq3); 
										 
	maquina2bj: maquina2estados port map(clock => clk_geral,
										 reset => rst_grl,
										 estado => outMaq2); 
								  
	ucontrolObj: ucontrol port map( clock_geral => clk_geral,
									wr_enable => write_en,
									reset_geral => rst_grl,
									stateMachine2 => stateMachine2_s,
									commandFromROM => comandoUCONTROL,
									--returnFromULA => inFromULA,
									jump_enable => j_enable,
									instrucao => operacaoUCONTROL,
									valor => valorSaidaUCONTROL,
									enderecoA => regA,
									enderecoB => regB,
									chosenRegister => regEscolhido,
									jump_adress => jumpAddres,
									isAddress => indicaEndereco,
									branch_enable => b_enable,
									branch_delta => branch_delta); 
									
	-- CONFIGURACAO PC
	entradaPC <= saidaPC + "00000001" when outMaq2 = "1" and j_enable = '0' and b_enable = '0' else			-- so incrementa se nao tiver jump
				 jumpAddres when outMaq2 = "1" and j_enable = '1' and b_enable = '0' else					-- pula para o endereço do jump se houver
				 resultULA when j_enable = '0' and b_enable = '1' else							-- pc pula pro endereço do branch
				 saidaPC;					--* saída da maquina em 0: mantem na mesma instrução  *		-- senão, so fica na mesma instrucao

	-- CONFIGURACAO ROM
	entradaROM <= saidaPC;																	-- ROM recebe o endereço da proxima instrucao
	
	-- CONFIGURACAO UCONTROL
	comandoUCONTROL <= dataROM_s;															-- unidade de controle recebe toda a instrucao, com 16 bits
	stateMachine2_s <= outMaq2;																-- controla a unidade de controle 
	
	-- CONFIGURACAO ULA
	entradaAULA <= valorRegA;																				
	entradaBULA <= valorSaidaUCONTROL when operacaoUCONTROL = "11011011" and indicaEndereco = '0' else
				   valorSaidaUCONTROL when operacaoUCONTROL = "11010000" else
				   valorRegB when operacaoUCONTROL = "11011011" and indicaEndereco = '1' else					-- o valor do registrador vai para a entrada da ULA	
				   valorRegB when operacaoUCONTROL = "00100111" else
				   "00000000";
	operacaoULA <= "11011011" when operacaoUCONTROL = "00100111" else	-- operação de subtração quando for branch	
					operacaoUCONTROL; 									-- opcode determina a operacao
					
	
	-- VALIDA PARA A INSTRUCAO DE MOV E ADD
	valorLiteral <= resultULA when operacaoUCONTROL = "11011011" or operacaoUCONTROL = "11010000" else
					valorSaidaUCONTROL when operacaoUCONTROL = "01011110" else --or operacaoUCONTROL = "01001110" else
					valorRegB when operacaoUCONTROL = "01001110" or operacaoUCONTROL="11010110" else
					"00000000";
	escolhidoBanco <= regA when operacaoUCONTROL = "01001110" or operacaoUCONTROL = "01011110" or operacaoUCONTROL="11010110" or operacaoUCONTROL = "00100111" else
					  "0111" when operacaoUCONTROL = "11011011"  or operacaoUCONTROL = "11010000" else  
					  "0000";
	
	-- CONFIGURACAO BANCO REGISTRADORES
	regAbanco <= regA;								
	regBbanco <= saidaPC-1 when b_enable = '1' else
				 regB;
	regEscolhido <= escolhidoBanco;
	
	-- VALIDA PARA A INSTRUCAO DE ADD
	
	--Adicionando os pinos de saída
	saidaBancoA <= valorRegA;
	saidaBancoB <= valorRegB;
	saidaULA <= resultULA;
	dataROM <= dataROM_s;
	proxEndereco <= saidaPC;
	
	-- Adicionando pinos de teste
	chosenRegTESTE	<= escolhidoBanco;
	regAUCONTROL	<= regA;
	regBUCONTROL	<= regB;
	entradaRegABanco <= regAbanco;
	entradaRegBBanco <= regBbanco;
	state 			<= stateMachine2_s;
	valorEscrito	<= valorLiteral;
	operacaoULATESTE<= operacaoULA;
	ehEndereco		<= indicaEndereco;
	entradaAULATESTE	<= entradaAULA;
	entradaBULATESTE	<= entradaBULA;
	
end architecture;
	
	
	