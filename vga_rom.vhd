library ieee;
use ieee.std_logic_1164.all;

entity vga_rom is
port(
	clk_0,reset: in std_logic;
	hs,vs: out STD_LOGIC; 
	r,g,b: out STD_LOGIC_vector(2 downto 0);
	bird1: in std_logic_vector(19 downto 0);
	bird2: in std_logic_vector(19 downto 0);
	hand: in std_logic_vector(18 downto 0)
);
end vga_rom;

architecture vga_rom of vga_rom is

component vga640480 is
	 port(
			address_hand:		out std_logic_vector(13 downto 0);
			address_back:		out std_LOGIC_vector(14 downto 0);
			q_back		:		in std_LOGIC_vector(7 downto 0);
			q_hand 		: 		in std_logic_vector(7 downto 0);
			address		:		  out	STD_LOGIC_VECTOR(14 DOWNTO 0);
			reset       :         in  STD_LOGIC;
			q		    :		  in STD_LOGIC_vector(7 downto 0);
			clk100       :         in  STD_LOGIC; 
			hs,vs       :         out STD_LOGIC; 
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			bird1: in std_logic_vector(19 downto 0);
			bird2: in std_logic_vector(19 downto 0);
			hand: in std_logic_vector(18 downto 0)
	  );
end component;

component bird_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;
component hand_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;
component back_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;


signal address_tmp: std_logic_vector(14 downto 0);
signal clk50: std_logic;
signal q_tmp: std_logic_vector(7 downto 0);

signal address_hand: std_lOGIC_vector(13 downto 0);
signal q_hand: std_lOGIC_vector(7 downto 0);

signal address_back: std_lOGIC_vector(14 downto 0);
signal q_back: std_logic_vector(7 downto 0);
begin

process(clk_0)
begin
	if (rising_edge(clk_0)) then
		clk50 <= not clk50;
	end if;
end process;
u1: vga640480 port map(
						address_hand=>address_hand,
						address_back=>address_back,
						q_back=>q_back,
						q_hand=>q_hand,
						address=>address_tmp, 
						reset=>'1', 
						q=>q_tmp, 
						clk100=>clk_0, 
						hs=>hs, vs=>vs, 
						r=>r, g=>g, b=>b,
						bird1 => bird1,
						bird2 => bird2,
						hand => hand
					);
u2: bird_rom port map(	
						address=>address_tmp, 
						clock=>clk50, 
						q=>q_tmp
					);
u3: hand_rom port map(	
						address=>address_hand, 
						clock=>clk50, 
						q=>q_hand
					);
u4: back_rom port map(	
						address=>address_back, 
						clock=>clk50, 
						q=>q_back
					);
end vga_rom;