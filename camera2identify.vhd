library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;


entity camera2identify is
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
		
		btn : in std_logic
	);

end camera2identify;



architecture c2i of camera2identify is

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


   COMPONENT identify
   PORT(
      clk50 : IN std_logic;
      frame_addr : OUT std_logic_vector(14 downto 0);
      frame_pixel : IN std_logic_vector(15 downto 0);
		h_output: out std_logic_vector(9 downto 0);
		v_output: out std_logic_vector(8 downto 0);
		size_output: out std_logic_vector(9 downto 0)
      );
   END component;

signal frame_addr  : std_logic_vector(14 downto 0);
signal frame_pixel : std_logic_vector(15 downto 0);

signal capture_addr  : std_logic_vector(14 downto 0);
signal capture_data  : std_logic_vector(15 downto 0);
signal capture_we    : std_logic_vector(0 downto 0);

signal resend : std_logic;
signal config_finished : std_logic;
signal clk50: std_logic;

begin


process(clk100)
begin
	if rising_edge(clk100) then	
		clk50 <= not clk50;
	end if;
end process;

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
btn_debounce: debounce PORT MAP(
      clk => clk50,
      i   => btn,
      o   => resend
   );
iden: identify PORT MAP(
      clk50       => clk50,
      frame_addr  => frame_addr,
      frame_pixel => frame_pixel,
	  h_output => h_output,
	  v_output => v_output,
	  size_output => size_output
   );
	


















end architecture;