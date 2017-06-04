----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Top level for the OV7670 camera project.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity thecrows is
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

      LED          : out    STD_LOGIC_VECTOR(7 downto 0);

      vga_red      : out   STD_LOGIC_VECTOR(2 downto 0);
      vga_green    : out   STD_LOGIC_VECTOR(2 downto 0);
      vga_blue     : out   STD_LOGIC_VECTOR(2 downto 0);
      vga_hsync    : out   STD_LOGIC;
      vga_vsync    : out   STD_LOGIC;
		
		d1, d2, d3, d4, d5, d6 : out std_logic_vector(6 downto 0);
      btn           : in    STD_LOGIC
    );
end thecrows;

architecture Behavioral of thecrows is
	component vga_rom
	port(
		clk_0,reset: in std_logic;
		hs,vs: out STD_LOGIC; 
		r,g,b: out STD_LOGIC_vector(2 downto 0);
		bird1: in std_logic_vector(19 downto 0);
		bird2: in std_logic_vector(19 downto 0);
		hand: in std_logic_vector(18 downto 0)
	);
	end component;
	
	component decode
	port(
		key: in std_logic_vector(3 downto 0);
		display: out std_logic_vector(6 downto 0)
	);
	end component;

   COMPONENT debounce
   PORT(
      clk : IN std_logic;
      i : IN std_logic;          
      o : OUT std_logic
      );
   END COMPONENT;

   COMPONENT ov7670_controller
   PORT(
      clk   : IN    std_logic;    
      resend: IN    std_logic;    
      config_finished : out std_logic;
      siod  : INOUT std_logic;      
      sioc  : OUT   std_logic;
      reset : OUT   std_logic;
      pwdn  : OUT   std_logic;
      xclk  : OUT   std_logic
      );
   END COMPONENT;

   COMPONENT frame_buffer
   PORT (
      data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		rdclock		: IN STD_LOGIC ;
		wraddress		: IN STD_LOGIC_VECTOR (14 DOWNTO 0);
		wrclock		: IN STD_LOGIC  := '1';
		wren		: IN STD_LOGIC  := '0';
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
   );
   END COMPONENT;

   COMPONENT ov7670_capture
   PORT(
      pclk : IN std_logic;
      vsync : IN std_logic;
      href  : IN std_logic;
      d     : IN std_logic_vector(7 downto 0);          
      addr  : OUT std_logic_vector(14 downto 0);
      dout  : OUT std_logic_vector(15 downto 0);
      we    : OUT std_logic
      );
   END COMPONENT;


   COMPONENT vga
   PORT(
      clk50 : IN std_logic;
      vga_red : OUT std_logic_vector(2 downto 0);
      vga_green : OUT std_logic_vector(2 downto 0);
      vga_blue : OUT std_logic_vector(2 downto 0);
      vga_hsync : OUT std_logic;
      vga_vsync : OUT std_logic;
      
      frame_addr : OUT std_logic_vector(14 downto 0);
      frame_pixel : IN std_logic_vector(15 downto 0);
		h_output: out std_logic_vector(9 downto 0);
		v_output: out std_logic_vector(8 downto 0);
		size_output: out std_logic_vector(9 downto 0)
      );
   END COMPONENT;
	
	component game_logic
	port(
		clk_50: in std_logic;
		hand_pos: in std_logic_vector(18 downto 0);
		bird1, bird2: out std_logic_vector(19 downto 0);
		score_out: out integer
	);
	end component;
   
   signal frame_addr  : std_logic_vector(14 downto 0);
   signal frame_pixel : std_logic_vector(15 downto 0);

   signal capture_addr  : std_logic_vector(14 downto 0);
   signal capture_data  : std_logic_vector(15 downto 0);
   signal capture_we    : std_logic_vector(0 downto 0);
   signal resend : std_logic;
   signal config_finished : std_logic;
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
btn_debounce: debounce PORT MAP(
      clk => clk50,
      i   => btn,
      o   => resend
   );
part_vga: vga_rom port map(
	reset => '1',
	clk_0 => clk100,
	r => vga_red,
	g => vga_green,
	b => vga_blue,
	hs => vga_hsync,
	vs => vga_vsync,
	bird1 => bird1,
	bird2 => bird2,
	hand => h_output & v_output
);
   Inst_vga: vga PORT MAP(
      clk50       => clk50,
      vga_red     => vga_red_1,
      vga_green   => vga_green_1,
      vga_blue    => vga_blue_1,
      vga_hsync   => vga_hsync_1,
      vga_vsync   => vga_vsync_1,
      frame_addr  => frame_addr,
      frame_pixel => frame_pixel,
		h_output => h_output,
		v_output => v_output,
		size_output => size_output
   );
	part_d1: decode port map(
		key => "0" & h_output(3 downto 1),
		display => d1
	);
	part_d2: decode port map(
		key => "0" & h_output(6 downto 4),
		display => d2
	);
	part_d3: decode port map(
		key => "0" & h_output(9 downto 7),
		display => d3
	);
	part_d4: decode port map(
		key => "0" & v_output(2 downto 0),
		display => d4
	);
	part_d5: decode port map(
		key => "0" & v_output(5 downto 3),
		display => d5
	);
	part_d6: decode port map(
		key => "0" & v_output(8 downto 6),
		display => d6
	);
	
	part_logic: game_logic port map(
		clk_50 => clk50,
		hand_pos => h_output & v_output,
		bird1 => bird1,
		bird2 => bird2,
		score_out => score
	);

fb : frame_buffer
  PORT MAP (
    wrclock  => OV7670_PCLK,
    wren   => capture_we(0),
    wraddress => capture_addr,
    data  => capture_data,
    
    rdclock  => clk50,
    rdaddress => frame_addr,
    q => frame_pixel
  );
  led <= "0000000" & config_finished;
  
capture: ov7670_capture PORT MAP(
      pclk  => OV7670_PCLK,
      vsync => OV7670_VSYNC,
      href  => OV7670_HREF,
      d     => OV7670_D,
      addr  => capture_addr,
      dout  => capture_data,
      we    => capture_we(0)
   );
  
controller: ov7670_controller PORT MAP(
      clk   => clk50,
      sioc  => ov7670_sioc,
      resend => resend,
      config_finished => config_finished,
      siod  => ov7670_siod,
      pwdn  => OV7670_PWDN,
      reset => OV7670_RESET,
      xclk  => OV7670_XCLK
   );

end Behavioral;
