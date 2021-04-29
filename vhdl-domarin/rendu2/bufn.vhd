-- Fichier : bufn.vhd
-- Auteur : Jérémy Domarin & Youssef Benfaida

-- SPECIFICATION D'UN TAMPON A N BITS

library ieee;	-- importe la bibliothèque "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee",
							-- dont le type Std_Logic qui modélise qualitativement
							-- la valeur d'une borne électrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

entity bufn is
	generic( N : Integer := 4); -- N égal à 4 par défaut

	port(
		E : in Std_Logic; --commande de validation (enable)
		I : in Std_Logic_Vector(N-1 downto 0); --donnée d'entrée (input)
		O : buffer Std_Logic_Vector(N-1 downto 0) -- donnée de sortie (output)
		);

end entity;

architecture BUFN_arch of BUFN is

begin

proc: process (E, I)
begin
	if (E='1') then 
		O <= I;
	else 
		O <= (others =>'Z'); -- 'Z' signifie déconnecté
	end if;
end process;

end architecture;

--DESIGN EQUATIONS 

-- Explications : .OE (Output Enable) signifie que la sortie O est disponible si et seulement si la commande de validation OE est active.
-- Dans ce cas on stocke l'entrée i(k) à la sortie o(k), k=0..3 

--    o(0) =
--          i(0) 
--
--    o(0).OE =
--          e 
--
--    o(1) =
--          i(1) 
--
--    o(1).OE =
--          e 
--
--    o(2) =
--          i(2) 
--
--    o(2).OE =
--          e 
--
--    o(3) =
--          i(3) 
--
--    o(3).OE =
--          e 
