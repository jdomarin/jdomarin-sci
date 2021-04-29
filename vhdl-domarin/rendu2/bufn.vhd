-- Fichier : bufn.vhd
-- Auteur : J�r�my Domarin & Youssef Benfaida

-- SPECIFICATION D'UN TAMPON A N BITS

library ieee;	-- importe la biblioth�que "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les �l�ments
							-- du paquetage "std_logic_1164"
							-- de la biblioth�que "ieee",
							-- dont le type Std_Logic qui mod�lise qualitativement
							-- la valeur d'une borne �lectrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

entity bufn is
	generic( N : Integer := 4); -- N �gal � 4 par d�faut

	port(
		E : in Std_Logic; --commande de validation (enable)
		I : in Std_Logic_Vector(N-1 downto 0); --donn�e d'entr�e (input)
		O : buffer Std_Logic_Vector(N-1 downto 0) -- donn�e de sortie (output)
		);

end entity;

architecture BUFN_arch of BUFN is

begin

proc: process (E, I)
begin
	if (E='1') then 
		O <= I;
	else 
		O <= (others =>'Z'); -- 'Z' signifie d�connect�
	end if;
end process;

end architecture;

--DESIGN EQUATIONS 

-- Explications : .OE (Output Enable) signifie que la sortie O est disponible si et seulement si la commande de validation OE est active.
-- Dans ce cas on stocke l'entr�e i(k) � la sortie o(k), k=0..3 

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
