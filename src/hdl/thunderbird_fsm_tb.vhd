--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port(
	  i_clk, i_reset  : in    std_logic;
      i_left, i_right : in    std_logic;
      o_lights_L      : out   std_logic_vector(2 downto 0);
      o_lights_R      : out   std_logic_vector(2 downto 0)	
	  );
	end component thunderbird_fsm;

	-- test I/O signals
	signal w_L : std_logic := '0';
	signal w_R : std_logic := '0';
    signal w_reset : std_logic := '0';
    signal w_clk : std_logic := '0';
	-- constants
	signal w_thunderbird : std_logic_vector(5 downto 0) := "000000"; --  one-hot
        
    -- Clock period definitions
    constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	uut: thunderbird_fsm port map(
	i_clk => w_clk,
	i_reset => w_reset,
	i_left => w_L,
	i_right => w_R,
	o_lights_L(0) => w_thunderbird(3),
    o_lights_L(1) => w_thunderbird(4),
    o_lights_L(2) => w_thunderbird(5),
    o_lights_R(0) => w_thunderbird(2),
    o_lights_R(1) => w_thunderbird(1),
    o_lights_R(2) => w_thunderbird(0)
	);
	-----------------------------------------------------
	
	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    	clk_proc : process
    begin
        w_clk <= '0';
        wait for k_clk_period/2;
        w_clk <= '1';
        wait for k_clk_period/2;
    end process;
	-----------------------------------------------------
	sim_proc: process
	begin
	-- Test Plan Process --------------------------------
	w_reset <= '1'; --TEST RESET
	wait for k_clk_period*1;
    assert w_thunderbird = "000000" report "bad reset" severity failure;
    
    w_reset <= '0';
    wait for k_clk_period*1;
    
   w_L <= '1'; w_R <= '1' ; wait for k_clk_period; --TEST HAZARD
   assert	w_thunderbird = "111111" report "bad hazard" severity failure;
   wait for k_clk_period;
   assert w_thunderbird = "000000" report "bad hazard" severity failure;
  
    w_R <= '0'; w_L <= '0'; wait for k_clk_period*1;
    assert w_thunderbird = "000000" report "all lights need to be off" severity failure;
    
    w_R <= '0'; w_L <= '1'; wait for k_clk_period*1; 
    assert w_thunderbird = "001000" report "first right light" severity failure;
    wait for k_clk_period;
    assert w_thunderbird = "011000" report "second right light" severity failure;
    wait for k_clk_period;
    assert w_thunderbird = "111000" report "third right light" severity failure;
    wait for k_clk_period;
    assert w_thunderbird = "000000" report "reset right light" severity failure;
    
    w_R <= '0'; w_L <= '1'; wait for k_clk_period*1; 
    assert w_thunderbird = "001000" report "first right light" severity failure;
    w_R <= '0'; w_L <= '0'; wait for k_clk_period*1;
    assert w_thunderbird = "011000" report "second right light" severity failure;
    wait for k_clk_period;
    assert w_thunderbird = "111000" report "third right light" severity failure;
    wait for k_clk_period;
    assert w_thunderbird = "000000" report "reset right light" severity failure;
    
    w_R <= '1'; w_L <= '0'; wait for k_clk_period;
     assert w_thunderbird = "000100" report "first left light" severity failure;
    wait for k_clk_period;
    assert w_thunderbird = "000110" report "second left light" severity failure;
    wait for k_clk_period;
    assert w_thunderbird = "000111" report "third left light" severity failure;
    wait for k_clk_period;
    assert w_thunderbird = "000000" report "reset left light" severity failure;
  
     w_R <= '1'; w_L <= '0'; wait for k_clk_period;
       assert w_thunderbird = "000100" report "first left light" severity failure;
     w_R <= '0'; w_L <= '0'; wait for k_clk_period;
      assert w_thunderbird = "000110" report "second left light" severity failure;
      wait for k_clk_period;
      assert w_thunderbird = "000111" report "third left light" severity failure;
      wait for k_clk_period;
      assert w_thunderbird = "000000" report "reset left light" severity failure;
	-----------------------------------------------------	
	wait;
	end process;
end test_bench;
