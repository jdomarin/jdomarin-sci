-- Fichier : passn.vhd
-- Auteur : J�r�my Domarin & Youssef Benfaida

-- SPECIFICATION D'UN PASSEUR A N BITS

library ieee;	-- importe la biblioth�que "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les �l�ments
							-- du paquetage "std_logic_1164"
							-- de la biblioth�que "ieee",
							-- dont le type Std_Logic qui mod�lise qualitativement
							-- la valeur d'une borne �lectrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

entity passn is
	generic( N : Integer := 4); -- N �gal � 4 par d�faut

	port(
		G : in Std_Logic; --commande de passage
		I : in Std_Logic_Vector(N-1 downto 0); --donn�e d'entr�e
		O : buffer Std_Logic_Vector(N-1 downto 0) -- donn�e de sortie
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
-- la sortie du passeur est le produit logique (AND) de l'entr�e G et de l'entr�e � N bits I
-- les �quations sont donn�es pour chaque bit de O
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
