----------------------------------------------------------------------------------
-- Engineer: Mike Field <hamster@snap.net.nz>
-- 
-- Description: Generate analog 800x600 VGA, double-doublescanned from 19200 bytes of RAM
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

entity identify is
    Port ( 
      clk50       : in  STD_LOGIC;
      frame_addr  : out STD_LOGIC_VECTOR(14 downto 0);
      frame_pixel : in  STD_LOGIC_VECTOR(15 downto 0);
		h_output : out std_logic_vector(9 downto 0);
		v_output : out std_logic_vector(8 downto 0);
		size_output : out std_logic_vector(9 downto 0)
    );
end identify;

architecture Behavioral of identify is
   -- Timing constants
   constant hRez       : natural := 800;--800
   constant vRez       : natural := 600;--600

   constant hMaxCount  : natural := 1056;--1056
   constant hStartSync : natural := 840;--840
   constant hEndSync   : natural := 968;--968
   constant vMaxCount  : natural := 628;--628
   constant vStartSync : natural := 601;--601
   constant vEndSync   : natural := 605;--605
   constant hsync_active : std_logic := '1';
   constant vsync_active : std_logic := '1';

	signal clk25	 : std_logic;
   signal hCounter : unsigned(10 downto 0) := (others => '0');
   signal vCounter : unsigned(9 downto 0) := (others => '0');
   signal address : unsigned(16 downto 0) := (others => '0');
   signal blank : std_logic := '1';
	signal t_red, t_green, t_blue : std_logic_vector(1 downto 0);
	signal last_pixel, last2_pixel, last3_pixel, last4_pixel: std_logic_vector(15 downto 0);
	signal up_index, index_low, index_high: unsigned(10 downto 0) := (others => '0');
	signal h_ans: unsigned(10 downto 0);
	signal v_ans: unsigned(9 downto 0);
	signal flag: std_logic := '0';
	signal total_num, total_size_output: unsigned(12 downto 0) := (others => '0');
begin
   frame_addr <= std_logic_vector(address(16 downto 2));
   process(clk50)
	begin
		if (rising_edge(clk50)) then
			clk25<=clk25;
		end if;
	end process;
   process(clk50)
   begin
      if rising_edge(clk50) then
         -- Count the lines and rows      
			if hCounter = "00000000000" and vCounter = "00000000000" then
				size_output <= std_logic_vector(total_size_output / total_num)(9 downto 0);
				flag <= '0';
				total_num <= (others => '0');
				total_size_output <= (others => '0');
			end if;
         if hCounter = hMaxCount-1 then
            hCounter <= (others => '0');
            if vCounter = vMaxCount-1 then
               vCounter <= (others => '0');
            else
               vCounter <= vCounter+1;
            end if;
         else
            hCounter <= hCounter+1;
         end if;
			
         if blank = '0' then
--				if (frame_pixel(15 downto 13) >= "100") and (last3_pixel(15 downto 13) <= "010") then
--					t_red <= "111";
--				elsif (last3_pixel(15 downto 13) >= "100") and (frame_pixel(15 downto 13) <= "010") then
--					t_red <= "001";
--				else
--					t_red <= "000";
--				end if;
--				if (frame_pixel(10 downto 8) >= "100") and (last3_pixel(10 downto 8) <= "010") then
--					t_green <= "111";
--				elsif (last3_pixel(10 downto 8) >= "100") and (frame_pixel(10 downto 8) <= "010") then
--					t_green <= "001";
--				else
--					t_green <= "000";
--				end if;
--				if (frame_pixel(4 downto 2) >= "100") and (last3_pixel(4 downto 2) <= "010") then
--					t_blue <= "111";
--				elsif (last3_pixel(4 downto 2) >= "100") and (frame_pixel(4 downto 2) <= "010") then
--					t_blue <= "001";
--				else
--					t_blue <= "000";
--				end if;
				if (frame_pixel(15 downto 13) >= "111") then
					t_red <= "11";
				elsif (frame_pixel(15 downto 13) <= "100") then
					t_red <= "01";
				else
					t_red <= "00";
				end if;
				if (frame_pixel(10 downto 8) >= "111") then
					t_green <= "11";
				elsif (frame_pixel(10 downto 8) <= "100") then
					t_green <= "01";
				else
					t_green <= "00";
				end if;
				if (frame_pixel(4 downto 2) >= "111") then
					t_blue <= "11";
				elsif (frame_pixel(4 downto 2) <= "100") then
					t_blue <= "01";
				else
					t_blue <= "00";
				end if;
				
				if (t_red = "11") and (t_green = "11") and (t_blue = "11") then
					if (hCounter - index_low >= "00000001000") and (hCounter - index_low <= "00000010000") then
						index_low <= (others => '0');
						up_index <= hCounter;
					else

					end if;
					index_high <= hCounter;
				elsif (t_red = "01") and (t_green = "01") and (t_blue = "01") then
					if (hCounter - index_high >= "00000001000") and (hCounter - index_high <= "00000010000") then
						index_high <= (others => '0');
						if hCounter - up_index <= "00010000000" then
							if flag = '0' then
								h_ans <= hCounter;
								v_ans <= vCounter;
								flag <= '1';
								h_output <= "1001000000" - std_logic_vector(h_ans)(9 downto 0); -- /1056 * 1280
								v_output <= std_logic_vector(v_ans)(8 downto 0) - "000010000"; -- /628 * 960
							end if;
							total_size_output <= total_size_output + (hCounter - up_index);
							total_num <= total_num + 1;
						end if;
					else
						
					end if;
					index_low <= hCounter;
				end if;
         end if;
         if vCounter  >= vRez then
            address <= (others => '0');
            blank <= '1';
         else 
            if hCounter  >= 0 and hCounter  < 640 then
               blank <= '0';
               if hCounter = 639 then
                  if vCounter(1 downto 0) /= "11" then
                     address <= address - 639;
                  else
                      address <= address+1;
                  end if;
               else
                  address <= address+1;
               end if;
            else
               blank <= '1';
            end if;
         end if;
   
      end if;
   end process;
end Behavioral;

