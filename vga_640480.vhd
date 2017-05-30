library	ieee;
use		ieee.std_logic_1164.all;
use		ieee.std_logic_unsigned.all;
use		ieee.std_logic_arith.all;
use 		ieee.numeric_std.all;
entity vga640480 is
	 port(
			address_hand:		out std_logic_vector(13 downto 0);
			address_back:		out std_LOGIC_vector(14 downto 0);
			q_back		:		in std_LOGIC_vector(7 downto 0);
			q_hand 		: 		in std_logic_vector(7 downto 0);
			address		:		  out	STD_LOGIC_VECTOR(14 DOWNTO 0);
			reset       :         in  STD_LOGIC;
			q		    :		  in STD_LOGIC_vector(7 downto 0);
			clk100       :         in  STD_LOGIC; 
			hs,vs       :         out STD_LOGIC; 
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			bird1: in std_logic_vector(19 downto 0);
			bird2: in std_logic_vector(19 downto 0);
			hand: in std_logic_vector(18 downto 0)
	  );
end vga640480;

architecture behavior of vga640480 is
	signal r1,g1,b1   : std_logic_vector(2 downto 0);					
	signal hs1,vs1    : std_logic;				
	signal vector_x : std_logic_vector(9 downto 0);		
	signal vector_y : std_logic_vector(8 downto 0);	
	signal clk25, clk50, clk_1hz:	 std_logic;
	signal bird_state: std_LOGIC_vector(2 downto 0):="000";
	signal hand_state: std_logic_vector(1 downto 0):="00";
	signal bird1_pos		: std_logic_vector(19 downto 0):="00001111110000111110";--19~10:x  9~1: y 0:state
	signal bird2_pos		: std_logic_vector(19 downto 0):="00010111110000111110";
	signal hand_pos		: std_logic_vector(18 downto 0):="0010111110000111110";
	signal addr_back_s	:std_logic_vector(14 downto 0):=(others=>'0');
begin
address_back <= addr_back_s;
--bird1_pos <= "00001111110000111110";
--bird2_pos <= "00100111110001010110";
--hand_pos  <= "0010011111000110110";
 -----------------------------------------------------------------------
  process(clk100)	
    begin
        if(clk100'event and clk100='1') then 
             clk50 <= not clk50;
        end if;
 	end process;
----------------------------------------------------------------------
process(clk100)	
	variable num: integer;
begin
    if(clk100'event and clk100='1') then 
         num := num + 1;
			 if (num = 5000000) then
				num := 0;
				clk_1hz <= not clk_1hz;
			end if;
    end if;
end process;

process(clk50)	
begin
    if(clk50'event and clk50='1') then 
         clk25 <= not clk25;
    end if;
end process;

process(clk_1hz)
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
process(clk25, reset)
begin
	if rising_edge(clk25) then
		if vs1='0' then
			addr_back_s <= (others=>'0');
		elsif vector_x < 640 and vector_y < 480 then
			if vector_x=639 then
				if vector_y(1 downto 0)/="11" then
					addr_back_s <= addr_back_s - 159;
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
			if (vector_x > 640) then
				g1  <= "000";
				b1	<= "000";
				r1	<= "000";
			else
			g1  <= q_back(7 downto 5);
			b1	<= q_back(4 downto 2);
			r1	<= q_back(1 downto 0)&"0";
			
			if  vector_y > bird1_pos(9 downto 1) and bird1_dy <= 63 
		and  vector_x > bird1_pos(19 downto 10) and bird1_dx <= 63 then
			address <= bird_state & bird1_dy(5 downto 0) & bird1_dx(5 downto 0);
				if q /= "10011100" then
					r1 <=q(7 downto 5);				  	
					g1 <=q(4 downto 2);
					b1 <= q(1 downto 0)&"1";
				end if;
			end if;
			if  vector_y > bird2_pos(9 downto 1) and bird2_dy <= 63
		and  vector_x > bird2_pos(19 downto 10) and bird2_dx <= 63	
		 then
				address <= bird_state & bird2_dy(5 downto 0) & bird2_dx(5 downto 0);
				if q /= "10011100" then
					r1 <=q(7 downto 5);				  	
					g1 <=q(4 downto 2);
					b1 <= q(1 downto 0)&"1";
				
				end if;
			end if;
			if  vector_y > hand_pos(8 downto 0) and hand_dy <= 63 
			and  vector_x > hand_pos(18 downto 9) and hand_dx <= 63 then
				address_hand <= hand_state & hand_dy(5 downto 0) & hand_dx(5 downto 0);
				if q_hand /= "10011100" then
					r1 <=q_hand(7 downto 5);				  	
					g1 <=q_hand(4 downto 2);
					b1 <= q_hand(1 downto 0)&"1";
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

