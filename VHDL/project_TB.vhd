library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all

entity vhdl_TB is
end vhdl_TB;


architecture vhdl_TB_ARCH for vhdl_TB is
  constant ACTIVE: std_logic := '1';
--unit-under-test------------------------------------------------------------
component vhdl
  port ( btn_dn : in std_logic := '0';
         clk : in std_logic;
         state : in std_logic;
         dir : in std_logic;
         sw : in std_logic_vector(15 downto 0);
         LED : out std_logic_vector(15 downto 0);
         SEG : out std_logic_vector(6 downto 0);
         an : out std_logic_vector(3 downto 0);
      );
end component;

--UUT-signals----------------------------------------------------------------
signal clk: std_logic :=0;                                   --signals--
signal reset: std_logic;
signal state: std_logic;
signal dir: std_logic;
signal btn_dn: std_logic;
signal sw: std_logic_vector(15 downto 0);
signal sevensegs: std_logic_vector(6 downto 0);
signal anodes: std_logic_vector(3 downto 0);
signal led: std_logic_vector(3 downto 0);

--architecture-description----------------------------------------------------
begin
 --unit-under-test------------------------------------------------------------
    UUT: vhdl port map(
                          clk => clk,
                          btn_dn => reset,
                          state => state,
                          SEG => sevensegs,
                          an => anodes,
                          LED => led,
                          sw => sw,
                          dir => dir
                      );

--system-clock---------------------------------------------------------------
CLOCK_FREQ: process
begin
      clk <= '0';
      wait for 5 ns;
      clk <= '1';
      wait for 5 ns;
end process;

--initialize-reset-signal----------------------------------------------------
RESET_DRIVER: process
begin
    reset <= '1';
    wait for 30 ns;
    reset <= '0';
    wait;
end process;

--waveform-generator-for-start/stop-simulation-------------------------------
START_DRIVER: process
begin
    state <= '0';
    wait for 50 ns;
    state <= '1';
    wait for 20 ns;
    state <= '0';
    wait;
end process;

--waveform-generator-for-direction------------------------------
DIR_DRIVER: process
begin
    dir <= '0';
    wait for 20 ns;
    dir <= '1';
    wait for 20 ns;
    dir <= '0';
    wait;
end process;
