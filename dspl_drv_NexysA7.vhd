--------------------------------------
-- Biblioteca
--------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

--------------------------------------
-- Entidade
--------------------------------------
entity dspl_drv_NexysA7 is
  port (reset, clock: in std_logic;
        d1,d2,d3,d4,d5,d6,d7,d8 : in std_logic_vector(5 downto 0);
        an: out std_logic_vector(7 downto 0);
        dec_cat: out std_logic_vector(7 downto 0));
end entity;

--------------------------------------
-- Arquitetura
--------------------------------------
architecture behavioral of dspl_drv_NexysA7 is
  signal clock_1ms : std_logic;
  signal counter_1ms: std_logic_vector(15 downto 0);
  signal counter_an: std_logic_vector(2 downto 0);
  signal digito: std_logic_vector(4 downto 0);
begin

  process(clock, reset)
  begin
    if reset = '1' then
      clock_1ms <= '0';
      counter_1ms <= (others=>'0');
    elsif rising_edge(clock) then
      if counter_1ms = 49999 then
        clock_1ms <= not clock_1ms;
        counter_1ms <= (others=>'0');
      else 
        counter_1ms <= counter_1ms + 1;
      end if;
    end if;
  end process;

  process(clock_1ms, reset)
  begin
    if reset = '1' then
      counter_an <= (others=>'0');
    elsif rising_edge(clock_1ms) then
      counter_an <= counter_an + 1;
    end if;
  end process;

  an <= "1111111" & not d1(5)       when counter_an = 0 else
        "111111" & not d2(5) & '1'  when counter_an = 1 else
        "11111" & not d3(5) & "11"  when counter_an = 2 else
        "1111" & not d4(5) & "111"  when counter_an = 3 else
        "111" & not d5(5) & "1111"  when counter_an = 4 else
        "11" & not d6(5) & "11111"  when counter_an = 5 else
        '1' & not d7(5) & "111111"  when counter_an = 6 else
             not d8(5) & "1111111"; --   when counter_an = 7;

  digito <= d1(4 downto 0)  when counter_an = 0 else
            d2(4 downto 0)  when counter_an = 1 else
            d3(4 downto 0)  when counter_an = 2 else
            d4(4 downto 0)  when counter_an = 3 else
            d5(4 downto 0)  when counter_an = 4 else
            d6(4 downto 0)  when counter_an = 5 else
            d7(4 downto 0)  when counter_an = 6 else
            d8(4 downto 0); -- when counter_an = 7;

  dec_cat <= not digito(0) & "1000000" when (digito(4 downto 1) = 0)  else 
             not digito(0) & "1111001" when (digito(4 downto 1) = 1)  else 
             not digito(0) & "0100100" when (digito(4 downto 1) = 2)  else 
             not digito(0) & "0110000" when (digito(4 downto 1) = 3)  else 
             not digito(0) & "0011001" when (digito(4 downto 1) = 4)  else 
             not digito(0) & "0010010" when (digito(4 downto 1) = 5)  else 
             not digito(0) & "0000010" when (digito(4 downto 1) = 6)  else 
             not digito(0) & "1111000" when (digito(4 downto 1) = 7)  else 
             not digito(0) & "0000000" when (digito(4 downto 1) = 8)  else 
             not digito(0) & "0010000" when (digito(4 downto 1) = 9)  else 
             not digito(0) & "0001000" when (digito(4 downto 1) = 10) else 
             not digito(0) & "0000011" when (digito(4 downto 1) = 11) else 
             not digito(0) & "1000110" when (digito(4 downto 1) = 12) else 
             not digito(0) & "0100001" when (digito(4 downto 1) = 13) else 
             not digito(0) & "0000110" when (digito(4 downto 1) = 14) else 
             not digito(0) & "0001110"; -- when (digito(4 downto 1) = 15

end architecture;
