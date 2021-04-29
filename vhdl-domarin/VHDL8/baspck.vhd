--file : baspck.vhd		nm du fichier contenant le paquetage BASIC_PACK
--Auteur : J�r�my Domarin & Youssef Benfaida

library ieee;	--import de la biblioth�que ieee

use ieee.std_logic_1164.all;	--rend visible tous les �l�ments du paquetage std_logic_1164 de ieee

--import �ventuel des autres biblioth�ques

package basic_pack is 	--nom du package

--d�claration �ventuelle des types de package


--d�claration �ventuelle des constantes de package

--d�claration des composants

--ci apr�s d�claration du composant REGN :

component REGN
	generic( N : Integer := 4); -- N �gal � 4 par d�faut

	port(
		L : in Std_Logic; --commande de passage
		R : in Std_Logic; --commande d effacement prioritaire et synchrone R
		clock : in Std_Logic; --horloge
		D : in Std_Logic_Vector(N-1 downto 0); --donn�e d'entr�e
		Q : buffer Std_Logic_Vector(N-1 downto 0) -- donn�e de sortie
		);

end component;

--ci apr�s d�claration du composant MUXN_4 :

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

