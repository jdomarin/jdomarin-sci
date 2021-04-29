-- Fichier : regn.vhd
-- Auteur : Jérémy Domarin & Youssef Benfaida

-- SPECIFICATION D'UN REGISTRE A N BITS

library ieee;	-- importe la bibliothèque "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee",
							-- dont le type Std_Logic qui modélise qualitativement
							-- la valeur d'une borne électrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

entity regn is
	generic( N : Integer := 4); -- N égal à 4 par défaut

	port(
		clock : in Std_Logic; --horloge
		R : in Std_Logic; --commande d effacement prioritaire et synchrone R
		L : in Std_Logic; --commande de passage
		D : in Std_Logic_Vector(N-1 downto 0); --donnée d'entrée
		Q : buffer Std_Logic_Vector(N-1 downto 0) -- donnée de sortie
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