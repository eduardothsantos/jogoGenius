library ieee;
use ieee.std_logic_1164.all;

entity circuito_exp7 is
port(
	  -- Sinais de entrada
	  clock: 			in  std_logic;
	  reset: 			in  std_logic;
	  iniciar: 			in  std_logic;
	  botoes: 			in  std_logic_vector(3 downto 0);
	  -- Sinais de saida
	  leds: 				out std_logic_vector(3 downto 0);
	  pronto: 			out std_logic;
	  acertou: 			out std_logic;
	  errou: 			out std_logic;
	  -- Sinais de depuracao
	  db_tem_jogada: 	out std_logic;
	  db_jogada: 		out std_logic_vector(6 downto 0);
	  db_contagem: 	out std_logic_vector(6 downto 0);
	  db_memoria: 		out std_logic_vector(6 downto 0);
	  db_limite: 		out std_logic_vector(6 downto 0); --ate onde vai a contagem nessa execucao
	  db_estado: 		out std_logic_vector(6 downto 0);
	  db_timeout:		out std_logic
);
end entity;

architecture atividade1 of circuito_exp7 is

component unidade_controle
	port 
	( 
		clock:     				in  std_logic; 
		reset:     				in  std_logic; 
		iniciar:   				in  std_logic;
		fim:       				in  std_logic;
		igual: 					in  std_logic;
		jogada: 					in	 std_logic;
		limiteMaximo: 			in  std_logic;
		timeout:					in  std_logic;
		treset:					out std_logic;
		tenable:					out std_logic;
		escreve:					out std_logic;
		zera:      				out std_logic;
		conta:     				out std_logic;
		pronto:    				out std_logic;
		registra:				out std_logic;
		acertou: 				out std_logic;
		errou: 					out std_logic;
		incrementaLimite : 	out std_logic;
		zeraLim: 				out std_logic;
		db_estado: 				out std_logic_vector(3 downto 0)
	);
end component;

component fluxo_dados
	port
	(
		clock 				: in  std_logic;
      zerac 				: in  std_logic;
		zeraLim				: in  std_logic;
      contac 				: in  std_logic;
      escrevem 			: in  std_logic;
      chaves 				: in  std_logic_vector(3 downto 0);
		zeraR 				: in  std_logic;
		enableR 				: in  std_logic;
		incrementaLimite	: in  std_logic;
		treset				: in  std_logic;
		tenable				: in  std_logic;
		timeout				: out std_logic;
		limiteMaximo		: out std_logic;
      igual 				: out std_logic;
      fimc 					: out std_logic;
		db_tem_jogada 		: out std_logic;
		jogada_feita 		: out std_logic;
      db_contagem 		: out std_logic_vector(3 downto 0);
      db_memoria 			: out std_logic_vector(3 downto 0);
		db_limite			: out std_logic_vector(3 downto 0);
		db_jogada 			: out std_logic_vector(3 downto 0)
	);
end component;

component hexa7seg
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end component;

signal fimc_FD 			: std_logic;
signal conta_UC 			: std_logic;
signal zera_UC 			: std_logic;
signal igual 				: std_logic;
signal tudo_certo 		: std_logic;
signal jogada_feita_FD	: std_logic;
signal enable				: std_logic;
signal final_UC 			: std_logic;
signal registra_UC		: std_logic;
signal jogada_FD 			: std_logic_vector(3 downto 0);
signal contagem 			: std_logic_vector(3 downto 0);
signal memoria 			: std_logic_vector(3 downto 0);
signal estado 				: std_logic_vector(3 downto 0);
signal jogada				: std_logic_vector(3 downto 0);

signal limite_FD : std_logic_vector (3 downto 0);
signal limMax_FD : std_logic;
signal incLim_UC : std_logic;
signal zeraLim   : std_logic;
signal escrevem  : std_logic;
signal timeout, treset, tenable : std_logic;

begin

G1: fluxo_dados port map
	(
		clock 				=> clock,
		zerac 				=> zera_UC,
		zeraLim        	=> zeraLim,
		contac 				=> conta_UC,
		escrevem 			=> escrevem,
		chaves 				=> botoes,
		zeraR 				=> zeraLim, 
		enableR 				=> registra_UC, 
		incrementaLimite 	=> incLim_UC,
		limiteMaximo   	=> limMax_FD,
		treset				=> treset,
		tenable				=> tenable,
		timeout				=> timeout,
		igual 				=> igual, 
		fimc 					=> fimc_FD,
		db_tem_jogada 		=> db_tem_jogada,
		jogada_feita		=> jogada_feita_FD,
		db_contagem 		=> contagem,
		db_memoria 			=> memoria,
		db_limite      	=> limite_FD,
		db_jogada 			=>	jogada_FD
	);
	
G2: unidade_controle port map
	(
		clock 				=> clock,
		reset 				=> reset,
		iniciar 				=> iniciar,
		fim 					=> fimc_FD,
		igual 				=> igual,
		jogada 				=> jogada_feita_FD,
		limiteMaximo		=> limMax_FD,
		timeout				=> timeout,
		treset				=> treset,
		tenable				=> tenable,
		escreve				=> escrevem,
		zera 					=> zera_UC,
		conta 				=> conta_UC,
		pronto 				=> pronto,
		registra 			=> registra_UC,
		acertou 				=> acertou,
		errou 				=> errou,
		incrementaLimite	=>incLim_UC,
		zeraLim 				=> zeraLim,
		db_estado 			=> estado
	);
db_timeout <= timeout;
G3: hexa7seg port map(hexa=>contagem, 	sseg=>db_contagem);
G4: hexa7seg port map(hexa=>memoria, 	sseg=>db_memoria);
G5: hexa7seg port map(hexa=>estado, 	sseg=>db_estado);
G6: hexa7seg port map(hexa=>jogada_FD, sseg=>db_jogada);
G7: hexa7seg port map(hexa=>limite_FD, sseg=>db_limite);
leds <= jogada_FD;

end architecture;