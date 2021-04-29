library ieee;
use ieee.std_logic_1164.all;

entity LFFN is
generic (N : Integer := 4);
	port(
		G:	in	Std_Logic;
		D:	in	Std_Logic_Vector(0 to N-1);
		Q:	buffer	Std_Logic_Vector(0 to N-1)
		);
end entity;

architecture LFFN_arch of LFFN is

begin

lff_proc: process (G, D)
	begin
		if(G = '1') then
			Q <= D ;
		end if ;
end process ;
end architecture;