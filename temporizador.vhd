-- ============================================================================
-- Entidade: temporizador
-- ----------------------------------------------------------------------------
-- Descrição:
-- Este módulo implementa um temporizador em VHDL. Ele utiliza um contador de 
-- 16 bits para representar o tempo restante em minutos e segundos. O contador 
-- pode ser inicializado, decrementado e reiniciado com base nos sinais de 
-- controle fornecidos.
--
-- Portas:
-- - clock      : Entrada do sinal de clock. O contador é atualizado na borda 
--                de subida deste sinal.
-- - reset      : Entrada de reset. Quando ativado ('1'), o contador é 
--                reiniciado para zero.
-- - load       : Entrada de carga. Quando ativado ('1'), o contador é 
--                inicializado com o valor fornecido em `init_time`.
-- - en         : Entrada de habilitação. Quando ativado ('1'), o contador é 
--                decrementado a cada ciclo de clock, desde que não tenha 
--                atingido zero.
-- - init_time  : Vetor de 8 bits usado para inicializar os 8 bits mais 
--                significativos do contador (minutos).
-- - minH       : Saída de 4 bits representando os dígitos mais significativos 
--                dos minutos.
-- - minL       : Saída de 4 bits representando os dígitos menos significativos 
--                dos minutos.
-- - segH       : Saída de 4 bits representando os dígitos mais significativos 
--                dos segundos.
-- - segL       : Saída de 4 bits representando os dígitos menos significativos 
--                dos segundos.
-- - cont       : Saída de 16 bits representando o valor completo do contador.
--
-- Funcionamento:
-- - Quando `reset` é ativado, o contador é zerado.
-- - Quando `load` é ativado, os 8 bits mais significativos do contador são 
--   carregados com o valor de `init_time`, e os 8 bits menos significativos 
--   são zerados.
-- - Quando `en` é ativado, o contador é decrementado a cada ciclo de clock, 
--   desde que seu valor seja maior que zero.
-- - As saídas `minH`, `minL`, `segH` e `segL` são derivadas diretamente do 
--   valor do contador, representando os minutos e segundos em formato BCD.
-- ============================================================================


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity temporizador is
    port(
        clock      : in  std_logic;
        reset      : in  std_logic;
        load       : in  std_logic;
        en         : in  std_logic;
        init_time  : in  std_logic_vector(7 downto 0);
        minH       : out std_logic_vector(3 downto 0);
        minL       : out std_logic_vector(3 downto 0);
        segH       : out std_logic_vector(3 downto 0);
        segL       : out std_logic_vector(3 downto 0);
        cont       : out std_logic_vector(15 downto 0)
    );
end temporizador;

architecture behavioral of temporizador is
    signal counter : std_logic_vector(15 downto 0);

begin

    process(clock, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
        elsif rising_edge(clock) then
            if load = '1' then
                counter(15 downto 8) <= init_time;
                counter(7 downto 0) <= (others => '0');
            elsif en = '1' then
                if counter > "0000000000000000" then
                    counter <= counter - 1;
                end if;
            end if;
        end if;
    end process;

    minH <= counter(15 downto 12);
    minL <= counter(11 downto 8);
    segH <= counter(7 downto 4);
    segL <= counter(3 downto 0);
    cont <= counter;

end behavioral;
