-- ============================================================================
-- Entidade: relogio_xadrez
-- Descrição: Este módulo VHDL implementa um sistema de relógio de xadrez com dois
--            temporizadores (um para cada jogador) e uma máquina de estados finita (FSM)
--            para controlar o fluxo do jogo. O módulo também controla um display para
--            mostrar o tempo restante de cada jogador.
--
-- Portas:
--   - reset       : Sinal de entrada para resetar o sistema.
--   - clock       : Sinal de clock de entrada para operações síncronas.
--   - load        : Sinal de entrada para carregar o tempo inicial nos temporizadores.
--   - init_time   : Vetor de entrada especificando o tempo inicial para os temporizadores.
--   - j1, j2      : Sinais de entrada representando os botões dos jogadores 1 e 2.
--   - an          : Vetor de saída para o controle dos ânodos do display.
--   - dec_cat     : Vetor de saída para o controle dos cátodos do display.
--   - winJ1       : Sinal de entrada/saída indicando se o jogador 1 venceu.
--   - winJ2       : Sinal de entrada/saída indicando se o jogador 2 venceu.
--
-- Arquitetura: behavioral
--   - FSM:
--     - Estados: IDLE, JOGADOR1, JOGADOR2, J1WINSTATE, J2WINSTATE.
--     - Controla o fluxo do jogo com base nas ações dos jogadores e nas condições dos temporizadores.
--   - Sinais:
--     - j1_clear, j2_clear: Sinais de detecção de borda para os botões dos jogadores.
--     - en1, en2: Sinais de habilitação para os temporizadores.
--     - cont1, cont2: Valores de contagem regressiva dos temporizadores para os jogadores 1 e 2.
--     - minH1, minL1, segH1, segL1: Divisão do tempo para o jogador 1 (minutos e segundos).
--     - minH2, minL2, segH2, segL2: Divisão do tempo para o jogador 2 (minutos e segundos).
--     - d1 a d8: Sinais codificados para controlar o display.
--
-- Componentes:
--   - edge_detector: Detecta bordas de subida nos botões dos jogadores.
--   - temporizador: Módulo de temporizador para funcionalidade de contagem regressiva.
--   - dspl_drv_NexysA7: Driver de display para mostrar os temporizadores em um display de 7 segmentos.
--
-- Processos:
--   - FSM Base: Lida com as transições de estado com base nas entradas e no estado atual.
--   - Lógica da FSM: Determina o próximo estado com base no estado atual e nas condições.
--
-- Notas:
--   - O sistema transita entre os estados com base nas ações dos jogadores e nos valores dos temporizadores.
--   - O display é atualizado para mostrar o tempo restante de cada jogador.
--   - Os sinais winJ1 e winJ2 são ativados quando o temporizador de um jogador chega a zero.
-- ============================================================================


library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity relogio_xadrez is
  port(
    reset          : in  std_logic;
    clock          : in  std_logic;
    load           : in  std_logic;
    init_time      : in  std_logic_vector(7 downto 0);
    j1, j2         : in  std_logic;
    an, dec_cat    : out std_logic_vector(7 downto 0); 
    winJ1, winJ2   : inout std_logic 
  );
end relogio_xadrez;

architecture behavioral of relogio_xadrez is
  -- FSM
  type state_type is (IDLE, JOGADOR1, JOGADOR2, J1WINSTATE, J2WINSTATE);
  signal state, next_state : state_type;

  signal j1_clear, j2_clear, en1, en2, load_cont: std_logic;
  signal cont1, cont2 : std_logic_vector(15 downto 0);
  signal minH1, minL1, segH1, segL1 : std_logic_vector(3 downto 0);
  signal minH2, minL2, segH2, segL2 : std_logic_vector(3 downto 0);
  signal d1, d2, d3, d4, d5, d6, d7, d8: std_logic_vector(5 downto 0);
begin

  edj1: entity work.edge_detector
    port map (clock => clock, reset => reset, din => j1, rising => j1_clear);

  edj2: entity work.edge_detector
    port map (clock => clock, reset => reset, din => j2, rising => j2_clear);

 
  contador1: entity work.temporizador
    port map (
      clock => clock,
      reset => reset,
      load  => load,
      en    => en1, 
      init_time => init_time,
      minH => minH1,
      minL => minL1,
      segH => segH1,
      segL => segL1,
      cont => cont1
    );

  -- Instanciação do temporizador 2 (Jogador 2)
  contador2: entity work.temporizador
    port map (
      clock => clock,
      reset => reset,
      load  => load,
      en    => en2, 
      init_time => init_time,
      minH => minH2,
      minL => minL2,
      segH => segH2,
      segL => segL2,
      cont => cont2
    );

  d1 <= '1' & minH2 & '0';
  d2 <= '1' & minL2 & '0';
  d3 <= '1' & segH2 & '1';
  d4 <= '1' & segL2 & '0';
  d5 <= '1' & minH1 & '0';
  d6 <= '1' & minL1 & '0';
  d7 <= '1' & segH1 & '1';
  d8 <= '1' & segL1 & '0';

  -- DISPLAY
  display: entity work.dspl_drv_NexysA7
  port map (
    reset => reset,
    clock => clock,
    d1 => d1,
    d2 => d2,
    d3 => d3,
    d4 => d4,
    d5 => d5,
    d6 => d6,
    d7 => d7,
    d8 => d8,
    an => an,
    dec_cat => dec_cat
  );
  
  -- FSM BASE
  process(clock,reset)
  begin
    if reset = '1' then
      state <= IDLE;
    elsif rising_edge(clock) then
      state <= next_state;
    end if;
  end process;


  en1 <= '1' when state = JOGADOR1;
  en2 <= '1' when state = JOGADOR2;
  winJ1 <= '1' when cont2 = "0000000000000000" nand state = IDLE else '0';
  winJ2 <= '1' when cont1 = "0000000000000000" nand state = IDLE else '0';


  -- PROCESSO LÓGICO PARA A MÁQUINA DE ESTADOS
  process(state, j1_clear, j2_clear, winJ1, winJ2, load)
  begin
    case state is
      when IDLE =>
        if load = '1' then
          if j1_clear = '1' then
            next_state <= JOGADOR1;
          elsif j2_clear = '1' then
            next_state <= JOGADOR2;
          else
            next_state <= IDLE;
          end if;
        end if;
        
      when JOGADOR1 =>
        if winJ1 = '1' then
          next_state <= J1WINSTATE;
        elsif j1_clear = '1' then
          next_state <= JOGADOR2;
        else
          next_state <= JOGADOR1;
        end if;
      when JOGADOR2 =>
        if winJ2 = '1' then
          next_state <= J2WINSTATE;
        elsif j2_clear = '1' then
          next_state <= JOGADOR1;
        else
          next_state <= JOGADOR2;
        end if;
      when J1WINSTATE =>
        if j1_clear = '1' then
          next_state <= IDLE;
        else
          next_state <= J1WINSTATE;
        end if;
      when J2WINSTATE =>
          if j2_clear = '1' then
            next_state <= IDLE;
          else
            next_state <= J2WINSTATE;
          end if;
      when others =>
        next_state <= IDLE;
    end case;
  end process;


end behavioral;
