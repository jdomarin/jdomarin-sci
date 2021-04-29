
-- Fichier : addn.vhd
-- Auteur : Jérémy Domarin & Benfaida Youssef

-- TP2, Question 1

-- ADDITIONNEUR N BITS

library ieee;	-- importe la bibliothèque "ieee"

use ieee.std_logic_1164.all; --rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee",
							-- dont le type Std_Logic qui modélise qualitativement
							-- la valeur d'une borne électrique {0, 1, Z, - ...} ;
							-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.



-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity addn is
	generic( N : Integer := 4); -- N égal à 4 par défaut

-- DEFINITION DES CONSTANTES

	port(
		I : in Std_Logic; -- entrée de retenue
		A : in Std_Logic_Vector(N-1 downto 0); -- opérande A
		B : in Std_Logic_Vector(N-1 downto 0); --opérande B
		S : buffer Std_Logic_Vector(N-1 downto 0) ; --sortie rebouclable
		C : buffer Std_Logic);					-- sortie de retenue

end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATEUR

architecture ADDN_arch of ADDN is

signal RC: Std_Logic_Vector(N-1 downto 0);
signal RI: Std_Logic_Vector(N-1 downto 0);
--attribute SYNTHESIS_OFF of RI : signal is TRUE;
constant TPD_PASS : Time := 10 ns;
constant TPD_IO : Time := 20 ns;

begin

RI(0) <= I after TPD_IO; -- I est la retenue d'entrée de l'additionneur 0
S <= A xor B xor RI after TPD_IO + 2*TPD_PASS;
RC <= (A and (B or RI)) or (B and RI) after TPD_IO + 3 = TPD_PASS;
carry_gen : for j in 1 to N-1 generate
				RI(j) <= RC(j-1); -- propager la retenue de la sortie RC(j-1) vers l'entrée RI(j) de la tranche suivante
			end generate;
C <= RC(N-1); -- C est la retenue de sortie de l'additionneur N-1

end architecture;


-- Question 2
-- Directive SYNTHESIS_OFF (RC : true, RI : false)
--	  c =
--          b(7) * rc_6.CMB 
--        + a(7) * rc_6.CMB 
--        + a(7) * b(7) 
--
--    rc_0 =
--          b(0) * i 
--        + a(0) * i 
--        + a(0) * b(0) 
--
--    rc_1 =
--          b(1) * rc_0.CMB 
--        + a(1) * rc_0.CMB 
--        + a(1) * b(1) 
--
--    rc_2 =
--          b(2) * rc_1.CMB 
--        + a(2) * rc_1.CMB 
--        + a(2) * b(2) 
--
--    rc_3 =
--          b(3) * rc_2.CMB 
--        + a(3) * rc_2.CMB 
--        + a(3) * b(3) 
--
--    rc_4 =
--          b(4) * rc_3.CMB 
--        + a(4) * rc_3.CMB 
--        + a(4) * b(4) 
--
--    rc_5 =
--          b(5) * rc_4.CMB 
--        + a(5) * rc_4.CMB 
--        + a(5) * b(5) 
--
--    rc_6 =
--          b(6) * rc_5.CMB 
--        + a(6) * rc_5.CMB 
--        + a(6) * b(6) 
--
--    s(0) =
--          /a(0) * b(0) 
--        + a(0) * /b(0) 
--
--    s(1) =
--          a(1) * b(1) * rc_0.CMB 
--        + /a(1) * /b(1) * rc_0.CMB 
--        + /a(1) * b(1) * /rc_0.CMB 
--        + a(1) * /b(1) * /rc_0.CMB 
--
--    s(2) =
--          a(2) * b(2) * rc_1.CMB 
--        + /a(2) * /b(2) * rc_1.CMB 
--        + /a(2) * b(2) * /rc_1.CMB 
--        + a(2) * /b(2) * /rc_1.CMB 
--
--    s(3) =
--          a(3) * b(3) * rc_2.CMB 
--        + /a(3) * /b(3) * rc_2.CMB 
--        + /a(3) * b(3) * /rc_2.CMB 
--        + a(3) * /b(3) * /rc_2.CMB 
--
--    s(4) =
--          a(4) * b(4) * rc_3.CMB 
--        + /a(4) * /b(4) * rc_3.CMB 
--        + /a(4) * b(4) * /rc_3.CMB 
--        + a(4) * /b(4) * /rc_3.CMB 
--
--    s(5) =
--          a(5) * b(5) * rc_4.CMB 
--        + /a(5) * /b(5) * rc_4.CMB 
--        + /a(5) * b(5) * /rc_4.CMB 
--        + a(5) * /b(5) * /rc_4.CMB 
--
--    s(6) =
--          a(6) * b(6) * rc_5.CMB 
--        + /a(6) * /b(6) * rc_5.CMB 
--        + /a(6) * b(6) * /rc_5.CMB 
--        + a(6) * /b(6) * /rc_5.CMB 
--
--    s(7) =
--          a(7) * b(7) * rc_6.CMB 
--        + /a(7) * /b(7) * rc_6.CMB 
--        + /a(7) * b(7) * /rc_6.CMB 
--        + a(7) * /b(7) * /rc_6.CMB 
-- Directive SYNTHESIS_OFF (RC : true, RI : true)
 -- c =
--          b(7) * ri_7.CMB 
--        + a(7) * ri_7.CMB 
--        + a(7) * b(7) 
--
--    ri_1 =
--          b(0) * i 
--        + a(0) * i 
--        + a(0) * b(0) 
--
--    ri_2 =
--          b(1) * ri_1.CMB 
--        + a(1) * ri_1.CMB 
--        + a(1) * b(1) 
--
--    ri_3 =
--          b(2) * ri_2.CMB 
--        + a(2) * ri_2.CMB 
--        + a(2) * b(2) 
--
--    ri_4 =
--          b(3) * ri_3.CMB 
--        + a(3) * ri_3.CMB 
--        + a(3) * b(3) 
--
--    ri_5 =
--          b(4) * ri_4.CMB 
--        + a(4) * ri_4.CMB 
--        + a(4) * b(4) 
--
--    ri_6 =
--          b(5) * ri_5.CMB 
--        + a(5) * ri_5.CMB 
--        + a(5) * b(5) 
--
--    ri_7 =
--          b(6) * ri_6.CMB 
--        + a(6) * ri_6.CMB 
--        + a(6) * b(6) 
--
--    s(0) =
--          /a(0) * b(0) 
--        + a(0) * /b(0) 
--
--    s(1) =
--          a(1) * b(1) * ri_1.CMB 
--        + /a(1) * /b(1) * ri_1.CMB 
--        + /a(1) * b(1) * /ri_1.CMB 
--        + a(1) * /b(1) * /ri_1.CMB 
--
--    s(2) =
--          a(2) * b(2) * ri_2.CMB 
--        + /a(2) * /b(2) * ri_2.CMB 
--        + /a(2) * b(2) * /ri_2.CMB 
--        + a(2) * /b(2) * /ri_2.CMB 
--
--    s(3) =
--          a(3) * b(3) * ri_3.CMB 
--        + /a(3) * /b(3) * ri_3.CMB 
--        + /a(3) * b(3) * /ri_3.CMB 
--        + a(3) * /b(3) * /ri_3.CMB 
--
--    s(4) =
--          a(4) * b(4) * ri_4.CMB 
--        + /a(4) * /b(4) * ri_4.CMB 
--        + /a(4) * b(4) * /ri_4.CMB 
--        + a(4) * /b(4) * /ri_4.CMB 
--
--    s(5) =
--          a(5) * b(5) * ri_5.CMB 
--        + /a(5) * /b(5) * ri_5.CMB 
--        + /a(5) * b(5) * /ri_5.CMB 
--        + a(5) * /b(5) * /ri_5.CMB 
--
--    s(6) =
--          a(6) * b(6) * ri_6.CMB 
--        + /a(6) * /b(6) * ri_6.CMB 
--        + /a(6) * b(6) * /ri_6.CMB 
--        + a(6) * /b(6) * /ri_6.CMB 
--
--    s(7) =
--          a(7) * b(7) * ri_7.CMB 
--        + /a(7) * /b(7) * ri_7.CMB 
--        + /a(7) * b(7) * /ri_7.CMB 
--        + a(7) * /b(7) * /ri_7.CMB 
-- Différence : équations de RI quand SYNTHESIS_OFF de RI est à TRUE; équations de RC sinon.

-- Question 3
-- Nombre de passes : N+1 (le nombre de bits)
-- Délai de propagation : environ 10*(N+1) ns

-- Question 4
-- Nombre de macro-cellules : 2*N + macrocell
