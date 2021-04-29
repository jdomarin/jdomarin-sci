-- Fichier cpu.vhd
-- Conception architecture CPU: Alexandre Parodi
-- Auteur: J�r�my Domarin & Youssef Benfaida

-- Ce fichier contient l'embryon de la sp�cification de la micro-machine,
-- c'est � dire du processeur sans d�codeur d'instrucions.
-- (Essentiellement les d�clarations et les connexions des signaux entre eux, mais
-- pas les instances de composant et leurs connexions).
-- Il doit �tre compl�t� pour obtenir cpu1.vhd ;
-- Il sera utilis� aussi bien pour la simulation que la synth�se.
-- Il convient pour un CPU RISC 16 bits mais peut �tre �tendu � 32 ou 64 bits en changeant N.
-- De m�me, M peut �tre chang� pour augmenter le nombre de registres jusqu'� 16.

library ieee;
use ieee.std_logic_1164.all; -- type Std_Logic et �l�ments associ�es

use work.basic_pack.all; -- types et composants de base (Wire, Nibble,..., REGN, CNTN,...)
use work.cpu_pack.all;   -- composants sp�cifiques du CPU (ALSUN, BRANCH_CONTROLLER, ...)

use work.mic_pack.all;   -- d�claration du type du code de microinstruction (type MIC_TYPE) 
                         -- d�claration et affectation de la largeur des s�lecteurs de registres ALPHA
                         -- d�claration du type des s�lecteurs de registres.

entity CPU is
    generic (
        M:   Integer := 4  ;-- nombre de registres dans [4 .. 2**alpha]
        N:   Integer := 16  -- largeur du bus de donn�es en bits dans [16 .. 64]
        );                  -- (alpha = CONSTANTE du paquetage Mic_Pack dans [2..4])
    port (

        -- Control BUS (bus de contr�le):
        clock: in     Std_Logic; -- horloge        (synchronisation)

        n_rst: in     Std_Logic; -- /ReSeT         (initialisation)
        n_str: buffer Std_Logic; -- /STRobe        (usage du bus) 
        wrt:   buffer Std_Logic; -- WRiTe transfer (�criture)
        be0:   buffer Std_Logic; -- Byte Enable 0  (validation octet adresse paire) 
        be1:   buffer Std_Logic; -- Byte Enable 1  (validation octet adresse impaire)

        dbus:  inout  Std_Logic_Vector(N-1 downto 0); -- bus de donn�es
        abus:  buffer Std_Logic_Vector(N-1 downto 1) -- bus d'adresses
        );
end entity;

architecture micro_machine_arc of CPU is

-- TYPES:
subtype  Word is Std_Logic_Vector(N-1 downto 0); -- mot machine de N bits

-- CONSTANTES:
constant NOCARE_WORD: Word := (others => '-');   -- "--..-" (mot sans importance)
constant HIZ_WORD:    Word := (others => 'Z');   -- "ZZ..Z" (mot d�branch�)
constant ZERO_WORD:   Word := (others => '0');   -- "00..0" (mot z�ro)
constant START_ADDRESS_D2: Std_Logic_Vector(N-2 downto 0) := (1=>'0', others => '1');
--adresse de d�marrage du programme divis�e par 2; START_ADDRESS = F...FA

-- SIGNAUX INTERNES du sch�ma-bloc avec les m�mes noms (explications dans cpu.doc):
signal pcd2:       Std_Logic_Vector(N-2 downto 0); -- PC divis� par 2 sur N-1 bits
signal pc:          Word;     -- Program Counter value, adresse du mot suivant l'instruction
signal uv:          Word;     -- micro Value, valeur fournie par la microinstruction
signal qv:          Word;     -- Quick Value, valeur fournie par l'instruction
signal rf_oa:       Word;     -- Output A du bloc de registres
signal rf_ob:       Word;     -- Output B du bloc de registres
signal alsu_a:      Word;     -- op�rande A de l'ALSU
signal alsu_b:      Word;     -- op�rande B de l'ALSU
signal cos:         Wire;     -- Current Operation Sign
signal coz:         Wire;     -- Current Operation Zero
signal cov:         Wire;     -- Current Operation Overflow
signal coc:         Wire;     -- Current Operation Carry
signal new_flags:   Nibble;   -- Nouveaux indicateurs
signal nf:          Wire;     -- Negative Flag: indicateur de signe
signal cf:          Wire;     -- Carry Flag: indicateur de retenue
signal zf:          Wire;     -- Zero Flag: indicateur de Zero
signal vf:          Wire;     -- oVerflow Flag: indicateur de d�bordement.
signal flags:       Nibble;   -- Status Register value
signal sr:          Word;     -- Extended Status Register value
signal alsu_result: Word;     -- r�sultat de l'ALSU
signal dbus_in:     Word;     -- entr�e d'instruction et de donn�es du CPU
signal abus0:       Wire;     -- bit n�0 de l'adresse compl�te
signal cpu_reset:   Wire;     -- initialisation du CPU ssi '1'
signal cpu_address: Word;     -- adresse compl�te sur N bits
signal pc_L:        Wire;     -- Program_Counter_Load est le signal BRanch de BC
signal mic:   		MIC_Type;  -- Micro Instruction Code
signal ic:    		DByte;      -- Instruction Code
signal cycle:		Triad;		-- num�ro de cycle dans l'instruction

-- ALIAS: (un alias est un 2�me nom pour certains signaux)

alias nic:          DByte is dbus_in(15 downto 0); -- Next Instruction Code
-- 2�me nom pour les 16 bits de droite de dbus_in

alias qvc:          Byte is ic(7 downto 0);        -- Quick Value code
-- 2�me nom pour l'octet de droite de ic; 

alias branch_address_d2: Std_Logic_Vector(N-2 downto 0) is alsu_result(N-1 downto 1);
-- N-1 bits de gauche de l'adresse � charger dans le PC en cas de branchement
-- 2�me nom pour les N-1 bits de gauche de alsu_result;

-- DIRECTIVES DE SYNTHESE POUR LES SIGNAUX INTERNES (marqu�s par un carr� noir sur le sch�ma-bloc)
attribute SYNTHESIS_OFF of alsu_a:   signal is TRUE;    -- conserve ce signal � la synth�se
attribute SYNTHESIS_OFF of alsu_b:   signal is TRUE;    -- conserve ce signal � la synth�se
attribute SYNTHESIS_OFF of alsu_result: signal is TRUE; -- conserve ce signal � la synth�se
attribute SYNTHESIS_OFF of pc_l:     signal is TRUE;    -- conserve ce signal � la synth�se
attribute SYNTHESIS_OFF of abus0:    signal is TRUE;    -- conserve ce signal � la synth�se
attribute SYNTHESIS_OFF of mic:    signal is TRUE;    -- conserve ce signal � la synth�se

begin

-- CONNEXION DU BUS DE DONN�ES DBUS

dbus <= alsu_result when ((mic.cbus_str and mic.cbus_wrt) = '1') else HIZ_WORD; 
-- �quivalent au tampon ("buffer") et � la porte ET du sch�ma bloc
-- dbus = alsu_result si transfert en �criture; 
-- sinon DBUS est d�branch�, donc en haute-imp�dance "High Z", = ZZ..Z

dbus_in <= dbus; -- permet de piloter dbus_in sans modifier dbus en simulation


-- CONNEXION DU BUS DE CONTR�LE CBUS

be0       <= not abus0;                  -- octet pair valid� ssi adresse paire
be1       <= not(mic.cbus_typ xor abus0);-- octet impair valid� ssi octet � adresse impaire                                           -- ou mot � adresse paire
cpu_reset <= not n_rst;                  -- initialisation du CPU       
n_str     <= not mic.cbus_str;           -- usage du BUS par le CPU
wrt       <= mic.cbus_wrt;               -- �criture ou lecture


-- CONNEXION DU BUS D'ADRESSE ABUS

abus_gen: for k in 1 to N-1 generate
    abus(k) <= cpu_address(k); -- affecte abus avec les N-1 bits de droite de l'adresse
end generate;
abus0 <= cpu_address(0);       -- affecte abus0


-- CALCUL DE PC

pc <= pcd2 & '0';              -- pc = 2 x pcd2


-- CALCUL DES NOUVEAUX INDICATEURS caract�risant le r�sultat courant de l'ALSU

coz <= '1' when alsu_result=ZERO_WORD else '0'; -- <=> NOR entre les bits du r�sultat
cos <= alsu_result(N-1);                        -- bit de gauche du r�sultat
new_flags <= (coz, cov, coc, cos);              -- regroupement des nouveaux indicateurs


-- AFFECTATIONS DES INDICATEURS caract�risant le r�sultat de la derni�re instruction

(zf, vf, cf, nf) <= flags;                       -- indicateurs: nf cf vf zf = sr
sr <= (3=>zf, 2=>vf, 1=>cf, 0=>nf, others=>'0'); -- sr = 0 0 0 ... 0 nf cf vf zf 


-- CALCUL DE QV par EXTENSION DE SIGNE DE QVC (�quivalent � la bo�te EXTEND du sch�ma-bloc) 

qvl_gen: for k in 0 to 7 generate
    QV(k) <= QVC(k); -- les 8 premiers bits de droite de QV sont ceux de QVC
end generate;
qvm_gen: for k in 8 to N-1 generate
    QV(k) <= QVC(7);  -- met le bit de signe de QVC sur les bits restants � gauche de QV
end generate;


-- CALCUL DE la micro-valeur UV par extension de UVC fournie par la micro-instruction

uv <= (1=>mic.alsu_uvc(1), 0=>mic.alsu_uvc(0), others=>'0');

-- =================================================================

-- INSTANCES DES COMPOSANTS AVEC LEURS CONNEXIONS � SPECIFIER CI-APR�S:

-- (cf. baspck.txt et cpupck.txt qui contiennent les
-- blocs d'instantiation tout pr�ts � copier-coller) dans l'ordre suivant
-- et avec les noms d'instance et de composant suivants:
--
-- (Les noms d'instances peuvent normalement �tre queconques � condition de
-- n'�tre pas d�j� utilis�s, et l'ordre (contrairement � celui de la compilation) 
-- peut �tre quelconque aussi bien s�r;

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

-- Ne pas mettre de d�codeur d'instruction pour le TP VHDL 9 et 10
-- concernant la micro-machine seule (CPU sans d�codeur d'instruction) !

rf: TRIPLE_PORT_REG_FILE          -- bloc de registres
    generic map (
        alpha => alpha ,  -- largeur des s�lecteurs
        M     => M ,  -- nombre de registres
        N     => N )  -- largeur du mot de donn�e
    port map (
        clock => clock ,  -- horloge
        R     => cpu_reset ,  -- remise � z�ro
        L     => mic.rf_L ,  -- commande de chargement
        INS   => mic.rf_ins ,  -- IS s�lecteur du registre � charger
        OAS   => mic.rf_oas ,  -- OAS s�lecteur du registre en sortie A
        OBS   => mic.rf_obs,  -- OBS s�lecteur du registre en sortie B
        I     => alsu_result,  -- entr�e de donn�e � charger
        OA    => rf_oa ,  -- sortie A
        OB    => rf_ob ); -- sortie B

prg_cnt : CNTN  -- compteur binaire synchrone
    generic map (N  => N-1 )     -- largeur du mot de donn�e
    port map (
        clock => clock ,  -- horloge
        R     => cpu_reset ,  -- reset: commande de r�-initialisation
        L     => pc_L ,  -- load: commande de chargement
        T     => mic.pc_i ,  -- increment: commande d'incr�mentation
        V     => START_ADDRESS_D2 ,  -- init data: donn�e initiale 
        D     => branch_address_d2 ,  -- data: donn�e � charger
        Q     => pcd2  -- valeur de comptage
		);

sta_reg : REGN  -- registre
    generic map (N  => 4 )     -- largeur du mot de donn�e
    port map (
        clock => clock ,  -- horloge
        R     => cpu_reset ,  -- reset: commande de RAZ
        L     => mic.sr_L ,  -- load: commande de chargement
        D     => new_flags ,  -- data: entr�e de donn�e � charger
        Q     => flags ); -- sortie de donn�e stock�e

mux_a  : MUXN_4  -- multiplexeur � 4 entr�es
    generic map (N   => N )  -- largeur du mot de donn�e
    port map (
        s   => mic.alsu_ais ,  -- s�lecteur de l'entr�e � sortir
        x0  => pc ,  -- entr�e n�0
        x1  => rf_oa ,  -- entr�e n�1
        x2  => (others => '0'),  -- entr�e n�2
        x3  => sr ,  -- entr�e n�3
		y   => alsu_a ); -- sortie

mux_b  : MUXN_4  -- multiplexeur � 4 entr�es
    generic map (N   => N )  -- largeur du mot de donn�e
    port map (
        s   => mic.alsu_bis ,  -- s�lecteur de l'entr�e � sortir
        x0  => rf_ob ,  -- entr�e n�0
        x1  => dbus_in ,  -- entr�e n�1
        x2  => qv,  -- entr�e n�2
        x3  => uv,  -- entr�e n�3
        y   => alsu_b ); -- sortie

mux_address : MUXN_2  -- multiplexeur � 2 entr�es
    generic map (N   => N )  -- largeur du mot de donn�e
    port map (
        s   => mic.abus_s ,  -- s�lecteur de l'entr�e � sortir
        x0  => pc ,  -- entr�e n�0
        x1  => rf_ob ,  -- entr�e n�1
        y   => cpu_address ); -- sortie

alsu: ALSUN     -- op�rateur de calcul
    generic map (N   => N)   -- largeur du mot de donn�e
    port map (
        p   => mic.alsu_op ,  -- code d'op�ration
        i   => CF ,  -- entr�e de retenue
        adr => abus0 ,  -- parit� d'adresse
        a   => alsu_a ,  -- entr�e d'op�rande A
        b   => alsu_b ,  -- entr�e d'op�rande B
        r   => alsu_result ,  -- sortie de r�sultat
        c   => coc ,  -- sortie de retenue
        v   => cov ); -- d�bordement;

bc:  BRANCH_CONTROLLER -- contr�leur de branchement
    port map (
        cc  => mic.bc_cc ,  -- commande de code de condition
        nf  => nf ,  -- entr�e negative flag
        cf  => cf ,  -- entr�e carry flag
        vf  => vf ,  -- entr�e overflow flag
        zf  => zf ,  -- entr�e zero flag
        br  => pc_L ); -- sortie requ�te de branchement

ir : REGN  -- registre
    generic map (
        N  => N )     -- largeur du mot de donn�e
    port map (
        clock => clock ,  -- horloge
        R     => cpu_reset ,  -- reset: commande de RAZ
        L     => mic.ir_L ,  -- load: commande de chargement
        D     => nic ,  -- data: entr�e de donn�e � charger
        Q     => ic ); -- sortie de donn�e stock�e

cycle_reg : REGN
	generic map (N  => 3 )     -- largeur du mot de donn�e
    port map (
        clock => clock,  -- horloge
        R     => cpu_reset,  -- reset: commande de RAZ
        L     => '1',  -- load: commande de chargement
        D     => mic.next_cycle,  -- data: entr�e de donn�e � charger
		Q => cycle -- num�ro de cycle dans l'instruction
        ); -- sortie de donn�e stock�e

idl : INSTRUCTION_DECODER_LOGIC
    port map (
        ic		=> ic,    -- code d'instruction
        cycle	=> cycle,    -- micro-instruction step (i.e. n� cycle dans l'instruction)
		mic		=> mic);  -- code de micro-instruction

end architecture;
