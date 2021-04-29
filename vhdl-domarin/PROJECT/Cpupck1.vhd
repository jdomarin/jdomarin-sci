-- (C) Copyright Alexandre Parodi - October 2002-2006
-- fichier cpupck1.vhd

-- Définit le paquetage CPU_PACK
-- qui déclare tous les composants spécifiques du CPU
-- pour une micromachine N bits RISC:
--
-- ALSUN, TRIPLE_PORT_REG_FILE, 
-- BRANCH_CONTROLLER

-- NE PAS MODIFIER CE FICHIER !!
-- MODIFIER PLUTOT LES ENTITéS !!

library ieee; 				 		
use ieee.std_logic_1164.all;
use work.mic_pack.all;


package cpu_pack is


component ALSUN
   generic(N: Integer := 4);
   port(
     p:   in     Std_Logic_Vector(4 downto 0);   -- code d'opération
     i:   in     Std_Logic;                      -- entrée de retenue
     adr: in     Std_Logic;                      -- parité d'adresse
     a:   in     Std_Logic_Vector(N-1 downto 0); -- entrée d'opérande
     b:   in     Std_Logic_Vector(N-1 downto 0); -- entrée d'opérande
     r:   buffer Std_Logic_Vector(N-1 downto 0); -- sortie de résultat
     c:   buffer Std_Logic;                      -- sortie de retenue
     v:   buffer Std_Logic);                     -- débordement;
end component;


component BRANCH_CONTROLLER -- contrôleur de branchement
    port (
        cc: in Std_Logic_Vector(3 downto 0); -- commande de code de condition
        nf: in Std_Logic;                    -- entrée negative flag
        cf: in Std_Logic;                    -- entrée carry flag
        vf: in Std_Logic;                    -- entrée overflow flag
        zf: in Std_Logic;                    -- entrée zero flag
        br: buffer Std_Logic);               -- sortie requête de branchement
end component;


component TRIPLE_PORT_REG_FILE   -- bloc de registres
    generic (
        alpha:             Integer := 2;  -- largeur des sélecteurs
        M:                 Integer := 4;  -- nombre de registres
        N:                 Integer := 4); -- largeur du mot de donnée
    port (
        clock:             in Std_Logic; -- horloge
        R:                 in Std_Logic; -- remise à zéro
        L:                 in Std_Logic; -- commande de chargement
        ins:               in Std_Logic_Vector(alpha-1 downto 0); -- IS sélecteur du registre à charger
        oas:               in Std_Logic_Vector(alpha-1 downto 0); -- OAS sélecteur du registre en sortie A
        obs:               in Std_Logic_Vector(alpha-1 downto 0); -- OBS sélecteur du registre en sortie B
        i:                 in     Std_Logic_Vector(N-1 downto 0);  -- entrée de donnée à charger
        oa:                buffer Std_Logic_Vector(N-1 downto 0);  -- sortie A
        ob:                buffer Std_Logic_Vector(N-1 downto 0)); -- sortie B
end component;


-- le décodeur d'instruction ne figure pas ici: il fera partie de la version finale.


end package;

