library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity bird is
	port(
		init, v_change: in std_logic;
		hand_pos: in std_logic_vector(28 downto 0);
		bird_pos: in std_logic_vector(28 downto 0);
		bird_v: in std_logic_vector(28 downto 0);
		random_x, random_y: in integer;
		random_x_out, random_y_out: out integer;
		bird_pos2: out std_logic_vector(28 downto 0);
		bird_v2: out std_logic_vector(28 downto 0);
		bird_dead: out std_logic
	);
end bird;

architecture arch of bird is
signal bird_x, hand_x: std_logic_vector(14 downto 0);
signal bird_y, bird_vy, hand_y: std_logic_vector(13 downto 0);
signal is_dead, tmp_x, tmp_y: std_logic;

constant x_max: integer := 528;
constant y_max: integer := 314;

begin
	random_x_out <= (random_x * random_x + 3 * random_x + 47) mod x_max;
	random_y_out <= (random_y * random_y + 5 * random_y + 67) mod y_max;
	process(init, hand_pos, bird_pos, bird_v)
	begin
		if init = '0' then
			bird_x <= bird_pos(28 downto 14) + bird_v(28 downto 14);
			bird_y <= bird_pos(13 downto 0) + bird_v(13 downto 0);
			hand_x <= hand_pos(28 downto 14);
			hand_y <= hand_pos(13 downto 0);
			bird_vy <= bird_v(13 downto 0) + "00000000000110";
			if (bird_x <= hand_x and hand_x(14 downto 6) - bird_x(14 downto 6) <= "0000000100") or (bird_x >= hand_x and bird_x(14 downto 6) - hand_x(14 downto 6) <= "0000000100") then
				tmp_x <= '1';
			else
				tmp_x <= '0';
			end if;
			if (bird_y <= hand_y and hand_y(13 downto 6) - bird_y(13 downto 6) <= "000000100") or (bird_y >= hand_y and bird_y(13 downto 6) - hand_y(13 downto 6) <= "000000100") then
				tmp_y <= '1';
			else
				tmp_y <= '0';
			end if;
			is_dead <= tmp_x and tmp_y;
			bird_pos2 <= bird_x & bird_y;
			bird_v2 <= bird_v(28 downto 14) & bird_vy;
			bird_dead <= is_dead;
		else
			bird_x <= conv_std_logic_vector(random_x, 10) & "00000";
			bird_y <= conv_std_logic_vector(random_y, 9) & "00000";
			bird_pos2 <= bird_x & bird_y;
			bird_v2 <= "000000001100000" & ("11111101000000");
			bird_dead <= '0';
		end if;
	end process;
end arch;