library	ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;
use 		ieee.numeric_std.all;
use work.render_info.all;
entity vga640480 is
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
			game_state: in std_logic_vector(1 downto 0);--10 lose 11 win

			sram_addr : out std_logic_vector(19 downto 0);
			sram_data : in std_logic_vector(31 downto 0)

	  );
end vga640480;

architecture behavior of vga640480 is

	signal clk_1hz		: std_logic;
	signal r1,g1,b1   : std_logic_vector(2 downto 0);					
	signal hs1,vs1    : std_logic;				
	signal vector_x : std_logic_vector(9 downto 0);		
	signal vector_y : std_logic_vector(8 downto 0);	

	signal bird_state: std_LOGIC_vector(2 downto 0):="000";
	signal hand_state: std_logic_vector(1 downto 0):="00";
	signal bird1_pos		: std_logic_vector(19 downto 0):="00001111110000111110";--19~10:x  9~1: y 0:state
	signal bird2_pos		: std_logic_vector(19 downto 0):="00010111110000111110";
	signal hand_pos		: std_logic_vector(18 downto 0):="0010111110000111110";
	signal addr_back_s	:std_logic_vector(13 downto 0):=(others=>'0');
	signal address : std_logic_vector(19 downto 0);

begin
--bird1_pos <= "01001111110000111111";
--bird2_pos <= "00100111110001010110";
--hand_pos  <= "0010011111000110110";
 sram_addr <= address;
----------------------------------------------------------------------
process(clk25)	
	variable num: integer;
begin
    if(clk25'event and clk25='1') then 
         num := num + 1;
			 if (num = 1250000) then
				num := 0;
				clk_1hz <= not clk_1hz;
			end if;
    end if;
end process;

---------------------------------------------------------------------
process(clk_1hz)--birdstate
begin
	if(rising_edge(clk_1hz)) then
	if (hand_state=3) then
			hand_state <= "00";
		else
			hand_state <= hand_state + 1;
		end if;
		if (bird_state=7) then
			bird_state <= "000";
		else
			bird_state <= bird_state + 1;
		end if;
	end if;
end process;		

-----------------------------------------------------------------------
process(clk25, reset)--background
begin
	if rising_edge(clk25) then
		if vs1='0' then
			addr_back_s <= (others=>'0');
		elsif vector_x < 640 and vector_x >= 160 and vector_y < 480 then
			if vector_x=639 then
				if vector_y(1 downto 0)/="11" then
					addr_back_s <= addr_back_s - 119;
				else
					addr_back_s <= addr_back_s + 1;
				end if;
			elsif vector_x(1 downto 0)="11" then
				addr_back_s <= addr_back_s + 1;
			end if;
		end if;
	
	end if;
end process;
 
  -----------------------------------------------------------------------
	 process(clk25,reset)	
	 begin
	  	if reset='0' then
	   		vector_y <= (others=>'0');
	  	elsif clk25'event and clk25='1' then
	  		if (vector_x < 640 and vector_x(0) = '1') then
	  			address <= address + 1;
	  		end if;
	  		if (vector_y > 480) then
				case game_state is
				when "01" => 
					address <= std_logic_vector(to_unsigned(0,address'length));
				when "00" =>
					address <= std_logic_vector(to_unsigned(153600,address'length));
				when "10" => 
					address <= std_logic_vector(to_unsigned(307200,address'length));
				when "11" => 
					address <= std_logic_vector(to_unsigned(image_address(3),address'length));
				end case;
	  			
	  		end if;
	   		if vector_x=799 then
					vector_x <= (others =>'0');
					
					
					if vector_y=524 then
						vector_y <= (others=>'0');
					else
						vector_y <= vector_y + 1;
					end if;
					
				else
					
					vector_x <= vector_x + 1;
	   		end if;
	  	end if;
	 end process;
 
  -----------------------------------------------------------------------
	 process(clk25,reset) 
	 begin
		  if reset='0' then
		   hs1 <= '1';
		  elsif clk25'event and clk25='1' then
		   	if vector_x>656 and vector_x<=752 then
		    	hs1 <= '0';
		   	else
		    	hs1 <= '1';
		   	end if;
		  end if;
	 end process;
 
 -----------------------------------------------------------------------
	 process(clk25,reset) 
	 begin
	  	if reset='0' then
	   		vs1 <= '1';
	  	elsif clk25'event and clk25='1' then
	   		if vector_y>=491 and vector_y<493 then
	    		vs1 <= '0';
	   		else
	    		vs1 <= '1';
	   		end if;
	  	end if;
	 end process;
 -----------------------------------------------------------------------
	 process(clk25,reset) 
	 begin
	  	if reset='0' then
	   		hs <= '0';
	  	elsif clk25'event and clk25='1' then
	   		hs <=  hs1;
	  	end if;
	 end process;

 -----------------------------------------------------------------------
	 process(clk25,reset) 
	 begin
	  	if reset='0' then
	   		vs <= '0';
	  	elsif clk25'event and clk25='1' then
	   		vs <=  vs1;
	  	end if;
	 end process;
	
 -----------------------------------------------------------------------	
	process(reset,clk25,vector_x,vector_y,bird_state) 
	variable det_hand: integer;
	variable hand_dy: std_LOGIC_vector(8 downto 0);
	variable hand_dx: std_LOGIC_vector(9 downto 0);
	
	variable bird1_dy: std_LOGIC_vector(8 downto 0);
	variable bird1_dx: std_LOGIC_vector(9 downto 0);
	variable bird2_dy: std_LOGIC_vector(8 downto 0);
	variable bird2_dx: std_LOGIC_vector(9 downto 0);
	
	variable life_dx: std_LOGIC_vector(9 downto 0);
	variable life_dy: std_LOGIC_vector(8 downto 0);
	variable life_anchor: std_logic_vector(8 downto 0);
	variable det1: integer;
	variable det2: integer;
	
	begin  
		
		if(clk25'event and clk25='1')then

			hand_dy	:= vector_y - hand_pos(8 downto 0);
			hand_dx 	:= vector_x - hand_pos(18 downto 9);
			
			bird1_dy := vector_y - bird1_pos(9 downto 1);
			bird2_dy := vector_y - bird2_pos(9 downto 1);
			bird1_dx := vector_x - bird1_pos(19 downto 10);
			bird2_dx := vector_x - bird2_pos(19 downto 10);
			
			life_dx := vector_x - 50;
			life_dy := vector_y - 100;
			life_anchor := vector_y - score;

			if vector_x > 640 then
				g1  <= "000";
				b1	<= "000";
				r1	<= "000";
			else
				--background
				if (vector_x(0)='0') then
					r1 <= sram_data(9 downto 7);
					g1 <= sram_data(6 downto 4);
					b1 <= sram_data(3 downto 1);
				else
					r1 <= sram_data(25 downto 23);
					g1 <= sram_data(22 downto 20);
					b1 <= sram_data(19 downto 17);
				end if;


				if game_state="01" then
				if (vector_x >= 50 and vector_x < 114 and vector_y >= 100 and vector_y < 356) then
					obj_address.address_life <= life_dy(7 downto 0) & life_dx(5 downto 0);
					

					if obj_data.q_life /= 119 then
						if (vector_y > score + 100) then
							r1  <= obj_data.q_life(7 downto 5);
							g1	<= obj_data.q_life(4 downto 2);
							b1	<= obj_data.q_life(1 downto 0) & "1";
						else
							g1  <= obj_data.q_life(7 downto 5);
							r1	<= obj_data.q_life(4 downto 2);
							b1	<= obj_data.q_life(1 downto 0) & "1";
						end if;
					end if;
					if vector_y - 100 < score + 8 and vector_y - 100 >= score then
						obj_address.address_anchor <= life_anchor(2 downto 0) & life_dx(5 downto 0);
						if obj_data.q_anchor /= 123 then
							r1  <= obj_data.q_anchor(7 downto 5);
							g1	<= obj_data.q_anchor(4 downto 2);
							b1	<= obj_data.q_anchor(1 downto 0) & "1";
						end if;
					end if;

				end if;
				--first bird
				if bird1(0) = '0' and vector_y > bird1_pos(9 downto 1) and bird1_dy <= 63 
			and  vector_x > bird1_pos(19 downto 10) and bird1_dx <= 63 then
					obj_address.address_bird <= bird_state & bird1_dy(5 downto 0) & bird1_dx(5 downto 0);
					if obj_data.q_bird /= "10011100" then
						r1 <= obj_data.q_bird(7 downto 5);				  	
						g1 <= obj_data.q_bird(4 downto 2);
						b1 <= obj_data.q_bird(1 downto 0)&"1";
					end if;
				end if;
				--second bird
				if  bird2(0) = '0' and vector_y > bird2_pos(9 downto 1) and bird2_dy <= 63
			and  vector_x > bird2_pos(19 downto 10) and bird2_dx <= 63	
			 then
					obj_address.address_bird <= bird_state & bird2_dy(5 downto 0) & bird2_dx(5 downto 0);
					if obj_data.q_bird /= "10011100" then
						r1 <= obj_data.q_bird(7 downto 5);				  	
						g1 <= obj_data.q_bird(4 downto 2);
						b1 <= obj_data.q_bird(1 downto 0)&"1";
					end if;
				end if;
				--hand

				if vector_y > hand_pos(8 downto 0) and hand_dy <= 63 
				and  vector_x > hand_pos(18 downto 9) and hand_dx <= 63 then

					obj_address.address_hand <= hand_state & hand_dy(5 downto 0) & hand_dx(5 downto 0);
					obj_address.address_dead <= hand_state(0) & hand_dy(5 downto 0) & hand_dx(5 downto 0);
					if is_hold='1' then
						if obj_data.q_dead /= "00011100" then
							r1 <= obj_data.q_dead(7 downto 5);				  	
							g1 <= obj_data.q_dead(4 downto 2);
							b1 <= obj_data.q_dead(1 downto 0)&"1";
						end if;
					else

						if obj_data.q_hand /= "10011100" then
							if is_hold='0' then
								r1 <= obj_data.q_hand(7 downto 5);
							else
								r1 <= "111";
							end if;
							g1 <= obj_data.q_hand(4 downto 2);
							b1 <= obj_data.q_hand(1 downto 0)&"1";
						end if;
					end if;
			end if;
			end if;
		end if;
		end if;
	end process;	

	-----------------------------------------------------------------------
	process (hs1, vs1, r1, g1, b1)	
	begin
		if hs1 = '1' and vs1 = '1' then
			r	<= r1;
			g	<= g1;
			b	<= b1;
		else
			r	<= (others => '0');
			g	<= (others => '0');
			b	<= (others => '0');
			hand_pos <= hand;
			bird1_pos <= bird1;
			bird2_pos <= bird2;
		end if;
	end process;

end behavior;

