-- Fichier : bc.vhd
-- Auteur : J�r�my Domarin & Benfaida Youssef

-- TP6, Question 1

-- CONTROLEUR DE BRANCHEMENT

library ieee;										-- importe la biblioth�que "ieee"

use ieee.std_logic_1164.all; 						--rend visible "tous" les �l�ments
													-- du paquetage "std_logic_1164"
													-- de la biblioth�que "ieee",
													-- dont le type Std_Logic qui mod�lise qualitativement
													-- la valeur d'une borne �lectrique {0, 1, Z, - ...} ;
													-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity branch_controller is

	port(
		NF : in Std_Logic; 							--Bit de signe du dernier r�sultat(Negative Flag)
		CF : in Std_Logic; 							--Retenue du dernier r�sultat(Carry Flag)
		VF : in Std_Logic; 							--D�bordement arithm�tique(Carry Flag)
		ZF : in Std_Logic;							--Dernier r�sultat nul(Zero Flag)
		CC : in Std_Logic_Vector(3 downto 0);		--Code de la condition(Condition Code)					
		BR : buffer Std_Logic						--Branchement(Branch)
		);					

end entity;
-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATEUR

architecture BC_arch of branch_controller is

--Constantes

constant BC_NV : Std_Logic_Vector(3 downto 0) := "0000";	--Never
constant BC_AL : Std_Logic_Vector(3 downto 0) := "0001";	--Always
constant BC_EQ : Std_Logic_Vector(3 downto 0) := "0010";	--if Equal
constant BC_NE : Std_Logic_Vector(3 downto 0) := "0011";	--if Not Equal
constant BC_GE : Std_Logic_Vector(3 downto 0) := "0100";	--if Greater or Equal
constant BC_LE : Std_Logic_Vector(3 downto 0) := "0101";	--if Less or Equal
constant BC_GT : Std_Logic_Vector(3 downto 0) := "0110";	--if Greater
constant BC_LW : Std_Logic_Vector(3 downto 0) := "0111";	--if Lower
constant BC_AE : Std_Logic_Vector(3 downto 0) := "1000";	--if Above or Equal(Carry Cleared)
constant BC_BE : Std_Logic_Vector(3 downto 0) := "1001";	--if Below or Equal
constant BC_AB : Std_Logic_Vector(3 downto 0) := "1010";	--if Above
constant BC_BL : Std_Logic_Vector(3 downto 0) := "1011";	--if Below(Carry Set)
constant BC_VS : Std_Logic_Vector(3 downto 0) := "1100";	--if oVerflow flag is Set
constant BC_VC : Std_Logic_Vector(3 downto 0) := "1101";	--if oVerflow flag is Clear
constant BC_NS : Std_Logic_Vector(3 downto 0) := "1110";	--if Negative flag is Set
constant BC_NC : Std_Logic_Vector(3 downto 0) := "1111";	--if Negative flag is Clear

begin

with CC select
	BR <= '0'when BC_NV,
		  '1' when BC_AL,
		  ZF when BC_EQ,
		  not ZF when BC_NE,
		  not (NF xor VF) when BC_GE,
		  (NF xor VF) or ZF when BC_LE,
		  (not (NF xor VF)) and (not ZF) when BC_GT,
		  NF xor VF when BC_LW,
		  not CF when BC_AE,
		  CF or ZF when BC_BE,
		  (not CF) and (not ZF) when BC_AB,
		  CF when BC_BL,
		  VF when BC_VS,
		  not VF when BC_VC,
		  NF when BC_NS,
		  not NF when BC_NC,
		  '0' when others;

end architecture;