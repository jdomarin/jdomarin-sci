-- Fichier : alsun.vhd
-- Auteur : J�r�my Domarin & Benfaida Youssef

-- TP7, Question 1

-- UNITE DE CALCUL ARITHMETIQUE ET LOGIQUE A N BITS

library ieee;										-- importe la biblioth�que "ieee"

use ieee.std_logic_1164.all; 						--rend visible "tous" les �l�ments
													-- du paquetage "std_logic_1164"
													-- de la biblioth�que "ieee",
													-- dont le type Std_Logic qui mod�lise qualitativement
													-- la valeur d'une borne �lectrique {0, 1, Z, - ...} ;
													-- type Bit={0,1}, type Boolean = {FALSE, TRUE}.

-- ENTITY = SPECIFICATION DE L'INTERFACE (DECLARATION) DE L'OPERATEUR

entity alsun is
	generic( N : Integer := 4); 					-- N �gal � 4 par d�faut

	port(
		P : in std_logic_vector(4 downto 0); --op�ration
		I : in std_logic; -- entr�e de retenue
		ADR : in std_logic; -- bit faible de l'adresse
		A : in std_logic_vector(N-1 downto 0); -- op�rande A
		B : in std_logic_vector(N-1 downto 0); --op�rande B
		R : buffer std_logic_vector(N-1 downto 0); --r�sultat
		C : buffer std_logic; --retenue
		V : buffer std_logic --d�bordement arithm�tique
		);					

end entity;

-- ARCHITECTURE = SPECIFICATION DU COMPORTEMENT (DEFINITION) DE L'OPERATEUR

architecture ALSUN_arch of ALSUN is
--signaux
-- les retenues d'entr�e et de sortie
signal RC: Std_Logic_Vector(N-1 downto 0);
--attribute SYNTHESIS_OFF of RC : signal is TRUE;
signal RI: Std_Logic_Vector(N-1 downto 0);
--attribute SYNTHESIS_OFF of RI : signal is FALSE;

--Constantes
--2 op�randes
constant ALSU_ADD : std_logic_vector(4 downto 0) := "00110"; --add
constant ALSU_ADC : std_logic_vector(4 downto 0) := "00000"; --add carry
constant ALSU_SUB : std_logic_vector(4 downto 0) := "00111"; --substract
constant ALSU_AND : std_logic_vector(4 downto 0) := "00100"; --and
constant ALSU_OR : std_logic_vector(4 downto 0) := "00101"; --or
constant ALSU_XOR : std_logic_vector(4 downto 0) := "00001"; --xor
--1 op�rande
constant ALSU_NOT : std_logic_vector(4 downto 0) := "10100"; --not
constant ALSU_NEG : std_logic_vector(4 downto 0) := "10111"; --negate
constant ALSU_SRL : std_logic_vector(4 downto 0) := "10010"; --shift right logical
constant ALSU_SRA : std_logic_vector(4 downto 0) := "10011"; --shift right arithmetic
constant ALSU_RRC : std_logic_vector(4 downto 0) := "10001"; --rotate right through carry
constant ALSU_SWP : std_logic_vector(4 downto 0) := "11010"; --swap bytes
constant ALSU_EXT : std_logic_vector(4 downto 0) := "11101"; --extend byte
--load and store word, �quivalents � PASS B
constant ALSU_LDW : std_logic_vector(4 downto 0) := "01101"; --load word
constant ALSU_STW : std_logic_vector(4 downto 0) := "01100"; --store word


begin


-- calcul de RI(0) selon l'op�ration
RI(0)<=	I when P=ALSU_ADC else
		'0' when P=ALSU_ADD else
		'1' when P=ALSU_SUB else
		'1' when P=ALSU_NEG else
		'-'; --peu importe

-- calcul de RC selon l'op�ration
RC <=	(A and B) or (RI and B) or (RI and A) when P=ALSU_ADC else
		(A and B) or (RI and B) or (RI and A) when P=ALSU_ADD else --pareil pour ADD et ADC
		(A and (not B)) or (A and RI) or ((not B) and RI) when P=ALSU_SUB else
		(not B) and RI when P=ALSU_NEG;

		
-- propagation de la retenue (comme pour l'additionneur)
carry_gen : for j in 1 to N-1 generate
				RI(j) <= RC(j-1); -- propager la retenue de la sortie RC(j-1) vers l'entr�e RI(j) de la tranche suivante
			end generate;

-- Process pour calculer la valeur de P selon l'op�ration, r�sultat stock� dans une variable interm�diaire rv
Alsu_proc: process (A, B, ADR, R, C, V, RI)

Variable rv: std_logic_vector(N-1 downto 0);

begin

case P is --� terminer
-- valeurs de rv, v et c selon la valeur de P
	when ALSU_XOR =>
		rv := A xor B;
		v <= '0';
		c <= '0';
	when ALSU_AND =>
		rv := A and B;
		v <= '0';
		c <= '0';
	when ALSU_OR =>
		rv := A or B;
		v <= '0';
		c <= '0';
	when ALSU_NOT =>
		rv := not B;
		v <= '0';
		c <= '0';
	when ALSU_ADD =>
		rv := (A xor B) xor RI;
		v <= RC(N-1) xor RC(N-2);
		c <= RC(N-1);
	when ALSU_SUB =>
		c <= '0';
		v <= '0'; 
		for k in 0 to N-1 loop
			rv(k) := not(A(k) xor (not B(k)));
		end loop;
	when ALSU_NEG =>
		rv := (not B) xor RI;
		v <= RC(N-1) xor RC(N-2);
		c <= not(RC(N-1));
	when ALSU_SRL =>
		c <= B(0);
		v <= '0';
		for k in 0 to N-1 loop
			rv(k) := B(k+1);
		end loop;
	when ALSU_SRA =>
	 --simule l'op�ration (B>>1) + B(N-1)*2^(N-1)
	 	rv(N-1) := B(N-1);
		c <= B(0);
		v <= '0';
		for k in 0 to N-2 loop
			rv(k) := B(k+1);
		end loop;
	when ALSU_RRC =>
		--rotate right through carry flag
	 	rv(N-1) := I;
		c <= B(0);
		v <= '0';
		for k in 0 to N-2 loop
			rv(k) := B(k+1);
		end loop;
	when ALSU_SWP =>
		c <= '0';
		v <= '0';
		for k in 0 to N/2-1 loop
			rv(k) := b(k+N/2); --calcule le demi-mot droit de r
 		    rv(k+N/2) := b(k); --calcule le demi-mot gauche de r
		end loop;
		--extend bytes - to do
	--when ALSU_EXT =>
		
	--op�rations de transfert
	when ALSU_LDW =>
		c <= '0';
		v <= '0';
		if ADR='1' then 
			for k in 0 to N/2-1 loop
				rv(k) := b(k+N/2); --calcule le demi-mot droit de r
 		    	rv(k+N/2) := b(k); --calcule le demi-mot gauche de r
			end loop;
		else
			for k in 0 to N/2-1 loop
				rv(k) := b(k); --calcule le demi-mot droit de r
 		    	rv(k+N/2) := b(k+N/2); --calcule le demi-mot gauche de r
			end loop;
		end if;
	when others => 
		rv := (others => '-'); -- rv = ---...-- ce qui �vite la m�morisation et simplifie la logique
end case;
R <= rv;

end process;

end architecture;


