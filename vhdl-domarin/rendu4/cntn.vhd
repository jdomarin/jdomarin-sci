-- Fichier : cntn.vhd
-- Auteur : J�r�my Domarin & Benfaida Youssef

-- TP5, Question 1

-- COMPTEUR BINAIRE SYNCHRONE DE N BITS RECHARGEABLE ET RE-UTILISABLE A UNE VALEUR

-- R�ponses aux questions
-- 2.2.a : calculer la fr�quence de comptage :
-- pour N=4
-- synth�se par DFF, avec SYNTHESIS_OFF sur RC : fmax = 17,7 Mhz
-- synth�se par DFF, sans SYNTHESIS_OFF sur RC : fmax = 43 Mhz

-- synth�se par TFF, avec SYNTHESIS_OFF sur RC : fmax = 18 Mhz 

-- synth�se par TFF, avec SYNTHESIS_OFF sur RC : fmax = 43 Mhz

-- pour N=16
-- synth�se par DFF, avec SYNTHESIS_OFF sur RC : fmax = 5,3 MHz

-- synth�se par DFF, sans SYNTHESIS_OFF sur RC : fmax = 43 MHz

-- synth�se par TFF, avec SYNTHESIS_OFF sur RC : fmax = 5,3 MHz

-- synth�se par TFF, avec SYNTHESIS_OFF sur RC : fmax = 43 MHz

-- 2.2.b
-- Meilleur choix : N = 16 sans attribut SYNTHESIS_OFF avec synth�se optimale

-- 2.2.c
-- RC0 = Q0 and T
-- RC1 = Q1 and T or Q0 and T
-- RC2 = Q2 and T or Q1 and T or Q0 and T
-- RC3 = Q3 and T or Q2 and T or Q1 and T or and T

library ieee;										-- importe la biblioth�que "ieee"

use ieee.std_logic_1164.all; 						--rend visible "tous" les �l�ments
													-- du paquetage "std_logic_1164"
													-- de la biblioth�que "ieee",
													-- dont le type Std_Logic qui mod�lise qualitativement
													-- la valeur d'une borne �lectrique {0, 1, Z, - ...} ;
													-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity cntn is
	generic( N : Integer := 4); 					-- N �gal � 4 par d�faut

	port(
		clock : in Std_Logic; 						--horloge de synchronisation
		R : in Std_Logic; 							--commande de r�-initialisation synchrone(Reset)
		L : in Std_Logic; 							--commande de chargement(Load)
		T : in Std_Logic;							--commande incr�mentation(Toggle)
		V : in Std_Logic_Vector(N-1 downto 0);		--donn�e de valeur initiale(init Value)						
		D : in Std_Logic_Vector(N-1 downto 0); 		--donn�e d'entr�e � charger(Data)
		Q : buffer Std_Logic_Vector(N-1 downto 0); 	--donn�e de sortie	de valeur de comptage
		C : buffer Std_Logic						--indicateur de sortie qui contient la retenue sortante � gauche(Carry)
		);					

end entity;
-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATEUR

architecture CNTN_arch of CNTN is
signal RC : std_logic_vector(N-1 downto 0);
signal RI : std_logic_vector(N-1 downto 0);
signal QQ_n : std_logic_vector(N-1 downto 0);
--attribute SYNTHESIS_OFF of RC : signal is TRUE;

begin			-- calcul des signaux
RI(0) <= C;
QQ_n <= Q xor RI;
RC <= Q and RI;
carry_gen : for i in 1 to N-1 generate
				RI(i) <= RC(i-1);
				end generate;
C <= RC(N-1);

proc: process (clock)

begin
	if (clock'event and clock='1') then
    	if(R='1') then
			Q <= V;									--Initialisation synchrone de Q � la valeur V				
		elsif (L='1') then
 	    	Q <= D;									--Chargement synchrone de Q avec D
			elsif (T='1') then
 		    	Q <= QQ_n;							--Stocke le signal interm�qiaire QQ_n dans Q (QQ_n calcul� hors du process)
		end if;
	end if;
end process;

end architecture;