----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Top level for the OV7670 camera project.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TheCrows is
    Port ( 
      clk100        : in   STD_LOGIC;
      OV7670_SIOC  : out   STD_LOGIC;
      OV7670_SIOD  : inout STD_LOGIC;
      OV7670_RESET : out   STD_LOGIC;
      OV7670_PWDN  : out   STD_LOGIC;
      OV7670_VSYNC : in    STD_LOGIC;
      OV7670_HREF  : in    STD_LOGIC;
      OV7670_PCLK  : in    STD_LOGIC;
      OV7670_XCLK  : out   STD_LOGIC;
      OV7670_D     : in    STD_LOGIC_VECTOR(7 downto 0);


      vga_red      : out   STD_LOGIC_VECTOR(2 downto 0);
      vga_green    : out   STD_LOGIC_VECTOR(2 downto 0);
      vga_blue     : out   STD_LOGIC_VECTOR(2 downto 0);
      vga_hsync    : out   STD_LOGIC;
      vga_vsync    : out   STD_LOGIC;
		
      btn           : in    STD_LOGIC
    );
end TheCrows;

architecture Behavioral of TheCrows is
	component vga_rom
	port(
		clk_0,reset: in std_logic;
		hs,vs: out STD_LOGIC; 
		r,g,b: out STD_LOGIC_vector(2 downto 0);
		bird1: in std_logic_vector(19 downto 0);
		bird2: in std_logic_vector(19 downto 0);
		hand: in std_logic_vector(18 downto 0);
		score: in integer
	);
	end component;

	
	component game_logic
	port(
		clk_50: in std_logic;
		hand_pos: in std_logic_vector(18 downto 0);
		size: in std_logic_vector(9 downto 0);
		bird1, bird2: out std_logic_vector(19 downto 0);
		score_out: out integer
	);
	end component;
   

  component camera2identify is
  port
  (
    clk100        : in   STD_LOGIC;
    OV7670_SIOC  : out   STD_LOGIC;
    OV7670_SIOD  : inout STD_LOGIC;
    OV7670_RESET : out   STD_LOGIC;
    OV7670_PWDN  : out   STD_LOGIC;
    OV7670_VSYNC : in    STD_LOGIC;
    OV7670_HREF  : in    STD_LOGIC;
    OV7670_PCLK  : in    STD_LOGIC;
    OV7670_XCLK  : out   STD_LOGIC;
    OV7670_D     : in    STD_LOGIC_VECTOR(7 downto 0);

    h_output : out std_logic_vector(9 downto 0);
    v_output : out std_logic_vector(8 downto 0);
    size_output : out std_logic_vector(9 downto 0);
	 btn: in std_logic
  );

end component;
   
	
	signal h_output, size_output : std_logic_vector(9 downto 0);
	signal v_output : std_logic_vector(8 downto 0);
	signal bird1, bird2 : std_logic_vector(19 downto 0);
	signal clk50			: std_logic;

	signal vga_red_1      : STD_LOGIC_VECTOR(2 downto 0);
   signal vga_green_1    : STD_LOGIC_VECTOR(2 downto 0);
   signal vga_blue_1     : STD_LOGIC_VECTOR(2 downto 0);
   signal vga_hsync_1    : STD_LOGIC;
   signal vga_vsync_1    : STD_LOGIC;
	
	signal score : integer;
begin
	process(clk100) 
	begin
		if (rising_edge(clk100)) then
			clk50 <= not clk50;
		end if;
	end process;

display: vga_rom
	port map(
		clk_0 => clk100,
		reset => '1',
		hs=>vga_hsync,
		vs=>vga_vsync,
		r => vga_red,
		g => vga_green,
		b => vga_blue,
		bird1 => bird1,
		bird2 => bird2,
		hand => h_output & v_output,
		score =>score
	);	
		
	part_logic: game_logic port map(
		clk_50 => clk50,
		hand_pos => h_output & v_output,
		size => size_output,
		bird1 => bird1,
		bird2 => bird2,
		score_out => score
	);

input: camera2identify port map(
  
    clk100=>clk100,
    OV7670_SIOC=>OV7670_SIOC,
    OV7670_SIOD=>OV7670_SIOD,
    OV7670_RESET=>OV7670_RESET,
    OV7670_PWDN=>OV7670_PWDN,
    OV7670_VSYNC=>OV7670_VSYNC,
    OV7670_HREF=>OV7670_HREF,
    OV7670_PCLK=>OV7670_PCLK,
    OV7670_XCLK =>OV7670_XCLK,
    OV7670_D=>OV7670_D,

    h_output=>h_output,
    v_output=>v_output,
    size_output=>size_output,
	 
	 btn=>btn
  );

end Behavioral;
