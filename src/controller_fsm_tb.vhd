library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity controller_fsm_tb is
end controller_fsm_tb;

architecture behavior of controller_fsm_tb is

    -- Component declaration
    component controller_fsm
        Port (
            i_reset : in STD_LOGIC;
            i_adv   : in STD_LOGIC;
            o_cycle : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    -- Signals for connecting to DUT
    signal i_reset : STD_LOGIC := '0';
    signal i_adv   : STD_LOGIC := '0';
    signal o_cycle : STD_LOGIC_VECTOR (3 downto 0);

    constant clk_period : time := 10 ns;

begin

    -- Instantiate the DUT (Device Under Test)
    uut: controller_fsm
        port map (
            i_reset => i_reset,
            i_adv   => i_adv,
            o_cycle => o_cycle
        );

    -- Clock generation (i_adv acts like a clock)
    clk_process : process
    begin
        while true loop
            i_adv <= '0';
            wait for clk_period / 2;
            i_adv <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset
        i_reset <= '1';
        wait for 20 ns;
        i_reset <= '0';

        -- Let FSM run through several cycles
        wait for 100 ns;

        -- Apply another reset mid-operation
        i_reset <= '1';
        wait for 20 ns;
        i_reset <= '0';

        -- Run again
        wait for 100 ns;

        -- End simulation
        wait;
    end process;

end behavior;
