-- VHDL - (C) Alexandre Parodi - 2006
-- fichier micpck.vhd

library ieee;                -- importe la bibliothèque IEEE			
use ieee.std_logic_1164.all; -- montre tout le paquetage STD_LOGIC_1164 de ieee
use work.basic_pack.all;     -- montre tout le paquetage basic_pack de work

------------------------------
-- DEFINITION du PAQUETAGE MIC_PACK
------------------------------

-- Ce paquetage contient la définition de:

--    * type Micro Instruction Code;

--    * valeurs des champs de Micro Instruction Code (plus tard).


package MIC_PACK is

------------------------------
-- MIC type
------------------------------

Constant ALPHA: Integer := 2; -- largeur des sélecteurs du bloc de regsitres
                              -- Peut être choisie dans {2, 3, 4}

Subtype Selector_Type is Std_Logic_Vector(ALPHA-1 downto 0); -- Type des sélecteurs de registre
                                                             -- Ce type est un mot de ALPHA bits.

type Mic_Type is record
            alsu_op   : Pentad;         -- code opération de l'ALSU
            alsu_ais  : Pair;           -- sélection de l'entrée A de l'ALSU
            alsu_bis  : Pair;           -- sélection de l'entrée B de l'ALSU
            alsu_uvc  : Pair;           -- code de micro valeur
            rf_oas    : Selector_Type;  -- registre en sortie OA du bloc de registres
            rf_obs    : Selector_Type;  -- registre en sortie OB du bloc de registres
            rf_ins    : Selector_Type;  -- registre à charger dans le bloc de registres
            rf_l      : Wire;           -- commande de chargement du bloc de registres
            abus_s    : Wire;           -- sélection de l'adresse
            cbus_typ  : Wire;           -- type de donnée sur bus de données
            cbus_wrt  : Wire;           -- sens des données sur bus de données
            cbus_str  : Wire;           -- utilisation du bus de données
            sr_l      : Wire;           -- commande de chargement du registre d'état SR
            pc_i      : Wire;           -- commande d'incrémentation du compteur de programme PC
            bc_cc     : Nibble;         -- code de condition de branchement
            ir_l      : Wire;           -- commande de chargement du registre d'instruction IR
            msg       : Pair;           -- message
            next_cycle : Triad;         -- numéro de la prochaine micro-instruction de l'instruction
end record;


----------------------------
-- constantes définissant les valeurs possibles des champs du MIC (plus tard)
----------------------------


end package;
