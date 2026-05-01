----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/28/2026 08:23:14 AM
-- Design Name: 
-- Module Name: negative_sign - Behavioral
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

entity negative_sign is
    Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
end negative_sign;

architecture Behavioral of negative_sign is

    signal w_seg : std_logic_vector(6 downto 0) := "0000000";

begin
    with i_Hex select
    w_seg   <=  "1111110" when "0000",
                "0000001" when "0001",
                "0000000" when others;
    -- Flipped mapping to o_seg_n to match constraints file
    -- Invert w_seg because the cathodes are active LOW
    o_seg_n(0) <= not w_seg(6); -- Sa
    o_seg_n(1) <= not w_seg(5); -- Sb
    o_seg_n(2) <= not w_seg(4); -- Sc
    o_seg_n(3) <= not w_seg(3); -- Sd
    o_seg_n(4) <= not w_seg(2); -- Se
    o_seg_n(5) <= not w_seg(1); -- Sf
    o_seg_n(6) <= not w_seg(0); -- Sg

end Behavioral;
