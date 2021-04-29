-- Fichier : dffn.vhd
-- Auteur : J�r�my Domarin & Youssef Benfaida

-- SPECIFICATION D'UNE BASCULE D A N BITS

library ieee;	-- importe la biblioth�que "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les �l�ments
							-- du paquetage "std_logic_1164"
							-- de la biblioth�que "ieee",
							-- dont le type Std_Logic qui mod�lise qualitativement
							-- la valeur d'une borne �lectrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

entity dffn is
	generic( N : Integer := 4); -- N �gal � 4 par d�faut

	port(
		clock : in Std_logic;
		D : in Std_Logic_Vector(N-1 downto 0); --donn�e d'entr�e
		Q : buffer Std_Logic_Vector(N-1 downto 0) -- donn�e de sortie
		);

end entity;

architecture DFFN_arch of DFFN is

begin

proc: process (clock)
begin
	if (clock'event and clock = '1') then 
			Q <= D;
 	end if;
end process;

end architecture;

--DESIGN EQUATIONS     
--
-- q(i).C = clock : synchronisation de l'horloge
-- q(i).D = d(i) : synchronisation des donn�es en fonction du front montant de l'horloge
--
--    q(0).D =
--          d(0) 
--
--    q(0).C =
--          clock 
--
--    q(1).D =
--          d(1) 
--
--    q(1).C =
--          clock 
--
--    q(2).D =
--          d(2) 
--
--    q(2).C =
--          clock 
--
--    q(3).D =
--          d(3) 
--
--    q(3).C =
--          clock 
