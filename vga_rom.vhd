library ieee;
use ieee.std_logic_1164.all;
use work.render_info.all;



entity vga_rom is
port(
	clk_0,reset: in std_logic;
	hs,vs: out STD_LOGIC; 
	r,g,b: out STD_LOGIC_vector(2 downto 0);
	bird1: in std_logic_vector(19 downto 0);
	bird2: in std_logic_vector(19 downto 0);
	hand: in std_logic_vector(18 downto 0);
	score: in integer
);
end vga_rom;

architecture vga_rom of vga_rom is

component vga640480 is
	 port(
			obj_address:		out obj_addr;
			obj_data:			in obj_d;
			reset       :         in  STD_LOGIC;
			clk25       :         in  STD_LOGIC; 
			hs,vs       :         out STD_LOGIC; 
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			bird1: 					in std_logic_vector(19 downto 0);
			bird2: 					in std_logic_vector(19 downto 0);
			hand: 					in std_logic_vector(18 downto 0);
			score:					in integer
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

component life_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;
component dead_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
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
		address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;


signal clk50, clk25: std_logic;

signal obj_address: obj_addr;
signal obj_data: obj_d;

begin

process(clk_0)
begin
	if (rising_edge(clk_0)) then
		clk50 <= not clk50;
	end if;
end process;
process(clk25)
begin
	if rising_edge(clk50) then
		clk25 <= not clk25;
	end if;
end process;
u1: vga640480 port map(
						obj_address=>obj_address,
						obj_data=>obj_data,
						reset=>'1',  
						clk25=>clk25, 
						hs=>hs, vs=>vs, 
						r=>r, g=>g, b=>b,
						bird1 => bird1,
						bird2 => bird2,
						hand => hand,
						score => score
					);
u2: bird_rom port map(	
						address=>obj_address.address_bird, 
						clock=>clk50, 
						q=>obj_data.q_bird
					);
u3: hand_rom port map(	
						address=>obj_address.address_hand, 
						clock=>clk50, 
						q=>obj_data.q_hand
					);
u4: back_rom port map(	
						address=>obj_address.address_back, 
						clock=>clk50, 
						q=>obj_data.q_back
					);
u5: dead_rom port map(	
						address=>obj_address.address_dead, 
						clock=>clk50, 
						q=>obj_data.q_dead
					);
u6: life_rom port map(	
						address=>obj_address.address_life, 
						clock=>clk50, 
						q=>obj_data.q_life
					);
end vga_rom;