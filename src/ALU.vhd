----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

    component ripple_adder is
        Port ( A : in STD_LOGIC_VECTOR (7 downto 0);
               B : in STD_LOGIC_VECTOR (7 downto 0);
               Cin : in STD_LOGIC;
               S : out STD_LOGIC_VECTOR (7 downto 0);
               Cout : out STD_LOGIC);
    end component ripple_adder;
    
    
    signal w_sum : STD_LOGIC_VECTOR (7 downto 0);
    signal w_Cout : std_logic;
    signal w_B : STD_LOGIC_VECTOR (7 downto 0);
    signal w_result: STD_LOGIC_VECTOR (7 downto 0);
begin

    ripple_adder_inst : ripple_adder
       port map (						  
            A => i_A,
            B => w_B,
            Cin => i_op(0),
            S => w_sum,
            Cout => w_Cout
        ); 
    
   	with i_op(1 downto 0) select 
        w_result <=  
         (i_A or i_B) when "11", 
         (i_A and i_B) when "10",   
          w_sum when others;
        
    with i_op(0) select 
        w_B <=  
         (not i_B) when '1', 
         (i_B) when others;
         
    o_result <= w_result;
        
        --switch o_flags to w_flags
        --or each together and then not them
     o_flags(2) <= not (w_result(0) or w_result(1) or w_result(2) or w_result(3)
        or w_result(4) or w_result(5) or w_result(6) or w_result(7)); 
     o_flags(3) <= w_result(7);
     o_flags(1) <= not i_op(1) and w_Cout; --? What do I and with?
     o_flags(0) <= not i_op(1) and not (w_sum(7) nor i_A(7) nor i_B(7)) and (i_A(7) nor i_B(7));
    

end Behavioral;
