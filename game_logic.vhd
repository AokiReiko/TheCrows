library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity game_logic is
	port(
		clk_50: in std_logic;
		hand_pos: in std_logic_vector(18 downto 0); -- 识别所得位置
		size: in std_logic_vector(9 downto 0); -- 识别所得大小
		bird1, bird2: out std_logic_vector(19 downto 0); -- 输出乌鸦信息
		is_hold: out std_logic; -- 是否处于敲击状态
		score_out: out integer; -- 游戏得分
		hold_bird1, hold_bird2: out std_logic; -- 乌鸦是否被抓住
		touch_flag_out: out std_logic; -- 是否抓住乌鸦
		game_state_out: out std_logic_vector(1 downto 0) -- 游戏状态，00为开始画面，01为游戏中状态，10为胜利状态，11为失败状态
	);
end game_logic;

architecture arch of game_logic is
type A1 is array(1 downto 0) of std_logic;
type A28 is array(1 downto 0) of std_logic_vector(28 downto 0);
type A19 is array(1 downto 0) of std_logic_vector(19 downto 0);
type A1_int is array(1 downto 0) of integer;
signal bird_signal: A19;
signal t: integer := 0;
signal clk_50hz: std_logic := '0'; -- 帧信号
signal bird_pos, bird_v, bird_pos_out, bird_v_out: A28; -- 乌鸦位置、速度
signal bird_init: A1 := ('0', '0'); -- 是否重置乌鸦
signal bird_dead, bird_touch: A1 := ('0', '0'); -- 乌鸦死亡状态、被敲击状态
signal v_change: std_logic := '0';
signal random_x, random_y, random_x_out, random_y_out: A1_int := (26, 58); -- 伪随机数
signal score: integer := 128;
signal begin_size, last_size: std_logic_vector(9 downto 0); -- 记录敲击
signal size_inc_time: integer := 0; -- 记录识别大小增加时间，用于识别敲击

signal touch_flag: std_logic;
signal hold_flag: std_logic;

signal interval: integer := 0;
signal flag_hold_bird: A1 := ('0', '0');
signal hold_bird: A1_int := (0, 0);

signal game_state : std_logic_vector(1 downto 0) := "00";
signal game_init_timer : integer := 0;
constant x_max: natural := 640;
constant y_max: natural := 480;

component bird -- 对单只乌鸦进行单帧模拟
	port(
		init, v_change: in std_logic;
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
	end component;
begin
	part1: bird port map(
				init => bird_init(0),
				v_change => v_change,
				hand_pos => hand_pos(18 downto 9) & "00000" & hand_pos(8 downto 0) & "00000",
				bird_pos => bird_pos(0),
				bird_v => bird_v(0),
				random_x => random_x(0),
				random_x_out => random_x_out(0),
				random_y => random_y(0),
				random_y_out => random_y_out(0),
				bird_pos2 => bird_pos_out(0),
				bird_v2 => bird_v_out(0),
				bird_dead => bird_touch(0),
				touch_flag => touch_flag
			);
	part2: bird port map(
				init => bird_init(1),
				v_change => v_change,
				hand_pos => hand_pos(18 downto 9) & "00000" & hand_pos(8 downto 0) & "00000",
				bird_pos => bird_pos(1),
				bird_v => bird_v(1),
				random_x => random_x(1),
				random_x_out => random_x_out(1),
				random_y => random_y(1),
				random_y_out => random_y_out(1),
				bird_pos2 => bird_pos_out(1),
				bird_v2 => bird_v_out(1),
				bird_dead => bird_touch(1),
				touch_flag => touch_flag
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
		if rising_edge(clk_50hz) then -- 游戏开始画面
			game_state_out <= game_state;
			if game_state = "00" then
				game_init_timer <= game_init_timer + 1;
				if game_init_timer = 400 then
					game_state <= "01";
					game_init_timer <= 0;
					is_hold <= '0';
				end if;
			elsif game_state = "01" then -- 游戏中
				
				for i in 0 to 1 loop
					bird_pos(i) <= bird_pos_out(i); -- 更新位置、速度
					bird_v(i) <= bird_v_out(i);
					random_x(i) <= random_x_out(i);
					random_y(i) <= random_y_out(i);
					if flag_hold_bird(i) = '1' then -- 乌鸦被抓住，计时，1s后重置乌鸦
						hold_bird(i) <= hold_bird(i) + 1;
						if hold_bird(i) = 50 then
							flag_hold_bird(i) <= '0';
							hold_bird(i) <= 0;
							is_hold <= '0';
							bird_pos(i) <= hand_pos(18 downto 9) & "00000" & hand_pos(8 downto 0) & "00000";
							-- bird_v(i)
						end if;
					end if;
				end loop;
				
				hold_bird1 <= flag_hold_bird(0);
				hold_bird2 <= flag_hold_bird(1);
				
				if size >= last_size - 1 then -- 判断是否正在敲击
					size_inc_time <= size_inc_time + 1;
					if size - begin_size >= "0000001000" and size /= "1111111111" and size_inc_time >= 10 then
						touch_flag <= '1';
					else
						touch_flag <= '0';
					end if;
				else
					size_inc_time <= 0;
					begin_size <= size;
					touch_flag <= '0';
				end if;
				
				touch_flag_out <= touch_flag;
				
				last_size <= size;
				
				for i in 0 to 1 loop -- 计算分数及胜利、失败状态
					if bird_dead(i) = '0' and bird_touch(i) = '1' then
						score <= score + 15;
						score_out <= score;
						if score >= 256 then
							game_state <= "10";
						end if;
						if flag_hold_bird(i) = '0' then
							flag_hold_bird(i) <= '1';
							is_hold <= '1';
						end if;
					end if;
					
					bird_dead(i) <= bird_dead(i) or bird_touch(i); -- 死亡状态
					
					bird_signal(i) <= bird_pos(i)(28 downto 19) & bird_pos(i)(13 downto 5) & bird_dead(i); -- 计算输出信号
					
					if bird_pos(i)(28 downto 19) >= x_max or bird_pos(i)(13 downto 5) >= y_max then -- 若离开屏幕，重置乌鸦
						bird_init(i) <= '1';
						if bird_dead(i) = '0' then
							score <= score - 4;
							score_out <= score;
							if score < 0 then
								game_state <= "11";
							end if;
						end if;
						bird_dead(i) <= '0';
					else
						bird_init(i) <= '0';
					end if;
					
				end loop;
				bird1 <= bird_signal(0);
				bird2 <= bird_signal(1);
				interval <= interval + 1;
				if interval = 5 then
					interval <= 0;
					v_change <= '1';
				else
					v_change <= '0';
				end if;
			else
				game_init_timer <= game_init_timer + 1; -- 重新开始游戏
				if game_init_timer = 400 then
					game_state <= "01";
					game_init_timer <= 0;
					score <= 128;
					is_hold <= '0';
				end if;
			end if;
		end if;
		
	end process;
end arch;
