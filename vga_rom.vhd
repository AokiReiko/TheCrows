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
	is_hold: in std_logic;
	score: in integer;

	hold_bird1, hold_bird2: in std_logic;
	touch_flag: in std_logic;
	game_state: in std_logic_vector(1 downto 0);

	sram_addr : out std_logic_vector(19 downto 0);
	sram_data : in std_logic_vector(31 downto 0)
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
			is_hold: 				in std_logic;
			score:					in integer;
			hold_bird1, hold_bird2: in std_logic;
			touch_flag: in std_logic;
			game_state: in std_logic_vector(1 downto 0);

			sram_addr : out std_logic_vector(19 downto 0);
			sram_data : in std_logic_vector(31 downto 0)
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

component anchor_rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
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
						is_hold => is_hold,
						score => score,

						hold_bird1 => hold_bird1,
					    hold_bird2 => hold_bird2,
						touch_flag => touch_flag,
						game_state => game_state,
						

						sram_addr => sram_addr,
						sram_data => sram_data
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
u7: anchor_rom port map(	
						address=>obj_address.address_anchor, 
						clock=>clk50, 
						q=>obj_data.q_anchor
					);
end vga_rom;