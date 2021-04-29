-- (C) Copyright Alexandre Parodi - October 2002 - November 2006
-- fichier cpupck1.vhd

-- D�finit le paquetage CPU_PACK
-- qui d�clare tous les composants sp�cifiques du CPU
-- pour une micromachine N bits RISC:
--
-- ALSUN, TRIPLE_PORT_REG_FILE, 
-- BRANCH_CONTROLLER

-- NE PAS MODIFIER CE FICHIER !!
-- MODIFIER PLUTOT LES ENTIT�S !!

library ieee; 				 		
use ieee.std_logic_1164.all;
use work.basic_pack.all;
use work.mic_pack.all;


package cpu_pack is

component ALSUN
   generic(N: Integer := 4);
   port(
     p:   in     Std_Logic_Vector(4 downto 0);   -- code d'op�ration
     i:   in     Std_Logic;                      -- entr�e de retenue
     adr: in     Std_Logic;                      -- parit� d'adresse
     a:   in     Std_Logic_Vector(N-1 downto 0); -- entr�e d'op�rande
     b:   in     Std_Logic_Vector(N-1 downto 0); -- entr�e d'op�rande
     r:   buffer Std_Logic_Vector(N-1 downto 0); -- sortie de r�sultat
     c:   buffer Std_Logic;                      -- sortie de retenue
     v:   buffer Std_Logic);                     -- d�bordement;
end component;


component BRANCH_CONTROLLER -- contr�leur de branchement
    port (
        cc: in Std_Logic_Vector(3 downto 0); -- commande de code de condition
        nf: in Std_Logic;                    -- entr�e negative flag
        cf: in Std_Logic;                    -- entr�e carry flag
        vf: in Std_Logic;                    -- entr�e overflow flag
        zf: in Std_Logic;                    -- entr�e zero flag
        br: buffer Std_Logic);               -- sortie requ�te de branchement
end component;


component TRIPLE_PORT_REG_FILE   -- bloc de registres
    generic (
        alpha:             Integer := 2;  -- largeur des s�lecteurs
        M:                 Integer := 4;  -- nombre de registres
        N:                 Integer := 4); -- largeur du mot de donn�e
    port (
        clock:             in Std_Logic; -- horloge
        R:                 in Std_Logic; -- remise � z�ro
        L:                 in Std_Logic; -- commande de chargement
        ins:               in Std_Logic_Vector(alpha-1 downto 0); -- IS s�lecteur du registre � charger
        oas:               in Std_Logic_Vector(alpha-1 downto 0); -- OAS s�lecteur du registre en sortie A
        obs:               in Std_Logic_Vector(alpha-1 downto 0); -- OBS s�lecteur du registre en sortie B
        i:                 in     Std_Logic_Vector(N-1 downto 0);  -- entr�e de donn�e � charger
        oa:                buffer Std_Logic_Vector(N-1 downto 0);  -- sortie A
        ob:                buffer Std_Logic_Vector(N-1 downto 0)); -- sortie B
end component;


-- le d�codeur d'instruction figure bien ici dans cette version finale.

component INSTRUCTION_DECODER_LOGIC -- logique du d�codeur d'instruction
    port (
        ic    :  in     DByte;     -- entr�e de code d'instruction
        cycle :  in     Triad;     -- n� cycle dans l'instruction
        mic   :  buffer Mic_Type); -- sortie de code de micro instruction

end component;


end package;

