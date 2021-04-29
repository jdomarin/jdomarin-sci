-- VHDL - (C) Alexandre Parodi - 2006
-- fichier micpck.vhd

library ieee;                -- importe la biblioth�que IEEE			
use ieee.std_logic_1164.all; -- montre tout le paquetage STD_LOGIC_1164 de ieee
use work.basic_pack.all;     -- montre tout le paquetage basic_pack de work

------------------------------
-- DEFINITION du PAQUETAGE MIC_PACK
------------------------------

-- Ce paquetage contient la d�finition de:

--    * type Micro Instruction Code;

--    * valeurs des champs de Micro Instruction Code (plus tard).


package MIC_PACK is

------------------------------
-- MIC type
------------------------------

Constant ALPHA: Integer := 2; -- largeur des s�lecteurs du bloc de regsitres
                              -- Peut �tre choisie dans {2, 3, 4}

Subtype Selector_Type is Std_Logic_Vector(ALPHA-1 downto 0); -- Type des s�lecteurs de registre
                                                             -- Ce type est un mot de ALPHA bits.

type Mic_Type is record
            alsu_op   : Pentad;         -- code op�ration de l'ALSU
            alsu_ais  : Pair;           -- s�lection de l'entr�e A de l'ALSU
            alsu_bis  : Pair;           -- s�lection de l'entr�e B de l'ALSU
            alsu_uvc  : Pair;           -- code de micro valeur
            rf_oas    : Selector_Type;  -- registre en sortie OA du bloc de registres
            rf_obs    : Selector_Type;  -- registre en sortie OB du bloc de registres
            rf_ins    : Selector_Type;  -- registre � charger dans le bloc de registres
            rf_l      : Wire;           -- commande de chargement du bloc de registres
            abus_s    : Wire;           -- s�lection de l'adresse
            cbus_typ  : Wire;           -- type de donn�e sur bus de donn�es
            cbus_wrt  : Wire;           -- sens des donn�es sur bus de donn�es
            cbus_str  : Wire;           -- utilisation du bus de donn�es
            sr_l      : Wire;           -- commande de chargement du registre d'�tat SR
            pc_i      : Wire;           -- commande d'incr�mentation du compteur de programme PC
            bc_cc     : Nibble;         -- code de condition de branchement
            ir_l      : Wire;           -- commande de chargement du registre d'instruction IR
            msg       : Pair;           -- message
            next_cycle : Triad;         -- num�ro de la prochaine micro-instruction de l'instruction
end record;


----------------------------
-- constantes d�finissant les valeurs possibles des champs du MIC (plus tard)
----------------------------


end package;
