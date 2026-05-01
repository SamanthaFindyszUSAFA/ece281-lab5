library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cycle_tb is
end cycle_tb;

architecture behavior of cycle_tb is

    -- Component declaration
    component cycle
        generic (
            k_SET : STD_LOGIC_VECTOR (3 downto 0) := "0000"
        );
        Port ( 
            i_input  : in  STD_LOGIC_VECTOR (7 downto 0);
            i_reset  : in  STD_LOGIC;
            i_cycle  : in  STD_LOGIC;
            o_output : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    -- Signals
    signal i_input  : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal i_reset  : STD_LOGIC := '0';
    signal i_cycle  : STD_LOGIC := '0';
    signal o_output : STD_LOGIC_VECTOR (7 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instantiate DUT
    uut: cycle
        port map (
            i_input  => i_input,
            i_reset  => i_reset,
            i_cycle  => i_cycle,
            o_output => o_output
        );

    -- Clock generation (i_cycle is the clock)
    clk_process : process
    begin
        while true loop
            i_cycle <= '0';
            wait for clk_period/2;
            i_cycle <= '1';
            wait for clk_period/2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- 1. Apply reset
        i_reset <= '1';
        wait for 15 ns;
        i_reset <= '0';
        wait for 10 ns;

        -- 2. First input value
        i_input <= "10101010";
        wait for 20 ns;  -- allow a couple clock edges

        -- 3. Change input
        i_input <= "11110000";
        wait for 20 ns;

        -- 4. Change input again
        i_input <= "00001111";
        wait for 20 ns;

        -- 5. Reset in middle
        i_reset <= '1';
        wait for 10 ns;
        i_reset <= '0';
        wait for 20 ns;

        -- 6. Final input
        i_input <= "11001100";
        wait for 30 ns;

        -- End simulation
        wait;
    end process;

end behavior;
