-- Fichier : regn.vhd
-- Auteur : J�r�my Domarin & Youssef Benfaida

-- SPECIFICATION D'UN REGISTRE A N BITS

library ieee;	-- importe la biblioth�que "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les �l�ments
							-- du paquetage "std_logic_1164"
							-- de la biblioth�que "ieee",
							-- dont le type Std_Logic qui mod�lise qualitativement
							-- la valeur d'une borne �lectrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

entity regn is
	generic( N : Integer := 4); -- N �gal � 4 par d�faut

	port(
		L : in Std_Logic; --commande de passage
		R : in Std_Logic; --commande d effacement prioritaire et synchrone R
		clock : in Std_Logic; --horloge
		D : in Std_Logic_Vector(N-1 downto 0); --donn�e d'entr�e
		Q : buffer Std_Logic_Vector(N-1 downto 0) -- donn�e de sortie
		);

end entity;

architecture REGN_arch of REGN is

begin

proc: process (clock)
begin
	if (clock'event and clock='1') then 
		if(R='1') then
			Q <= (others => '0');
		elsif (L='1') then 
			Q <= D;
		end if;
	end if;	
end process;

end architecture;