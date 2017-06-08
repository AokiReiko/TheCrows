library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity decode is --译码
	port(
		key: in std_logic_vector(3 downto 0);
		display: out std_logic_vector(6 downto 0)
	);
end decode;

architecture arch of decode is
begin
	process(key)
	begin
		case key is 
			when"0000"=>display<="1111110";
			when"0001"=>display<="1100000";
			when"0010"=>display<="1011101";
			when"0011"=>display<="1111001";
			when"0100"=>display<="1100011";
			when"0101"=>display<="0111011";
			when"0110"=>display<="0110111";
			when"0111"=>display<="1101000";
			when"1000"=>display<="1111111";
			when"1001"=>display<="1110011";
			when"1010"=>display<="1110111";
			when"1011"=>display<="0011111";
			when"1100"=>display<="1001110";
			when"1101"=>display<="0111101";
			when"1110"=>display<="1001111";
			when"1111"=>display<="1000111";
			when others=>display<="0000000";
		end case;
	end process;
end;