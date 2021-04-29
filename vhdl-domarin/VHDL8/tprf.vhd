-- Fichier : tprf.vhd
-- Auteur : Benfaida Youssef & Jérémy Domarin  

-- TP8

-- BLOC DE REGISTRES (TRIPLE_PORT_REG_FILE)

library ieee;										-- importe la bibliothèque "ieee"
use work.basic_pack.all;							--utilise tous les éléments du paquetage basic_pack de la bibliothèque work
use ieee.std_logic_1164.all; 						--rend visible "tous" les éléments
													-- du paquetage "std_logic_1164"
													-- de la bibliothèque "ieee",
													-- dont le type Std_Logic qui modélise qualitativement
													-- la valeur d'une borne électrique {0, 1, Z, - ...} ;
													-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity tprf is
	generic( alpha : Integer := 2; M : Integer := 4; N : Integer := 4); 						

	port(
		clock : in Std_Logic; 								--horloge (clock)
		R : in Std_Logic; 									--commande de remise à zero synchrone(Reset)
		L : in Std_Logic; 									--commande de chargement(Load)
		INS : in Std_Logic_Vector(alpha-1 downto 0);		--Sélecteur d'entrée I (Input Selector)					
		OAS : in Std_Logic_Vector(alpha-1 downto 0); 		--Sélecteur de sortie A (Output A Selector)
		OBS : in Std_Logic_Vector(alpha-1 downto 0);		--Sélecteur de sortie B (Output B Selector)				
		I : in Std_Logic_Vector(N-1 downto 0); 				--Entrée de donnée(Input)
		OA : buffer Std_Logic_Vector(N-1 downto 0); 		--Sortie A de donnée (Output A)
		OB : buffer Std_Logic_Vector(N-1 downto 0)		--Sortie B de donnée (Output B)
		);					

end entity;
-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATEUR

architecture tprf_arch of tprf is

signal R0, R1, R2, R3 : Std_Logic_Vector(N-1 downto 0);		-- Borne de sortie des registres
signal L0, L1, L2, L3 : Std_Logic;							-- Signaux internes de commande de chargement des registres  


begin

-- Instanciations des registres et des multiplexeurs

regn_0 : REGN									--Instancie le composant REGN pour créer l'opérateur regn_0
	generic map (N => N)						-- Largeur N des données de regn_0 = Largeur N des données du bloc de registres
	port map (
		L => L0,
		R => R,
		clock => clock,
		D => I,
		Q => R0);

regn_1: REGN									--Instancie le composant REGN pour créer l'opérateur regn_0
	generic map (N => N)						-- Largeur N des données de regn_0 = Largeur N des données du bloc de registres
	port map (
		L => L1,
		R => R,
		clock => clock,
		D => I,
		Q => R1);

regn_2: REGN									--Instancie le composant REGN pour créer l'opérateur regn_0
	generic map (N => N)						-- Largeur N des données de regn_0 = Largeur N des données du bloc de registres
	port map (
		L => L2,
		R => R,
		clock => clock,
		D => I,
		Q => R2);

regn_3: REGN									--Instancie le composant REGN pour créer l'opérateur regn_0
	generic map (N => N)						-- Largeur N des données de regn_0 = Largeur N des données du bloc de registres
	port map (
		L => L3,
		R => R,
		clock => clock,
		D => I,
		Q => R3);

muxn_4_a : MUXN_4
	generic map (N => N)						
	port map (
		s => OAS,
		x0 => R0,
		x1 => R1,
		x2 => R2,
		x3 => R3,
		y => OA);

muxn_4_b : MUXN_4
	generic map (N => N)						
	port map (
		s => OBS,
		x0 => R0,
		x1 => R1,
		x2 => R2,
		x3 => R3,
		y => OB);
	
L0 <= L when INS = "00" else '0';
L1 <= L when INS = "01" else '0';
L2 <= L when INS = "10" else '0';
L3 <= L when INS = "11" else '0';
end architecture;