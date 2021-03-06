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

entity processador is
	port (clk_geral			: in std_logic;						-- parâmetros necessários
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
		  entradaBULATESTE	: out unsigned(7 downto 0);
		  branch_delt 		: out unsigned(3 downto 0);
		  endFinal  		: out unsigned(7 downto 0);
		  memToReg			: out unsigned(1 downto 0);
		  dado_inRAM		: out unsigned(7 downto 0);		  
		  dado_outRAM		: out unsigned(7 downto 0);
		  address_RAM		: out unsigned(7 downto 0)
		  
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
		port(clock  	   	: in  std_logic;
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
		port (clock_geral	 	: in std_logic;
			  wr_enable	   		: in std_logic;
			  reset_geral	 	: in std_logic;
			  stateMachine2		: in unsigned(1 downto 0);
			  commandFromROM	: in unsigned(15 downto 0);
			  jump_enable		: out std_logic;
			  instrucao			: out unsigned(7 downto 0);					-- opcode
			  valor				: out unsigned(7 downto 0);					-- literal que será somado ao valor de um registrador, por exemplo
			  enderecoA			: out unsigned(3 downto 0);					-- A eh DESTINO
			  enderecoB			: out unsigned(3 downto 0);					-- B eh FONTE
			  chosenRegister	: out unsigned(3 downto 0);				
			  jump_adress 		: out unsigned(7 downto 0);
			  isAddress			: out std_logic;
			  branch_delta		: out unsigned(3 downto 0)
	);
	end component;
	
	component ram
		 port( clk 		: in std_logic;
			   wr_en 	: in std_logic;
			   endereco : in unsigned(7 downto 0);
	           dado_in 	: in unsigned(7 downto 0);
	           dado_out : out unsigned(7 downto 0)
	);
	end component;
	
	signal valorRegA, valorRegB							: unsigned(7 downto 0);					-- sinais de saída do banco de registrador
	signal entradaAULA, entradaBULA						: unsigned(7 downto 0);					-- sinais de entrada da ULA
	signal regA, regB, regEscolhido						: unsigned(3 downto 0);					-- saída da ucontrol, indica o endereço do registrador que precisa ser lido
	signal regAbanco, regBbanco, escolhidoBanco			: unsigned(3 downto 0);					-- entradas do banco de registradores
	signal valorLiteral, valorSaidaUCONTROL				: unsigned(7 downto 0);					-- valor a ser armazenado no registrador escolhido, sai da ucontrol
	signal valorInBanco									: unsigned(7 downto 0);					-- sinal que entra no banco de registradores
	signal operacaoULA, resultULA, inFromULA			: unsigned(7 downto 0);					-- saída da ucontrol, com base no opcode e a entrada da ucontrol com resultado da ULA
	signal j_enable, indicaEndereco,Bmaiors				: std_logic;							-- saída da ucontrol, indica se o opcode é uma instrução de jump
	signal operacaoUCONTROL								: unsigned(7 downto 0);
	signal stateMachine3_s, outMaq3						: unsigned(1 downto 0);					-- resultado da máquina de estados de 3 estados
	signal stateMachine2_s, outMaq2						: unsigned(1 downto 0);
	signal entradaPC, saidaPC, entradaROM				: unsigned(7 downto 0);	
	signal comandoUCONTROL								: unsigned(15 downto 0);
	signal dataROM_s									: unsigned(15 downto 0);				-- informação da ROM
	signal proxEndereco_s, jumpAddres					: unsigned(7 downto 0);					-- próximo endereço, atualização do PC
	signal branch_delta									: unsigned(3 downto 0);
	signal endFinalBranch, end_outULA					: unsigned(7 downto 0);
	signal ram_enable, ram_en_temp, pc_en, bancoReg_en, ucontrol_en	: std_logic;
	signal saidaRAM, entradaRAM, enderecoRAM			: unsigned(7 downto 0);
	signal memParaReg									: unsigned(1 downto 0);						-- quando memParaReg for 0 o valueR recebe o valor lido no endereço recebido pela RAM, se for 1, recebe a saída da ULA
	
	begin
	
	bancoReg: bancoReg_8 port map(readRegA => regAbanco,
								  readRegB => regBbanco,
								  valueR => valorLiteral,
								  chosenReg => regEscolhido,
								  wr_enable => bancoReg_en,
								  clock_geral => clk_geral,
								  rst_geral => rst_grl,
								  outRegA => valorRegA,
								  outRegB => valorRegB);
						
	ULAObj: ULA port map( ent1 => entradaAULA,
						  ent2 => entradaBULA,
						  selOpcao => operacaoULA,
					      saida => resultULA,
						  Bmaior => Bmaiors);
								
	romObj: rom port map( clock => clk_geral,
						  endereco => entradaROM,
						  dado => dataROM_s);
	
	pcObj: pc port map(clock => clk_geral,
					   write_enable => pc_en,
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
									wr_enable => ucontrol_en,
									reset_geral => rst_grl,
									stateMachine2 => stateMachine2_s,
									commandFromROM => comandoUCONTROL,
									jump_enable => j_enable,
									instrucao => operacaoUCONTROL,
									valor => valorSaidaUCONTROL,
									enderecoA => regA,
									enderecoB => regB,
									chosenRegister => regEscolhido,
									jump_adress => jumpAddres,
									isAddress => indicaEndereco,
									branch_delta => branch_delta); 
									
	ramObj: ram port map( clk => clk_geral,
						  wr_en => ram_enable,
						  endereco => enderecoRAM,
						  dado_in => entradaRAM,
						  dado_out => saidaRAM);
							
	memParaReg <= outMaq2;

	endFinalBranch <= ("1111" & branch_delta) + saidaPC(7 downto 0);  	-- somando o descolamento delta com meu endereço atual, tenho o endereço destino do branch
	
	-- CONFIGURACAO PC
	entradaPC <= saidaPC + "00000001" when outMaq2 = "0" and j_enable = '0' and Bmaiors = '0' else			-- so incrementa se nao tiver jump
				 jumpAddres when outMaq2 = "0" and j_enable = '1' and Bmaiors = '0' else					-- pula para o endereço do jump se houver
				 endFinalBranch when outMaq2 = "0" and j_enable = '0' and Bmaiors = '1' else							-- pc pula pro endereço do branch
				 saidaPC;					--* saída da maquina em 0: mantem na mesma instrução  *		-- senão, so fica na mesma instrucao

	-- CONFIGURACAO ROM
	entradaROM <= saidaPC;																	-- ROM recebe o endereço da proxima instrucao
	
	-- CONFIGURACAO UCONTROL
	comandoUCONTROL <= dataROM_s;															-- unidade de controle recebe toda a instrucao, com 16 bits
	stateMachine2_s <= outMaq2;																-- controla a unidade de controle 
	
	-- CONFIGURACAO ULA
	entradaAULA <= valorRegA;																				
	entradaBULA <= valorSaidaUCONTROL when operacaoUCONTROL = "11011011" and indicaEndereco = '0' else -- ADD com constante
				   valorSaidaUCONTROL when operacaoUCONTROL = "11010000" else						   -- SUB
				   valorSaidaUCONTROL when operacaoUCONTROL = "11010111" else 						   -- STORE
				   valorRegB when operacaoUCONTROL = "11011011" and indicaEndereco = '1' else		   -- ADD com endereço (o valor do registrador vai para a entrada da ULA)	
				   valorRegB when operacaoUCONTROL = "00100111" else								   -- BRANCH
				   "00000000";
	operacaoULA <= operacaoUCONTROL; -- "11011011" when operacaoUCONTROL = "00100111" and b_enable = '1' else	-- operação de subtração quando for branch	
					 														-- opcode determina a operacao
					
	
	-- VALIDA PARA A INSTRUCAO DE MOV E ADD
	valorLiteral <= resultULA when operacaoUCONTROL = "11011011" or operacaoUCONTROL = "11010000" else 
					valorSaidaUCONTROL when operacaoUCONTROL = "01011110" else 
					valorRegB when operacaoUCONTROL = "01001110" else
					saidaRAM when operacaoUCONTROL = "11010110" else -- (LOAD) valor a ser armezenado no reg vindo da RAM
					"00000000";
					
	escolhidoBanco <= regA when operacaoUCONTROL = "01001110" or operacaoUCONTROL = "01011110" or operacaoUCONTROL = "00100111" else
					  "0111" when operacaoUCONTROL = "11011011"  or operacaoUCONTROL = "11010000" else  
					  "0111" when operacaoUCONTROL = "11010110" else -- (LOAD) coloca o dado adquirido da RAM no acumulador
					  "0000";
	
	-- CONFIGURACAO BANCO REGISTRADORES
	regAbanco <= regA;								
	regBbanco <= regB; 
				 
	regEscolhido <= escolhidoBanco;
	
	-- CONFIGURACAO DA RAM
	ram_enable <= '1' when operacaoUCONTROL = "11010111" else 			-- STORE ativa write enable da RAM
				  '0';
	
	entradaRAM <= valorRegB when operacaoUCONTROL = "11010111" else 			-- (STORE) o dado a ser armazenado na RAM é o dado do REGB
				  "00000000";
				
	enderecoRAM <= 	valorRegA when operacaoUCONTROL = "11010111" or operacaoUCONTROL = "11010110" else 
				   "00000000";
				   
	-- CONFIGURACAO WR_EN PC
	pc_en <= '1';
	ucontrol_en <='1';
	
	
	-- CONFIGURACAO WR_EN DO BANCO DE REGS
	bancoReg_en <= '1' when operacaoUCONTROL = "11011011" or operacaoUCONTROL = "11010110" or operacaoUCONTROL = "11010000" or operacaoUCONTROL = "01011110" or operacaoUCONTROL = "01001110" else
				   '0';
	
	
	--Adicionando os pinos de saída
	saidaBancoA <= valorRegA;
	saidaBancoB <= valorRegB;
	saidaULA <= resultULA;
	dataROM <= dataROM_s;
	proxEndereco <= saidaPC;
	
	-- Adicionando pinos de teste
	chosenRegTESTE <= escolhidoBanco;
	regAUCONTROL <= regA;
	regBUCONTROL <= regB;
	entradaRegABanco <= regAbanco;
	entradaRegBBanco <= regBbanco;
	state <= stateMachine2_s;
	valorEscrito <= valorLiteral;
	operacaoULATESTE <= operacaoULA;
	ehEndereco <= indicaEndereco;
	entradaAULATESTE <= entradaAULA;
	entradaBULATESTE <= entradaBULA;
	branch_delt <= branch_delta;
	endFinal <= endFinalBranch;
	memToReg <= memParaReg;
	dado_inRAM <= entradaRAM;
	dado_outRAM <= saidaRAM;
	address_RAM <= enderecoRAM;
	
end architecture;
	
	
	