----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is

	type sm_state is (clear_display, first_num, second_num, result);
	
	-- Here you create variables that can take on the values defined above. Neat!	
	signal current_state: sm_state := clear_display; 
	signal next_state: sm_state:= clear_display;
begin
    next_state <=  sm_state'succ(current_state) when (current_state /= result) else -- going up
               clear_display;
    
    -- Output logic
	with current_state select
	o_cycle <= "1000" when result,
	           "0100" when second_num,
	           "0010" when first_num,
	           "0001" when others;

	state_register : process(i_adv, i_reset)
	begin
	    if i_reset = '1' then
           current_state <= clear_display;
        elsif rising_edge(i_adv) then
           current_state <= next_state;
        end if;
	end process state_register;


end FSM;
