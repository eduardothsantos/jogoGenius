library ieee;
use ieee.std_logic_1164.all;

entity unidade_controle is 
	port 
	( 
		clock:     				in  std_logic; 
		reset:     				in  std_logic; 
		iniciar:   				in  std_logic;
		fim:       				in  std_logic;
		igual: 					in  std_logic;
		jogada: 					in	 std_logic;
		limiteMaximo:			in  std_logic;
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
		incrementaLimite: 	out std_logic;
		zeraLim: 				out std_logic;
		db_estado: 				out std_logic_vector(3 downto 0)
	);
end entity;

architecture fsm of unidade_controle is
  type t_estado is (Aguarda, --estado inicial
						  Prepara, --inicia circuito para condicoes iniciais
						  InicioCiclo, --inicio de novo ciclo, aguardando
						  EsperaJogada, --esperado edge_detector detectar jogada
						  ArmazenaJogada, --armazena jogada
						  ComparaJogada, --compara jogada com memoria
						  AcertouJogada,
						  ErrouJogada,
						  CicloCerto,--chegamos no limite atual
						  CicloErrado,--erramos jogada
						  TerminouCerto,
						  TerminouErrado,
						  AumentaLimite,
						  EsperaEscrita,
						  ResetContador,
						  EscreveJogada);
  signal Eatual, Eprox: t_estado;
  signal certo : std_logic;
  
begin
  -- memoria de estado
  process (clock,reset)
  begin
    if reset='1' then
      Eatual <= Aguarda;
		certo <= '1';
    elsif clock'event and clock = '1' then
		Eatual <= Eprox; 
		certo <= igual;
    end if;
  end process;

  -- logica de proximo estado
  Eprox <=
      Aguarda when  Eatual=Aguarda and iniciar='0' else
      Prepara when  Eatual=Aguarda and iniciar='1' else 
		Prepara when  (Eatual=TerminouCerto or Eatual=TerminouErrado) and iniciar='1' else  
		EsperaEscrita when Eatual=Prepara else
		InicioCiclo when Eatual=ResetContador else
		
		EsperaJogada when Eatual=InicioCiclo else
		EsperaJogada when Eatual=EsperaJogada and jogada='0' and timeout='0' else
		EsperaJogada when Eatual=AcertouJogada and fim='0' else --nao acabou de jogar ainda

		ArmazenaJogada when  Eatual=EsperaJogada and jogada='1' and timeout='0' else
		ComparaJogada	when  Eatual=ArmazenaJogada else
      
		AcertouJogada when  Eatual=ComparaJogada and certo='1' and fim='0'else
		ErrouJogada when Eatual=ComparaJogada and certo='0' else
		ErrouJogada when Eatual=EsperaJogada and timeout='1' else
		
		
		CicloErrado when Eatual=ErrouJogada else
		AumentaLimite when Eatual=ComparaJogada and certo='1' and fim='1' else
		CicloCerto when Eatual=AumentaLimite and limiteMaximo='0' else
		
		EsperaEscrita when Eatual=CicloCerto else
		EsperaEscrita when Eatual=EsperaEscrita and jogada='0' else
		EscreveJogada when Eatual=EsperaEscrita and jogada='1' else
		ResetContador when Eatual=EscreveJogada else
		
		TerminouCerto when Eatual=AumentaLimite and limiteMaximo='1' else
      TerminouCerto when Eatual=TerminouCerto and iniciar='0' else
      TerminouErrado when Eatual=TerminouErrado and iniciar='0' else
		TerminouErrado when Eatual=CicloErrado else
		
		Aguarda;

  -- logica de saída (maquina de Moore)
  with Eatual select
    zera <=	'1' when Prepara | ResetContador,
				'0' when others;

  with Eatual select
    conta <=  '1' when AcertouJogada | CicloCerto,
              '0' when others;

  with Eatual select
    pronto <= '1' when TerminouCerto | TerminouErrado,
              '0' when others;
				  
	with Eatual select
		acertou <= 	'1' when TerminouCerto,
						'0' when others;
						
	with Eatual select
		errou <= '1' when TerminouErrado,
					'0' when others;

	with Eatual select
		registra <= '1' when ArmazenaJogada,
					'0' when others;
	
	with Eatual select
		incrementaLimite <= '1' when AumentaLimite, --no proximo ciclo, quero limite+1
								  '0' when others;
	with Eatual select
		zeraLim <= '1' when Prepara,
					  '0' when others;
	with Eatual select
		escreve <= '1' when EscreveJogada,
		  '0' when others;
	with Eatual select
		treset <= '1' when AcertouJogada | InicioCiclo,
		'0' when others;
	with Eatual select
		tenable <= '1' when EsperaJogada,
		'0' when others;		
  -- saida de depuracao (db_estado)
	with Eatual select
		db_estado <= 
x"0" when Aguarda,        -- ->  #40 
x"1" when Prepara,        -- ->  #79 
x"2" when InicioCiclo,    -- ->  #24
x"3" when EsperaJogada,   -- ->  #30
x"4" when ArmazenaJogada, -- ->  #19
x"5" when ComparaJogada,  -- ->  #12
x"6" when AcertouJogada,  -- ->  #02  
x"7" when ErrouJogada,    -- ->  #78
x"8" when CicloCerto,     -- ->  #00
x"9" when CicloErrado,    -- ->  #10
x"A" when EsperaEscrita,  -- ->  #08
x"B" when EscreveJogada,  -- ->  #03
x"C" when TerminouCerto,  -- ->  #46
x"D" when TerminouErrado, -- ->  #21
x"E" when ResetContador,  -- ->  #06
x"F" when AumentaLimite;  -- ->  #0D
end fsm;    

