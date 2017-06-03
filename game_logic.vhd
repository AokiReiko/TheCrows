library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
entity game_logic is
	port(
		clk_50: in std_logic;
		hand_pos: in std_logic_vector(18 downto 0);
		bird1, bird2: out std_logic_vector(19 downto 0)
	);
end game_logic;

architecture arch of game_logic is
signal t: integer := 0;
signal clk_50hz: std_logic := '0';
signal bird1_pos, bird1_v, bird2_pos, bird2_v, bird1_pos_out, bird1_v_out, bird2_pos_out, bird2_v_out: std_logic_vector(28 downto 0);
signal bird1_init, bird2_init: std_logic := '1';
signal bird1_dead, bird2_dead, bird1_touch, bird2_touch, v_change: std_logic := '0';
signal random_x1, random_y1, random_x1_out, random_y1_out: integer := 26;
signal random_x2, random_y2, random_x2_out, random_y2_out: integer := 56;
signal score: integer := 1000;

signal interval: integer := 0;

constant x_max: natural := 640;
constant y_max: natural := 480;

component bird
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
	end component;
begin
	part1: bird port map(
				init => bird1_init,
				v_change => v_change,
				hand_pos => hand_pos(18 downto 9) & "00000" & hand_pos(8 downto 0) & "00000",
				bird_pos => bird1_pos,
				bird_v => bird1_v,
				random_x => random_x1,
				random_x_out => random_x1_out,
				random_y => random_y1,
				random_y_out => random_y1_out,
				bird_pos2 => bird1_pos_out,
				bird_v2 => bird1_v_out,
				bird_dead => bird1_touch
			);
	part2: bird port map(
				init => bird2_init,
				v_change => v_change,
				hand_pos => hand_pos(18 downto 9) & "00000" & hand_pos(8 downto 0) & "00000",
				bird_pos => bird2_pos,
				bird_v => bird2_v,
				random_x => random_x2,
				random_x_out => random_x2_out,
				random_y => random_y2,
				random_y_out => random_y2_out,
				bird_pos2 => bird2_pos_out,
				bird_v2 => bird2_v_out,
				bird_dead => bird2_touch
			);
	process(clk_50)
	begin
		if rising_edge(clk_50) then
			t <= t+1;
			if t = 500000 then
				t <= 0;
				clk_50hz <= not clk_50hz;
			end if;
		end if;
	end process;
	process(clk_50hz)
	begin
		if rising_edge(clk_50hz) then
			bird1_pos <= bird1_pos_out;
			bird1_v <= bird1_v_out;
			bird2_pos <= bird2_pos_out;
			bird2_v <= bird2_v_out;
			random_x1 <= random_x1_out;
			random_y1 <= random_y1_out;
			random_x2 <= random_x2_out;
			random_y2 <= random_y2_out;
			
			bird1_dead <= bird1_dead or bird1_touch;
			bird2_dead <= bird2_dead or bird2_touch;
			
			bird1 <= bird1_pos(28 downto 19) & bird1_pos(13 downto 5) & bird1_dead;
			bird2 <= bird2_pos(28 downto 19) & bird1_pos(13 downto 5) & bird2_dead;
			
			if bird1_pos(28 downto 19) >= x_max or bird1_pos(13 downto 5) >= y_max then
				bird1_init <= '1';
				if bird1_dead = '0' then
					score <= score - 50;
				end if;
				bird1_dead <= '0';
			else
				bird1_init <= '0';
			end if;
			if bird2_pos(28 downto 19) >= x_max or bird2_pos(13 downto 5) >= y_max then
				bird2_init <= '1';
				if bird2_dead = '0' then
					score <= score - 50;
				end if;
				bird2_dead <= '0';
			else
				bird2_init <= '0';
			end if;
			interval <= interval + 1;
			if interval = 5 then
				interval <= 0;
				v_change <= '1';
			else
				v_change <= '0';
			end if;
		end if;
	end process;
end arch;