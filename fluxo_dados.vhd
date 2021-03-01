library ieee;
use ieee.std_logic_1164.all;

entity fluxo_dados is
	port
	(
		clock: 				in  std_logic;
      zerac: 				in  std_logic;
		zeraLim: 			in  std_logic;
      contac: 				in  std_logic;
      escrevem: 			in  std_logic;
      chaves: 				in  std_logic_vector(3 downto 0);
		zeraR: 				in  std_logic;
		enableR: 			in  std_logic;
		incrementaLimite: in  std_logic;
		treset:				in  std_logic;
		tenable:				in  std_logic;
		timeout:				out std_logic;
		limiteMaximo: 		out std_logic;
      igual: 				out std_logic;
      fimc: 				out std_logic;
		db_tem_jogada: 	out std_logic;
		jogada_feita: 		out std_logic;
      db_contagem: 		out std_logic_vector(3 downto 0);
      db_memoria: 		out std_logic_vector(3 downto 0);
		db_limite:			out std_logic_vector(3 downto 0);
		db_jogada:			out std_logic_vector(3 downto 0)
	);
end entity;

architecture dataflow of fluxo_dados is
component contador_163
   port (
        clock : in  std_logic;
        clr   : in  std_logic;
        ld    : in  std_logic;
        ent   : in  std_logic;
        enp   : in  std_logic;
        D     : in  std_logic_vector (3 downto 0);
		  limite: in  std_logic_vector (3 downto 0);
        Q     : out std_logic_vector (3 downto 0);
        rco   : out std_logic 
   );
end component;

component comparador_85
  port (
    i_A3   : in  std_logic;
    i_B3   : in  std_logic;
    i_A2   : in  std_logic;
    i_B2   : in  std_logic;
	 i_A1   : in  std_logic;
    i_B1   : in  std_logic;
    i_A0   : in  std_logic;
    i_B0   : in  std_logic;
    i_AGTB : in  std_logic;
    i_ALTB : in  std_logic;
    i_AEQB : in  std_logic;
    o_AGTB : out std_logic;
    o_ALTB : out std_logic;
    o_AEQB : out std_logic
  );
end component;

component ram_16x4
   port (
		clk				: in  std_logic;
      endereco     	: in  std_logic_vector(3 downto 0);
      dado_entrada 	: in  std_logic_vector(3 downto 0);
      we           	: in  std_logic;
      ce           	: in  std_logic;
      dado_saida   	: out std_logic_vector(3 downto 0)
    );
end component;

component registrador_4bits
	port 
	(
		clock : in std_logic;
		clear : in std_logic;
		enable : in std_logic;
		D : in std_logic_vector(3 downto 0);
		Q : out std_logic_vector(3 downto 0)
	);
end component;

component edge_detector
	port 
	(
		clock : in std_logic;
		reset : in std_logic;
		sinal : in std_logic;
		pulso : out std_logic
	);
end component;
component timer5k is
   port 
	(
	  clock 		: in  std_logic;
	  clr   		: in  std_logic; -- ativo em alto
	  enable		: in  std_logic;
	  Q     		: out std_logic_vector (13 downto 0);
	  timeout	: out std_logic 
   );
end component;

signal s_endereco : std_logic_vector(3 downto 0);
signal s_dados: std_logic_vector(3 downto 0);
signal or_jogada : std_logic;
signal nzerac : std_logic;
signal nzeraLim: std_logic;
signal limite : std_logic_vector (3 downto 0);
signal tem_jogada_feita: std_logic;
signal not_escrevem : std_logic;
begin
nzerac <= not zerac;
nzeraLim <= not zeraLim;
not_escrevem <= not escrevem;

or_jogada <= chaves(0) or chaves(1) or chaves(2) or chaves(3);

G1: contador_163 port map(
        clock => clock,
        clr   => nzerac,
        ld    => '1',
        ent   => contac,
        enp   => contac,
        D     => "0000",
		  limite=> limite,
        Q     => s_endereco,
        rco   => fimc);
		  
GLim: contador_163 port map(
        clock => clock,
        clr   => nzeraLim,
        ld    => '1',
        ent   => incrementaLimite,
        enp   => incrementaLimite,
        D     => "0000",
		  limite=> "1111",
        Q     => limite,
        rco   => limiteMaximo);

G2: comparador_85 port map(
            i_A3   => s_dados(3),
            i_B3   => chaves(3),
            i_A2   => s_dados(2),
            i_B2   => chaves(2),
            i_A1   => s_dados(1),
            i_B1   => chaves(1),
            i_A0   => s_dados(0),
            i_B0   => chaves(0),
            i_AGTB => '0',
            i_ALTB => '0',
            i_AEQB => '1',
            o_AGTB => open,
				o_ALTB => open,
            o_AEQB => igual);

G3: ram_16x4 port map(
		clk				=> clock,
		endereco     	=> s_endereco,
		dado_entrada 	=> chaves,
		we           	=> not_escrevem,
		ce           	=> '0',
		dado_saida   	=> s_dados);
		 
G4 : edge_detector port map
	(
		clock => clock,
		reset => '0',
		sinal => or_jogada,
		pulso => tem_jogada_feita
	);

G5 : registrador_4bits port map
	(
		clock => clock,
		clear => zeraR,
		enable => enableR,
		D => s_endereco,
		Q => db_jogada
	);
G6 : timer5k port map
	(
		clock 	=> clock,
		clr 		=> treset,
		enable	=> tenable,
		Q			=> open,
		timeout 	=> timeout
	);
	
db_tem_jogada <= tem_jogada_feita;
jogada_feita <= tem_jogada_feita;
db_contagem <= s_endereco;
db_memoria <= s_dados;
db_limite <= limite;

end architecture;