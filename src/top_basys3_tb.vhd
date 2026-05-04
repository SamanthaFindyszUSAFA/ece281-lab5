library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_basys3_tb is
end top_basys3_tb;

architecture behavior of top_basys3_tb is

    -- DUT signals
    signal sw    : std_logic_vector(7 downto 0) := (others => '0');
    signal btnU  : std_logic := '0';
    signal btnC  : std_logic := '0';
    signal btnL  : std_logic := '0';

    signal led : std_logic_vector(15 downto 0);
    signal seg : std_logic_vector(6 downto 0);
    signal an  : std_logic_vector(3 downto 0);

	-- Clock period definitions
	signal w_clk : std_logic := '0';
	constant k_clk_period : time := 10 ns;

begin

    -- DUT (override divider to speed simulation)
    uut: entity work.top_basys3
        port map(
            clk  => w_clk,
            sw   => sw,
            btnU => btnU,
            btnC => btnC,
            btnL => btnL,
            led  => led,
            seg  => seg,
            an   => an
        );

    -- 100 MHz clock
	clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;

    -- Stimulus
    stim_proc : process
    begin
        ----------------------------------------------------------------
        -- RESET
        ----------------------------------------------------------------
        btnU <= '1';
        wait for k_clk_period;
        btnU <= '0';
        wait for k_clk_period;

        ----------------------------------------------------------------
        -- LOAD A
        ----------------------------------------------------------------
        sw <= "00000101"; -- 5

        btnC <= '1';
        wait for k_clk_period;
        btnC <= '0';

        wait for k_clk_period;

        ----------------------------------------------------------------
        -- LOAD B
        ----------------------------------------------------------------
        sw <= "00000011"; -- 3

        btnC <= '1';
        wait for k_clk_period;
        btnC <= '0';

        wait for k_clk_period;

        ----------------------------------------------------------------
        -- RESULT (set opcode)
        ----------------------------------------------------------------
        sw(2 downto 0) <= "000"; -- e.g., ADD

        btnC <= '1';
        wait for k_clk_period;
        btnC <= '0';

        wait for k_clk_period;

        ----------------------------------------------------------------
        -- LOOP AGAIN
        ----------------------------------------------------------------
        btnC <= '1';
        wait for k_clk_period;
        btnC <= '0';

        wait for k_clk_period;

        wait;
    end process;

end behavior;
