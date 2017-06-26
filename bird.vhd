library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity bird is
	port(
		init, v_change: in std_logic; -- init：是否重置
		hand_pos: in std_logic_vector(28 downto 0);
		bird_pos: in std_logic_vector(28 downto 0);
		bird_v: in std_logic_vector(28 downto 0);
		random_x, random_y: in integer;
		random_x_out, random_y_out: out integer;
		bird_pos2: out std_logic_vector(28 downto 0);
		bird_v2: out std_logic_vector(28 downto 0);
		bird_dead: out std_logic;
		touch_flag: in std_logic
	);
end bird;

architecture arch of bird is
signal bird_x, bird_vx, hand_x: std_logic_vector(14 downto 0);
signal bird_y, bird_vy, hand_y: std_logic_vector(13 downto 0);
signal is_dead, tmp_x, tmp_y: std_logic;

constant x_max: integer := 640;
constant y_max: integer := 480;

begin
	--random_x_out <= (random_x * random_x + 3 * random_x + 47) mod x_max;
	--random_y_out <= (random_y * random_y + 5 * random_y + 67) mod y_max;
	random_x_out <= (random_x*3) mod x_max;
	random_y_out <= (random_y*5) mod y_max;
	process(init, hand_pos, bird_pos, bird_v)
	begin
		if init = '0' then -- 非重置，进行模拟
			bird_x <= bird_pos(28 downto 14) + bird_v(28 downto 14); -- 更新位置
			bird_y <= bird_pos(13 downto 0) + bird_v(13 downto 0);
			hand_x <= hand_pos(28 downto 14);
			hand_y <= hand_pos(13 downto 0);
			bird_vy <= bird_v(13 downto 0) + "00000000000110";
			if (bird_x <= hand_x and hand_x(14 downto 6) - bird_x(14 downto 6) <= "0000011000") or (bird_x >= hand_x and bird_x(14 downto 6) - hand_x(14 downto 6) <= "0000011000") then
				tmp_x <= '1';
			else
				tmp_x <= '0';
			end if;
			if (bird_y <= hand_y and hand_y(13 downto 6) - bird_y(13 downto 6) <= "000011000") or (bird_y >= hand_y and bird_y(13 downto 6) - hand_y(13 downto 6) <= "000011000") then
				tmp_y <= '1';
			else
				tmp_y <= '0';
			end if;
			is_dead <= tmp_x and tmp_y and touch_flag;
			bird_pos2 <= bird_x & bird_y;
			if is_dead = '1' then
				bird_v2 <= "000000000000000" & "11111111110000";
			else
				bird_v2 <= bird_v(28 downto 14) & bird_vy; -- 更新速度
			end if;
			bird_dead <= is_dead;
		else -- 利用随机数重置乌鸦
			bird_x <= conv_std_logic_vector(random_x, 10) & "00000";
			if random_y <= 100 then
				bird_y <= conv_std_logic_vector(random_y+100, 9) & "00000";
			else
				bird_y <= conv_std_logic_vector(random_y, 9) & "00000";
			end if;
			bird_pos2 <= bird_x & bird_y;
			-- bird_v2 <= "000000001100000" & ("11111101000000");
			bird_vx <= "0000000" & bird_x(8 downto 5) & "0000";
			if random_x <= x_max / 2 then
				bird_v2 <= bird_vx & ("11111101000000");
			else
				bird_v2 <= ("000000000000000" - bird_vx) & ("11111101000000");
			end if;
			bird_dead <= '0';
		end if;
	end process;
end arch;