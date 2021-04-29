-- Fichier : passn.vhd
-- Auteur : Jérémy Domarin & Youssef Benfaida

-- SPECIFICATION D'UN PASSEUR A N BITS

library ieee;	-- importe la bibliothèque "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee",
							-- dont le type Std_Logic qui modélise qualitativement
							-- la valeur d'une borne électrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

entity passn is
	generic( N : Integer := 4); -- N égal à 4 par défaut

	port(
		G : in Std_Logic; --commande de passage
		I : in Std_Logic_Vector(N-1 downto 0); --donnée d'entrée
		O : buffer Std_Logic_Vector(N-1 downto 0) -- donnée de sortie
		);

end entity;

architecture PASSN_arch of PASSN is

begin

proc: process (G, I)
begin
	if (G='1') then 
		O <= I;
	else 
		O <= (others => '0');
	end if;
end process;

end architecture;

--DESIGN EQUATIONS
--
-- la sortie du passeur est le produit logique (AND) de l'entrée G et de l'entrée à N bits I
-- les équations sont données pour chaque bit de O
--
--    o(0) =
--          g * i(0) 
--
--    o(1) =
--          g * i(1) 
--
--    o(2) =
--          g * i(2) 
--
--    o(3) =
--          g * i(3) 
