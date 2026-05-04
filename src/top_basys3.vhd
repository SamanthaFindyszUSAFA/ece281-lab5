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


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        btnL    :   in std_logic;
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals
	component clock_divider is
        generic ( constant k_DIV : natural := 2	);
        port ( 	i_clk    : in std_logic;		   -- basys3 clk
                i_reset  : in std_logic;		   -- asynchronous
                o_clk    : out std_logic		   -- divided (slow) clock
        );
    end component clock_divider;

    component TDM4 is 
    	generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        port ( i_clk		: in  STD_LOGIC;
               i_reset		: in  STD_LOGIC; -- asynchronous
               i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_sel		: out STD_LOGIC_VECTOR (3 downto 0)	-- selected data line (one-cold)
        );
    end component TDM4;
    
    component twos_comp is
        port (
            i_bin: in std_logic_vector(7 downto 0);
            o_sign: out std_logic_vector(3 downto 0);
            o_hund: out std_logic_vector(3 downto 0);
            o_tens: out std_logic_vector(3 downto 0);
            o_ones: out std_logic_vector(3 downto 0)
        );
    end component twos_comp;
    
    component controller_fsm is
        port ( i_reset : in STD_LOGIC;
               i_adv : in STD_LOGIC;
               o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
    end component controller_fsm;
    
    component ALU is
        port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
               i_B : in STD_LOGIC_VECTOR (7 downto 0);
               i_op : in STD_LOGIC_VECTOR (2 downto 0);
               o_result : out STD_LOGIC_VECTOR (7 downto 0);
               o_flags : out STD_LOGIC_VECTOR (3 downto 0));
    end component ALU;
    
    component cycle is 
        generic ( constant k_SET : STD_LOGIC_VECTOR (3 downto 0) := "0000"	);
        Port ( 
            i_input : in STD_LOGIC_VECTOR (7 downto 0);
            i_reset : in  STD_LOGIC;
            i_cycle : in STD_LOGIC_VECTOR (3 downto 0);
            o_output : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component cycle;
    
    component button_debounce is
        Port(	clk: in  STD_LOGIC;
                reset : in  STD_LOGIC;
                button: in STD_LOGIC;
                action: out STD_LOGIC);
    end component button_debounce;
    
    component sevenseg_decoder is
        port (
            i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR (6 downto 0)
        );
    end component sevenseg_decoder;
    
    component negative_sign is
        Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
           o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
    end component negative_sign;
    
    constant k_IO_WIDTH : natural := 4;
    
    signal w_clk : std_logic;		--this wire provides the connection between o_clk and TDM4 clk
    signal w_cycle : STD_LOGIC_VECTOR(3 downto 0) := "0001";
    signal w_btnC : std_logic;

    signal w_twos_comp_input : STD_LOGIC_VECTOR (7 downto 0);
    signal w_sign : std_logic_vector(3 downto 0);
    signal w_hund : std_logic_vector(3 downto 0);
    signal w_tens : std_logic_vector(3 downto 0);
    signal w_ones : std_logic_vector(3 downto 0);
    
    signal w_load_A : STD_LOGIC_VECTOR (7 downto 0);
    signal w_load_B : STD_LOGIC_VECTOR (7 downto 0);
    signal w_ALU_result : STD_LOGIC_VECTOR (7 downto 0);
    
    
    signal w_display : STD_LOGIC_VECTOR (6 downto 0);
    signal w_sel : STD_LOGIC_VECTOR (3 downto 0);
    
    signal w_seven_seg_decoder_input : STD_LOGIC_VECTOR (k_IO_WIDTH - 1 downto 0);
    signal w_seven_seg_output : STD_LOGIC_VECTOR (6 downto 0);
    signal w_negative_sign_output : STD_LOGIC_VECTOR (6 downto 0);
    --signal w_segment_output : STD_LOGIC_VECTOR (6 downto 0);
    --signal w_xF : STD_LOGIC_VECTOR (3 downto 0) := "1111";
  
    signal w_reset : std_logic;
begin
	-- PORT MAPS ----------------------------------------
    --Complete the clock_divider portmap below based on the design provided	
	clkdiv_inst : clock_divider 		--instantiation of clock_divider to take 
        generic map ( k_DIV => 125000 ) -- 4 Hz clock from 100 MHz
        port map (						  
            i_clk   => clk,
            i_reset => btnL,
            o_clk   => w_clk
        );   
        
    twos_comp_inst : twos_comp
        port map(
            i_bin => w_twos_comp_input,
            o_sign => w_sign,
            o_hund => w_hund,
            o_tens => w_tens,
            o_ones => w_ones
        );
        
     TDM4_inst: TDM4
        generic map ( k_WIDTH =>  k_IO_WIDTH )
        port map ( 
           i_clk   => w_clk,
           i_reset => btnU,
           i_D3    => w_sign,
           i_D2    => w_hund,
           i_D1    => w_tens,
           i_D0    => w_ones,
           o_data  => w_seven_seg_decoder_input,
           o_sel   => w_sel
        );
    
    ALU_inst: ALU 
        port map(
            i_A => w_load_A,
            i_B => w_load_B,
            i_op(2) => sw(2),
            i_op(1) => sw(1),
            i_op(0) => sw(0),
            o_result => w_ALU_result,
            o_flags(3) => led(15),
            o_flags(2) => led(14),
            o_flags(1) => led(13),
            o_flags(0) => led(12)
        );
        
    --cycle_inst_A: cycle
        --port map( 
            --i_input => sw,
            --i_reset => w_reset,
            --i_cycle => w_cycle(1 downto 1),
            --o_output => w_load_A
        --);
        
    --cycle_inst_B: cycle
        --port map( 
            --i_input => sw,
            --i_reset => w_reset,
            --i_cycle => w_cycle(2 downto 2),
            --o_output => w_load_B
        --);
        
    controller_fsm_inst: controller_fsm
        port map( 
            i_reset => w_reset,
            i_adv => w_btnC,
            o_cycle => w_cycle
        );
        
        
    sevenseg_decoder_inst: sevenseg_decoder
        port map(
            i_Hex => w_seven_seg_decoder_input,
            o_seg_n => w_seven_seg_output
        );
        
    button_debounce_inst: button_debounce
        port map(
            clk => clk,
            reset => '0', --btnU?
            button => btnC,
            action => w_btnC
        );
        
    negative_sign_inst: negative_sign
        port map(
            i_Hex => w_seven_seg_decoder_input,
            o_seg_n => w_negative_sign_output
        );
    
	
	
	-- CONCURRENT STATEMENTS ----------------------------
	with w_sel select 
        w_display <= --"1110000" when others;
         not w_negative_sign_output when "0111",
         --not w_seven_seg_output when others;
         "0001110" when others;
         
    seg <= w_display;
         
   	with w_cycle select 
        w_twos_comp_input <=  
         w_load_A when "0010", 
         w_load_B when "0100", 
         w_ALU_result when "1000",  
         "00000000" when others;

   
   w_reset <= '1' when(btnU = '1') else 
   '0';
   
    --an(0) <= '0';
    an(0) <= '0' when (w_sel = "1110") else '1';
    an(1) <= '0' when (w_sel = "1101") else '1';
    an(2) <= '0' when (w_sel = "1011") else '1';
    an(3) <= '0' when (w_sel = "0111") else '1';
    
    led(11 downto 4) <= (others => '0');

    led(3) <= w_cycle(3);
    led(2) <= w_cycle(2);
    led(1) <= w_cycle(1);
    led(0) <= w_cycle(0);
    --led(3) <= '1' when (w_cycle = "1000") else '0';
    --led(2) <= '1' when (w_cycle = "0100") else '0';
    --led(1) <= '1' when (w_cycle = "0010") else '0';
    --led(0) <= '1' when (w_cycle = "0001") else '0';
    
    load_A : process(w_cycle(1), w_reset)
	begin
	   if w_reset = '1' then
	       w_load_A <= "00000000";
	   
       elsif rising_edge(w_cycle(1)) then --???
           w_load_A <= sw;
       end if;
	end process load_A;
	
	
	load_B : process(w_cycle(2), w_reset)
	begin
	   if w_reset = '1' then
	       w_load_B <= "00000000";
	   
       elsif rising_edge(w_cycle(2)) then --???
           w_load_B <= sw;
       end if;
	end process load_B;
	
	
end top_basys3_arch;
