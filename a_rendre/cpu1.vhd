-- Fichier cpu.vhd
-- Conception architecture CPU: Alexandre Parodi
-- Auteur: Jérémy Domarin & Youssef Benfaida

-- Ce fichier contient l'embryon de la spécification de la micro-machine,
-- c'est à dire du processeur sans décodeur d'instrucions.
-- (Essentiellement les déclarations et les connexions des signaux entre eux, mais
-- pas les instances de composant et leurs connexions).
-- Il doit être complété pour obtenir cpu1.vhd ;
-- Il sera utilisé aussi bien pour la simulation que la synthèse.
-- Il convient pour un CPU RISC 16 bits mais peut être étendu à 32 ou 64 bits en changeant N.
-- De même, M peut être changé pour augmenter le nombre de registres jusqu'à 16.

library ieee;
use ieee.std_logic_1164.all; -- type Std_Logic et éléments associées

use work.basic_pack.all; -- types et composants de base (Wire, Nibble,..., REGN, CNTN,...)
use work.cpu_pack.all;   -- composants spécifiques du CPU (ALSUN, BRANCH_CONTROLLER, ...)

use work.mic_pack.all;   -- déclaration du type du code de microinstruction (type MIC_TYPE) 
                         -- déclaration et affectation de la largeur des sélecteurs de registres ALPHA
                         -- déclaration du type des sélecteurs de registres.

entity CPU is
    generic (
        M:   Integer := 4  ;-- nombre de registres dans [4 .. 2**alpha]
        N:   Integer := 16  -- largeur du bus de données en bits dans [16 .. 64]
        );                  -- (alpha = CONSTANTE du paquetage Mic_Pack dans [2..4])
    port (

        -- Control BUS (bus de contrôle):
        clock: in     Std_Logic; -- horloge        (synchronisation)

        n_rst: in     Std_Logic; -- /ReSeT         (initialisation)
        n_str: buffer Std_Logic; -- /STRobe        (usage du bus) 
        wrt:   buffer Std_Logic; -- WRiTe transfer (écriture)
        be0:   buffer Std_Logic; -- Byte Enable 0  (validation octet adresse paire) 
        be1:   buffer Std_Logic; -- Byte Enable 1  (validation octet adresse impaire)

        dbus:  inout  Std_Logic_Vector(N-1 downto 0); -- bus de données
        abus:  buffer Std_Logic_Vector(N-1 downto 1); -- bus d'adresses
        );
end entity;

architecture micro_machine_arc of MICRO_MACHINE is

-- TYPES:
subtype  Word is Std_Logic_Vector(N-1 downto 0); -- mot machine de N bits

-- CONSTANTES:
constant NOCARE_WORD: Word := (others => '-');   -- "--..-" (mot sans importance)
constant HIZ_WORD:    Word := (others => 'Z');   -- "ZZ..Z" (mot débranché)
constant ZERO_WORD:   Word := (others => '0');   -- "00..0" (mot zéro)
constant START_ADDRESS_D2: Std_Logic_Vector(N-2 downto 0) := (1=>'0', others => '1');
--adresse de démarrage du programme divisée par 2; START_ADDRESS = F...FA

-- SIGNAUX INTERNES du schéma-bloc avec les mêmes noms (explications dans cpu.doc):
signal pcd2:       Std_Logic_Vector(N-2 downto 0); -- PC divisé par 2 sur N-1 bits
signal pc:          Word;     -- Program Counter value, adresse du mot suivant l'instruction
signal uv:          Word;     -- micro Value, valeur fournie par la microinstruction
signal qv:          Word;     -- Quick Value, valeur fournie par l'instruction
signal rf_oa:       Word;     -- Output A du bloc de registres
signal rf_ob:       Word;     -- Output B du bloc de registres
signal alsu_a:      Word;     -- opérande A de l'ALSU
signal alsu_b:      Word;     -- opérande B de l'ALSU
signal cos:         Wire;     -- Current Operation Sign
signal coz:         Wire;     -- Current Operation Zero
signal cov:         Wire;     -- Current Operation Overflow
signal coc:         Wire;     -- Current Operation Carry
signal new_flags:   Nibble;   -- Nouveaux indicateurs
signal nf:          Wire;     -- Negative Flag: indicateur de signe
signal cf:          Wire;     -- Carry Flag: indicateur de retenue
signal zf:          Wire;     -- Zero Flag: indicateur de Zero
signal vf:          Wire;     -- oVerflow Flag: indicateur de débordement.
signal flags:       Nibble;   -- Status Register value
signal sr:          Word;     -- Extended Status Register value
signal alsu_result: Word;     -- résultat de l'ALSU
signal dbus_in:     Word;     -- entrée d'instruction et de données du CPU
signal abus0:       Wire;     -- bit n°0 de l'adresse complète
signal cpu_reset:   Wire;     -- initialisation du CPU ssi '1'
signal cpu_address: Word;     -- adresse complète sur N bits
signal pc_L:        Wire;     -- Program_Counter_Load est le signal BRanch de BC
signal mic:   		MIC_Type;  -- Micro Instruction Code
signal ic:    		DByte;      -- Instruction Code
signal cycle:		Triad;		-- numéro de cycle dans l'instruction

-- ALIAS: (un alias est un 2ème nom pour certains signaux)

alias nic:          DByte is dbus_in(15 downto 0); -- Next Instruction Code
-- 2ème nom pour les 16 bits de droite de dbus_in

alias qvc:          Byte is ic(7 downto 0);        -- Quick Value code
-- 2ème nom pour l'octet de droite de ic; 

alias branch_address_d2: Std_Logic_Vector(N-2 downto 0) is alsu_result(N-1 downto 1);
-- N-1 bits de gauche de l'adresse à charger dans le PC en cas de branchement
-- 2ème nom pour les N-1 bits de gauche de alsu_result;

-- DIRECTIVES DE SYNTHESE POUR LES SIGNAUX INTERNES (marqués par un carré noir sur le schéma-bloc)
attribute SYNTHESIS_OFF of alsu_a:   signal is TRUE;    -- conserve ce signal à la synthèse
attribute SYNTHESIS_OFF of alsu_b:   signal is TRUE;    -- conserve ce signal à la synthèse
attribute SYNTHESIS_OFF of alsu_result: signal is TRUE; -- conserve ce signal à la synthèse
attribute SYNTHESIS_OFF of pc_l:     signal is TRUE;    -- conserve ce signal à la synthèse
attribute SYNTHESIS_OFF of abus0:    signal is TRUE;    -- conserve ce signal à la synthèse
attribute SYNTHESIS_OFF of mic:    signal is TRUE;    -- conserve ce signal à la synthèse

begin

-- CONNEXION DU BUS DE DONNéES DBUS

dbus <= alsu_result when ((mic.cbus_str and mic.cbus_wrt) = '1') else HIZ_WORD; 
-- équivalent au tampon ("buffer") et à la porte ET du schéma bloc
-- dbus = alsu_result si transfert en écriture; 
-- sinon DBUS est débranché, donc en haute-impédance "High Z", = ZZ..Z

dbus_in <= dbus; -- permet de piloter dbus_in sans modifier dbus en simulation


-- CONNEXION DU BUS DE CONTRôLE CBUS

be0       <= not abus0;                  -- octet pair validé ssi adresse paire
be1       <= not(mic.cbus_typ xor abus0);-- octet impair validé ssi octet à adresse impaire                                           -- ou mot à adresse paire
cpu_reset <= not n_rst;                  -- initialisation du CPU       
n_str     <= not mic.cbus_str;           -- usage du BUS par le CPU
wrt       <= mic.cbus_wrt;               -- écriture ou lecture


-- CONNEXION DU BUS D'ADRESSE ABUS

abus_gen: for k in 1 to N-1 generate
    abus(k) <= cpu_address(k); -- affecte abus avec les N-1 bits de droite de l'adresse
end generate;
abus0 <= cpu_address(0);       -- affecte abus0


-- CALCUL DE PC

pc <= pcd2 & '0';              -- pc = 2 x pcd2


-- CALCUL DES NOUVEAUX INDICATEURS caractérisant le résultat courant de l'ALSU

coz <= '1' when alsu_result=ZERO_WORD else '0'; -- <=> NOR entre les bits du résultat
cos <= alsu_result(N-1);                        -- bit de gauche du résultat
new_flags <= (coz, cov, coc, cos);              -- regroupement des nouveaux indicateurs


-- AFFECTATIONS DES INDICATEURS caractérisant le résultat de la dernière instruction

(zf, vf, cf, nf) <= flags;                       -- indicateurs: nf cf vf zf = sr
sr <= (3=>zf, 2=>vf, 1=>cf, 0=>nf, others=>'0'); -- sr = 0 0 0 ... 0 nf cf vf zf 


-- CALCUL DE QV par EXTENSION DE SIGNE DE QVC (équivalent à la boîte EXTEND du schéma-bloc) 

qvl_gen: for k in 0 to 7 generate
    QV(k) <= QVC(k); -- les 8 premiers bits de droite de QV sont ceux de QVC
end generate;
qvm_gen: for k in 8 to N-1 generate
    QV(k) <= QVC(7);  -- met le bit de signe de QVC sur les bits restants à gauche de QV
end generate;


-- CALCUL DE la micro-valeur UV par extension de UVC fournie par la micro-instruction

uv <= (1=>mic.alsu_uvc(1), 0=>mic.alsu_uvc(0), others=>'0');

-- =================================================================

-- INSTANCES DES COMPOSANTS AVEC LEURS CONNEXIONS à SPECIFIER CI-APRèS:

-- (cf. baspck.txt et cpupck.txt qui contiennent les
-- blocs d'instantiation tout prêts à copier-coller) dans l'ordre suivant
-- et avec les noms d'instance et de composant suivants:
--
-- (Les noms d'instances peuvent normalement être queconques à condition de
-- n'être pas déjà utilisés, et l'ordre (contrairement à celui de la compilation) 
-- peut être quelconque aussi bien sûr;

-- dans un premier temps (pour micro-machine dans cpu1.vhd)
-- ------------------------------------------------------------------------
--rf:          TRIPLE_PORT_REG_FILE
--prg_cnt:     CNTN
--sta_reg:     REGN
--mux_a:       MUXN_4
--mux_b:       MUXN_4
--mux_address: MUXN_2
--alsu:        ALSUN
--bc:          BRANCH_CONTROLLER
--ir:          REGN

-- ====================================================================

-- Ne pas mettre de décodeur d'instruction pour le TP VHDL 9 et 10
-- concernant la micro-machine seule (CPU sans décodeur d'instruction) !

rf: TRIPLE_PORT_REG_FILE          -- bloc de registres
    generic map (
        alpha => alpha ,  -- largeur des sélecteurs
        M     => M ,  -- nombre de registres
        N     => N )  -- largeur du mot de donnée
    port map (
        clock => clock ,  -- horloge
        R     => cpu_reset ,  -- remise à zéro
        L     => mic.rf_L ,  -- commande de chargement
        INS   => mic.rf_ins ,  -- IS sélecteur du registre à charger
        OAS   => mic.rf_oas ,  -- OAS sélecteur du registre en sortie A
        OBS   => mic.rf_obs,  -- OBS sélecteur du registre en sortie B
        I     => alsu_result,  -- entrée de donnée à charger
        OA    => rf_oa ,  -- sortie A
        OB    => rf_ob ); -- sortie B

prg_cnt : CNTN  -- compteur binaire synchrone
    generic map (
        N  => N-1 )     -- largeur du mot de donnée
    port map (
        clock => clock ,  -- horloge
        R     => cpu_reset ,  -- reset: commande de ré-initialisation
        L     => pc_L ,  -- load: commande de chargement
        T     => mic.pc_i ,  -- increment: commande d'incrémentation
        V     => START_ADDRESS_D2 ,  -- init data: donnée initiale 
        D     => branch_address_d2 ,  -- data: donnée à charger
        Q     => pcd2  -- valeur de comptage
		);

sta_reg : REGN  -- registre
    generic map (
        N  => 4 )     -- largeur du mot de donnée
    port map (
        clock => clock ,  -- horloge
        R     => cpu_reset ,  -- reset: commande de RAZ
        L     => mic.sr_L ,  -- load: commande de chargement
        D     => new_flags ,  -- data: entrée de donnée à charger
        Q     => flags ); -- sortie de donnée stockée

mux_a  : MUXN_4  -- multiplexeur à 4 entrées
    generic map (
        N   => N )  -- largeur du mot de donnée
    port map (
        s   => mic.alsu_ais ,  -- sélecteur de l'entrée à sortir
        x0  => pc ,  -- entrée n°0
        x1  => rf_oa ,  -- entrée n°1
        x2  => (others => '0'),  -- entrée n°2
        x3  => sr ,  -- entrée n°3
		y   => alsu_a ); -- sortie

mux_b  : MUXN_4  -- multiplexeur à 4 entrées
    generic map (
        N   => N )  -- largeur du mot de donnée
    port map (
        s   => mic.alsu_bis ,  -- sélecteur de l'entrée à sortir
        x0  => rf_ob ,  -- entrée n°0
        x1  => dbus_in ,  -- entrée n°1
        x2  => qv,  -- entrée n°2
        x3  => uv,  -- entrée n°3
        y   => alsu_b ); -- sortie

mux_address : MUXN_2  -- multiplexeur à 2 entrées
    generic map (
        N   => N )  -- largeur du mot de donnée
    port map (
        s   => mic.abus_s ,  -- sélecteur de l'entrée à sortir
        x0  => pc ,  -- entrée n°0
        x1  => rf_ob ,  -- entrée n°1
        y   => cpu_address ); -- sortie

alsu: ALSUN     -- opérateur de calcul
    generic map (
        N   => N)   -- largeur du mot de donnée
    port map (
        p   => mic.alsu_op ,  -- code d'opération
        i   => CF ,  -- entrée de retenue
        adr => abus0 ,  -- parité d'adresse
        a   => alsu_a ,  -- entrée d'opérande A
        b   => alsu_b ,  -- entrée d'opérande B
        r   => alsu_result ,  -- sortie de résultat
        c   => coc ,  -- sortie de retenue
        v   => cov ); -- débordement;

bc:  BRANCH_CONTROLLER -- contrôleur de branchement
    port map (
        cc  => mic.bc_cc ,  -- commande de code de condition
        nf  => nf ,  -- entrée negative flag
        cf  => cf ,  -- entrée carry flag
        vf  => vf ,  -- entrée overflow flag
        zf  => zf ,  -- entrée zero flag
        br  => pc_L ); -- sortie requête de branchement

ir : REGN  -- registre
    generic map (
        N  => N )     -- largeur du mot de donnée
    port map (
        clock => clock ,  -- horloge
        R     => cpu_reset ,  -- reset: commande de RAZ
        L     => mic.ir_L ,  -- load: commande de chargement
        D     => nic ,  -- data: entrée de donnée à charger
        Q     => ic ); -- sortie de donnée stockée

cycle_reg : REGN
	generic map (
        N  => 3 )     -- largeur du mot de donnée
    port map (
        clock => clock ,  -- horloge
        R     => cpu_reset ,  -- reset: commande de RAZ
        L     => mic.ir_L ,  -- load: commande de chargement
        D     => nic ,  -- data: entrée de donnée à charger
		cycle => cycle; -- numéro de cycle dans l'instruction
        Q     => ic ); -- sortie de donnée stockée

idl : INSTRUCTION_DECODER_LOGIC
    port map (
        ic		=> ic,    -- code d'instruction
        cycle	=> cycle,    -- micro-instruction step (i.e. n° cycle dans l'instruction)
		mic		=> mic);  -- code de micro-instruction

end architecture;
