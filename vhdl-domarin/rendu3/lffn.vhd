-- Fichier : lffn.vhd
-- Auteur : J�r�my Domarin & Benfaida Youssef

-- TP4, Question 1

-- VERROU N BITS

library ieee;										-- importe la biblioth�que "ieee"

use ieee.std_logic_1164.all; 						--rend visible "tous" les �l�ments
													-- du paquetage "std_logic_1164"
													-- de la biblioth�que "ieee",
													-- dont le type Std_Logic qui mod�lise qualitativement
													-- la valeur d'une borne �lectrique {0, 1, Z, - ...} ;
													-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity lffn is
	generic( N : Integer := 4); 					-- N �gal � 4 par d�faut

	port(
		G : in Std_Logic; 							--commande de passage
		D : in Std_Logic_Vector(N-1 downto 0); 		--donn�e d'entr�e
		Q : buffer Std_Logic_Vector(N-1 downto 0) 	-- donn�e de sortie				
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