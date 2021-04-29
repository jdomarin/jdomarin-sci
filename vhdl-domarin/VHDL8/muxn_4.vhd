
-- Fichier : muxn_4.vhd
-- Auteur : Jérémy Domarin

-- TP1, question 5

-- MULTIPLEXEUR A 4 ENTREES DE N BITS

library ieee;	-- importe la bibliothèque "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee",
							-- dont le type Std_Logic qui modélise qualitativement
							-- la valeur d'une borne électrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity muxn_4 is
	generic ( N : Integer :=4);

	port (					-- liste nominative du port
		s : in Std_Logic_Vector(1 downto 0);
		x0 : in Std_Logic_Vector(N-1 downto 0);
		x1 : in Std_Logic_Vector(N-1 downto 0);
		x2 : in Std_Logic_Vector(N-1 downto 0);
		x3 : in Std_Logic_Vector(N-1 downto 0);
		y : buffer Std_Logic_Vector(N-1 downto 0)
		);
end entity;


-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATEUR

architecture MUXN_4_arch of MUXN_4 is --lie l'architecture à l'entité MUX4_2

begin

with s select
	Y <= x0 when "00", -- Y = X0 quand s=00
		x1 when "01", -- Y = X1 quand s=01
		x2 when "10", -- Y = X2 quand s=02
		x3 when others; --Y = X3 quand s=03

end architecture;