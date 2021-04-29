-- Fichier : dffn.vhd
-- Auteur : Jérémy Domarin & Youssef Benfaida

-- SPECIFICATION D'UNE BASCULE D A N BITS

library ieee;	-- importe la bibliothèque "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee",
							-- dont le type Std_Logic qui modélise qualitativement
							-- la valeur d'une borne électrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

entity dffn is
	generic( N : Integer := 4); -- N égal à 4 par défaut

	port(
		clock : in Std_logic;
		D : in Std_Logic_Vector(N-1 downto 0); --donnée d'entrée
		Q : buffer Std_Logic_Vector(N-1 downto 0) -- donnée de sortie
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
-- q(i).D = d(i) : synchronisation des données en fonction du front montant de l'horloge
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
