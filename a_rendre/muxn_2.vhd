
-- Fichier : mux4_2.vhd
-- Auteur : J�r�my Domarin

-- TP1, Question 4

-- MULTIPLEXEUR A 2 ENTREES DE N BITS

library ieee;	-- importe la biblioth�que "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les �l�ments
							-- du paquetage "std_logic_1164"
							-- de la biblioth�que "ieee",
							-- dont le type Std_Logic qui mod�lise qualitativement
							-- la valeur d'une borne �lectrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity muxn_2 is
	generic ( N : Integer := 4);

	port (					-- liste nominative du port
		s : in Std_Logic;
		x0 : in Std_Logic_Vector(N-1 downto 0);
		x1 : in Std_Logic_Vector(N-1 downto 0);
		y : buffer Std_Logic_Vector(N-1 downto 0)
		);
end entity;


-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATEUR

architecture MUXN_2_arch of MUXN_2 is --lie l'architecture � l'entit� MUX4_2

begin

y <= x0 when s = '0' else
	x1;

end architecture;