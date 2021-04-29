--file : baspck.vhd		nm du fichier contenant le paquetage BASIC_PACK
--Auteur : Jérémy Domarin & Youssef Benfaida

library ieee;	--import de la bibliothèque ieee

use ieee.std_logic_1164.all;	--rend visible tous les éléments du paquetage std_logic_1164 de ieee

--import éventuel des autres bibliothèques

package basic_pack is 	--nom du package

--déclaration éventuelle des types de package


--déclaration éventuelle des constantes de package

--déclaration des composants

--ci après déclaration du composant REGN :

component REGN
	generic( N : Integer := 4); -- N égal à 4 par défaut

	port(
		L : in Std_Logic; --commande de passage
		R : in Std_Logic; --commande d effacement prioritaire et synchrone R
		clock : in Std_Logic; --horloge
		D : in Std_Logic_Vector(N-1 downto 0); --donnée d'entrée
		Q : buffer Std_Logic_Vector(N-1 downto 0) -- donnée de sortie
		);

end component;

--ci après déclaration du composant MUXN_4 :

component muxn_4
	generic ( N : Integer :=4);

	port (					-- liste nominative du port
		s : in Std_Logic_Vector(1 downto 0);
		x0 : in Std_Logic_Vector(N-1 downto 0);
		x1 : in Std_Logic_Vector(N-1 downto 0);
		x2 : in Std_Logic_Vector(N-1 downto 0);
		x3 : in Std_Logic_Vector(N-1 downto 0);
		y : buffer Std_Logic_Vector(N-1 downto 0)
		);
end component;

end package;

