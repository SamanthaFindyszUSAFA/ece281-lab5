----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/27/2026 01:10:12 PM
-- Design Name: 
-- Module Name: cycle - Behavioral
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

entity cycle is
    Port ( 
        i_input : in STD_LOGIC_VECTOR (7 downto 0);
        i_reset : in  STD_LOGIC;
        i_cycle : in STD_LOGIC;
        o_output : out STD_LOGIC_VECTOR (7 downto 0)
    );
end cycle;

architecture Behavioral of cycle is

    signal current_number : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal next_number : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    
begin

    next_number <= i_input; 

    -- Output logic
	o_output <= current_number;

    state_register : process(i_cycle, i_reset)
	begin
	   if i_reset = '1' then
	       current_number <= "00000000";
	   
       elsif rising_edge(i_cycle) then --???
           current_number <= next_number;
       end if;
	end process state_register;


end Behavioral;
