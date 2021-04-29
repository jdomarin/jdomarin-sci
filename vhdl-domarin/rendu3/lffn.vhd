-- Fichier : lffn.vhd
-- Auteur : Jérémy Domarin & Benfaida Youssef

-- TP4, Question 1

-- VERROU N BITS

library ieee;										-- importe la bibliothèque "ieee"

use ieee.std_logic_1164.all; 						--rend visible "tous" les éléments
													-- du paquetage "std_logic_1164"
													-- de la bibliothèque "ieee",
													-- dont le type Std_Logic qui modélise qualitativement
													-- la valeur d'une borne électrique {0, 1, Z, - ...} ;
													-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity lffn is
	generic( N : Integer := 4); 					-- N égal à 4 par défaut

	port(
		G : in Std_Logic; 							--commande de passage
		D : in Std_Logic_Vector(N-1 downto 0); 		--donnée d'entrée
		Q : buffer Std_Logic_Vector(N-1 downto 0) 	-- donnée de sortie				
		);					

end entity;
-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATEUR

architecture LFFN_arch of LFFN is

begin

proc: process (G, D)

begin
	if (G='1') then 
		Q <= D;
	end if;
end process;

end architecture;