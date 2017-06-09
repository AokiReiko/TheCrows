library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package render_info is 
	
	type img_addr is array (0 to 3) of integer;
	constant image_address : img_addr := (0,153600,307200,460800);

	type obj_addr is record
		address_hand:	 std_logic_vector(13 downto 0);
		address_dead:	 std_LOGIC_vector(12 downto 0);
		address_bird:	 std_LOGIC_VECTOR(14 DOWNTO 0);
		address_life:	 std_logic_vector(13 downto 0);
		address_anchor:	 std_logic_vector(8 downto 0);
	end record;

	type obj_d is record
		q_dead		:	 std_LOGIC_vector(7 downto 0);
		q_hand 		: 	 std_logic_vector(7 downto 0);
		q_bird		:	 std_LOGIC_vector(7 downto 0);
		q_life		:	 std_LOGIC_vector(7 downto 0);
		q_anchor	:	 std_logic_vector(7 downto 0);
end record;

end package;