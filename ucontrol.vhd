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

entity ucontrol is
	port ( clock_geral	 	: in std_logic;
		   wr_enable	   	: in std_logic;
		   reset_geral	 	: in std_logic;
		   stateMachine2	: in unsigned(1 downto 0);
		   commandFromROM	: in unsigned(15 downto 0);
		   jump_enable		: out std_logic;
		   instrucao		: out unsigned(7 downto 0);					-- opcode
		   valor			: out unsigned(7 downto 0);					-- literal que será somado ao valor de um registrador, por exemplo
		   enderecoA		: out unsigned(3 downto 0);					-- A eh DESTINO
		   enderecoB		: out unsigned(3 downto 0);					-- B eh FONTE
		   chosenRegister	: out unsigned(3 downto 0);				
		   jump_adress 		: out unsigned(7 downto 0);
		   branch_delta		: out unsigned(3 downto 0);
		   isAddress		: out std_logic
		   
	);
end entity;

architecture a_ucontrol of ucontrol is
	component pc
		port( clock  	    : in  std_logic;
			  write_enable  : in  std_logic;
			  reset			: in  std_logic;
			  entrada	    : in  unsigned(7 downto 0);
			  saida		    : out unsigned(7 downto 0)
	);
	end component;
	
	component rom
		port( clock    : in std_logic;
			  endereco : in unsigned(7 downto 0);
			  dado     : out unsigned(15 downto 0)
	);
	end component;
	
	component maquina2estados
		port( clock  	   : in  std_logic;
			  reset 	   : in  std_logic;
			  estado	   : out unsigned(1 downto 0)
	);
	end component;
	
	component ula
		port(ent1, ent2	: in unsigned (7 downto 0);
			 selOpcao	: in unsigned (7 downto 0);			-- operação que será realizada pela ULA, vem do Ucontrol
			 saida		: out unsigned(7 downto 0);
			 end_out	: out unsigned(7 downto 0);
			 Bmaior		: out std_logic
	);
	end component;
	
	signal valorIntermediario						: unsigned(7 downto 0);
	signal outMaq				  					: unsigned(1 downto 0);	
	signal instrucao_s								: unsigned(7 downto 0);
	signal notAdress, complemento					: unsigned(7 downto 0);
	signal b_address								: unsigned(3 downto 0);
	signal regBranch, endereco_ram					: unsigned(7 downto 0);
	signal ent1s, ent2s, selOpcaos, saidas			: unsigned(7 downto 0);
	signal bmaiors									: std_logic;
	--signal isAddress_s							: std_logic;
	
	begin
	
	maquina2estadosObj: maquina2estados port map( clock => clock_geral,
												  reset => reset_geral,
												  estado => outMaq);
												  
	ulaObj: ula port map( ent1 => ent1s,
						  ent2 => ent2s,
						  selOpcao => selOpcaos,
						  saida => saidas,
						  end_out => endereco_ram,
						  Bmaior => bmaiors);

						   
	instrucao_s <= commandFromROM(15 downto 8) when outMaq = "0" else
				 "00000000";	
				 -- recolhe o opcode, 8 bits mais significativos
	instrucao <= instrucao_s;
	

					 
	b_address <= commandFromROM(3 downto 0) when instrucao_s="00100111" else --endereço do registrador com o valor que vamos comparar
				 "0000";
					 
	branch_delta <= b_address;
	
	regBranch <= "0000" & commandFromROM(7 downto 4) when instrucao_s="00100111" else
				 "00000000";
	
					 
	
	jump_enable <= '1' when instrucao_s="11011100" and outMaq = "0" else											-- se for uma instrução de jump, o jumpEnable pode ser ativado
				   '0';
				  
	jump_adress <= commandFromROM(7 downto 0) when instrucao_s="11011100" and outMaq = "0" else					-- em uma instrução de jump, o endereço para o salto corresponde aos 8 bits menos significativos
				   "00000000";
				  
	valorIntermediario <= commandFromROM(7 downto 0) when commandFromROM(15 downto 7)="110110110" and outMaq = "0" else	-- quando for uma instrução adicionando uma constante no acumulador 
					      commandFromROM(7 downto 0) when commandFromROM(15 downto 8)="01011110" else
						  commandFromROM(7 downto 0) when commandFromROM(15 downto 8)="11010000" and outMaq = "0" else
						  "00000000";																		

	isAddress <= '1' when commandFromROM(15 downto 7)="110110111" else
				 '0';
				 
	valor <=  "01111111" and valorIntermediario when commandFromROM(15 downto 8)="11011011" or commandFromROM(15 downto 8)="11010000" else -- ADD E SUB
			  "00001111" and valorIntermediario when commandFromROM(15 downto 8)="01011110" else -- MOVA
			  commandFromROM(7 downto 0) when commandFromROM(15 downto 8) = "11010111" else
			  "00000000";	 		  
	
	enderecoA <= commandFromROM(7 downto 4) when commandFromROM(15 downto 8)="01001110"  else								-- terceiro grupo de 4 bits quando é um MOV
				 --commandFromROM(7 downto 4) when commandFromROM(15 downto 8)="00100111" and b_enable='1' else				-- valor do deslocamente delta no branch
				 "0111" when (commandFromROM(15 downto 8)="11011011") or (commandFromROM(15 downto 8)="11010000") or (commandFromROM(15 downto 8)="01011110") or (commandFromROM(15 downto 8)="11010110") or (commandFromROM(15 downto 8)="00100111") else	-- endereço do acumulador quando é um add, porque o add só é feito no acumulador
				 "0111" when commandFromROM(15 downto 8) = "11010111" else --STORE STA
				 "0000";

	enderecoB <= commandFromROM(3 downto 0) when commandFromROM(15 downto 8)="01001110" or commandFromROM(15  downto 8)="11010110" else				-- 4 últimos bits em caso de MOV
				 commandFromROM(3 downto 0) when commandFromROM(15 downto 7)="110110111" or commandFromROM(15 downto 8)="11010000" else
				 commandFromROM(7 downto 4) when commandFromROM(15 downto 8)="00100111" else														-- reg6 com o número pra comparar e ver se faz branch
				 "0000"; 
				 
	chosenRegister <= "0111" when commandFromROM(15 downto 8)="11011011" or commandFromROM(15 downto 8)="01011110" or commandFromROM(15 downto 8)="11010110" or commandFromROM(15 downto 8)="11010000" else
					  commandFromROM(7 downto 4) when commandFromROM(15 downto 8)="01001110"  else	-- endereço destino quando é um MOV
					  "0000";
					  
					 
end architecture;
						
	
	