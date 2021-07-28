-- sw3-sw0 (indicates how many digits to count to)
-- sw15 (indicates counting up or down)
-- sw14 (pauses and starts the counter)
-- btn_dn (resets clock)

--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all

entity vhdl is
  Port ( btn_dn : in std_logic := '0';
         clk : in std_logic;
         state : in std_logic;
         dir : in std_logic;
         sw : in std_logic_vector(15 downto 0);
         LED : out std_logic_vector(15 downto 0);
         SEG : out std_logic_vector(6 downto 0);
         an : out std_logic_vector(3 downto 0);
      );
end vhdl;

architecture vhdl_ARCH for vhdl is
----------general-definitions---------------------------------------------------
constant ACTIVE: std_logic := '1';
constant NOT-ACTIVE: std_logic := '0';
constant UP: std_logic := '1';
constant DOWN: std_logic := '0';
variable TerminalValue : interger;

----seven-segment-display-------------------------------------------------------
constant ZERO_7SEG:  std_logic_vector(3 downto 0) := "0000";   --constants--
constant ONE_7SEG:   std_logic_vector(3 downto 0) := "0001";
constant TWO_7SEG:   std_logic_vector(3 downto 0) := "0010";
constant THREE_7SEG: std_logic_vector(3 downto 0) := "0011";
constant FOUR_7SEG:  std_logic_vector(3 downto 0) := "0100";
constant FIVE_7SEG:  std_logic_vector(3 downto 0) := "0101";
constant SIX_7SEG:   std_logic_vector(3 downto 0) := "0110";
constant SEVEN_7SEG: std_logic_vector(3 downto 0) := "0111";
constant EIGHT_7SEG: std_logic_vector(3 downto 0) := "1000";
constant NINE_7SEG:  std_logic_vector(3 downto 0) := "1001";

--LED--display---------------------------------------------------------------
constant LED_0:  std_logic_vector(15 downto 0) := "0000000000000000";
constant LED_1:  std_logic_vector(15 downto 0) := "0000000000000001";
constant LED_2:  std_logic_vector(15 downto 0) := "0000000000000011";
constant LED_3:  std_logic_vector(15 downto 0) := "0000000000000111";
constant LED_4:  std_logic_vector(15 downto 0) := "0000000000001111";
constant LED_5:  std_logic_vector(15 downto 0) := "0000000000011111";
constant LED_6:  std_logic_vector(15 downto 0) := "0000000000111111";
constant LED_7:  std_logic_vector(15 downto 0) := "0000000001111111";
constant LED_8:  std_logic_vector(15 downto 0) := "0000000011111111";
constant LED_9:  std_logic_vector(15 downto 0) := "0000000111111111";
constant LED_10: std_logic_vector(15 downto 0) := "0000001111111111";
constant LED_11: std_logic_vector(15 downto 0) := "0000011111111111";
constant LED_12: std_logic_vector(15 downto 0) := "0000111111111111";
constant LED_13: std_logic_vector(15 downto 0) := "0001111111111111";
constant LED_14: std_logic_vector(15 downto 0) := "0011111111111111";
constant LED_15: std_logic_vector(15 downto 0) := "0111111111111111";
constant LED_16: std_logic_vector(15 downto 0) := "1111111111111111";

--internal-connections----------------------------------------------------------
signal digit3_value: std_logic_vector(3 downto 0);              --signals--
signal digit2_value: std_logic_vector(3 downto 0);
signal digit1_value: std_logic_vector(3 downto 0);
signal digit0_value: std_logic_vector(3 downto 0);
signal digit3_blank: std_logic;
signal digit2_blank: std_logic;
signal digit1_blank: std_logic;
signal digit0_blank: std_logic;

signal countActive: std_logic := '0';
signal OneSec_Count: std_logic;

signal Decode: integer range 15 downto 0;

signal restart: std_logic := '0';
signal state;


--state-machine-declarations-----------------------------------constants--------
    type states is (STOP_PRESSED, START_PRESSED);
    signal CurrentState: states;
    signal NextState: states;


----imported-SevenSegmentDriver-------------------------------------------------
component SevenSegmentDriver
  port(
      restart: in std_logic;
      clock: in std_logic;

      digit0: in std_logic_vector(3 downto 0);
      digit1: in std_logic_vector(3 downto 0);
      digit2: in std_logic_vector(3 downto 0);
      digit3: in std_logic_vector(3 downto 0);

      blank0: in std_logic;
      blank1: in std_logic;
      blank2: in std_logic;
      blank3: in std_logic;

      sevensegs: out std_logic_vector(6 downto 0);
      anodes: out std_logic_vector(3 downto 0)
      );
end component;

begin
  restart <= btn_dn;
-----------driver---------------------------------------------------------------
  MY_SEG: SevenSegmentDriver port map(
    restart => btn_dn,
    clock => clk,
    digit3 => digit3_value,
    digit2 => digit2_value,
    digit1 => digit1_value,
    digit0 => digit0_value,
    blank3 => digit3_blank,
    blank2 => digit2_blank,
    blank1 => digit1_blank,
    blank0 => digit0_blank,
    sevensegs => SEG,
    anodes => an
  );

--state-machine-register--------------------------------------------------------
STATE_REGISTER: process(state, clk)                --process--
begin
   if (state = NOT-ACTIVE) then
       CurrentState <= STOP_PRESSED;
   elsif (rising_edge(clk)) then
       CurrentState <= NextState;
   end if;
end process;


-------counter------------------------------------------------------------------
ONE_SECOND: process(clk, state, btn_dn)                          --process--
variable count: integer range := TerminalValue;
begin
   OneSec_Count <= '0';
       if(state = NOT-ACTIVE) then
           count := 0;
       elsif(rising_edge(clk)) then
           if(countActive = ACTIVE) then
               if(dir = UP) then
                   count := count + 1;
               elseif(dir = DOWN) then
                   count := count - 1;
               elseif(count := TerminalValue) then
                   count := 0;
               end if;
           else
               OneSec_Count <= OneSec_Count;
           end if;
       end if;

       if(btn_dn = ACTIVE) then   ----reset counter---
           count := 0;
           btn_dn <= NOT-ACTIVE;
       end if;

end process;




------switch--set-terminal-value------------------------------------------------
TerminalValue: process(sw, TerminalValue)
constant termval : range 0 to 15 := 0;

begin
---check-term-value-of-switch-----------------------------------------------------
  if (sw(0) = ACTIVE) then
    termval := '0001';
  else
    termval := termval;
  end if

  if (sw(0) = ACTIVE and sw(1) = ACTIVE) then
    termval := '0011';
  else
    termval := termval;
  end if

  if (sw(0) = ACTIVE and sw(1) = ACTIVE and sw(2) = ACTIVE) then
    termval := '0111';
  else
    termval := termval;
  end if

  if (sw(0) and sw(1) and sw(2) and sw(3) = ACTIVE) then
    termval := '1111';
  else
    termval := termval;
  end if

  if (sw(1) and sw(2) and sw(3) = ACTIVE) then
    termval := '1110';
  else
    termval := termval;
  end if

  if (sw(0) and sw(2) and sw(3) = ACTIVE) then
    termval := '1101';
  else
    termval := termval;
  end if

  if (sw(0) and sw(1) and sw(3) = ACTIVE) then
    termval := '1011';
  else
    termval := termval;
  end if

  if (sw(1) = ACTIVE) then
    termval := '0010';
  else
    termval := termval;
  end if

  if (sw(2) = ACTIVE) then
    termval := '0100';
  else
    termval := termval;
  end if

  if (sw(3) = ACTIVE) then
    termval := '1000';
  else
    termval := termval;
  end if

  TerminalValue <= termval;

end process;

------switches-to-indicate-activity---------------------------------------------
SwitchAct: process(sw, state, dir)
begin

  if (sw(14) = ACTIVE) then
    state <= ACTIVE;
  elseif (sw(14) = NOT-ACTIVE) then
    state <= NOT-ACTIVE;
  end if;

  if (sw(15) = ACTIVE) then
    dir <= UP;
  elseif (sw(15) = NOT-ACTIVE) then
    dir <= DOWN;
  end if;

end process;


--DECODER-----------------------------------------------------------------------------
DECODER: process(decode)                                   --process--
variable digitValue: integer range 9 downto 0;
begin
   digitValue := 0;
   digit3_blank <= DISABLE_DIGIT;
   digit2_blank <= DISABLE_DIGIT;
   digit0_blank <= ENABLE_DIGIT;
   if(decode > 9) then
   if(decode = 15) then
       digit0_value <= ZERO_7SEGr;
       digit1_blank <= ENABLE_DIGIT;
       digit1_value <= TWO_7SEG;
   else
       digit1_blank <= ENABLE_DIGIT;
       digit1_value <= ONE_7SEG;
       digitValue := decode - 10;
   end if;
   else
       digit1_blank <= DISABLE_DIGIT;
       digitValue := decode;
   end if;

case(digitValue) is
   when 0 =>
       digit0_value <= ZERO_7SEG;
       LED <= ZERO_LED;
   when 1 =>
       digit0_value <= ONE_7SEG;
       LED <= ONE_LED;
   when 2 =>
       digit0_value <= TWO_7SEG;
       LED <= TWO_LED;
   when 3 =>
       digit0_value <= THREE_7SEG;
       LED <= THREE_LED;
   when 4 =>
       digit0_value <= FOUR_7SEG;
       LED <= FOUR_LED;
   when 5 =>
       digit0_value <= FIVE_7SEG;
       LED <= FIVE_LED;
   when 6 =>
       digit0_value <= SIX_7SEG;
       LED <= SIX_LED;
   when 7 =>
       digit0_value <= SEVEN_7SEG;
       LED <= SEVEN_LED;
   when 8 =>
       digit0_value <= EIGHT_7SEG;
       LED <= EIGHT_LED;
   when others =>
       digit0_value <= NINE_7SEG;
       LED <= NINE_LED;
end case;

end process;


end vhdl_ARCH;
