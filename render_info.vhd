library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package render_info is 
	
	type obj_addr is record
		address_hand:	 std_logic_vector(13 downto 0);
		address_back:	 std_LOGIC_vector(13 downto 0);
		address_dead:	 std_LOGIC_vector(12 downto 0);
		address_bird:	 std_LOGIC_VECTOR(14 DOWNTO 0);
		address_life:	 std_logic_vector(13 downto 0);
	end record;

	type obj_d is record
		q_dead		:	 std_LOGIC_vector(7 downto 0);
		q_back		:	 std_LOGIC_vector(7 downto 0);
		q_hand 		: 	 std_logic_vector(7 downto 0);
		q_bird		:	 std_LOGIC_vector(7 downto 0);
		q_life		:	 std_LOGIC_vector(7 downto 0);
end record;

end package;