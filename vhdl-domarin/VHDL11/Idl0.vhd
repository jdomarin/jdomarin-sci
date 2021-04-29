-- VHDL - (C) Alexandre Parodi - 2001 - Novembre 2006
-- 
-- Fichier idl0.vhd

library ieee;
use ieee.std_logic_1164.all;

use work.basic_pack.all; -- use the BASIC_PACK package from the WORK (default) library
use work.mic_pack.all;   -- use the MIC_PACK package from the WORK (default) library
use work.idl_pack.all;   -- use the IDL_PACK package from the WORK (default) library

entity INSTRUCTION_DECODER_LOGIC is
    port (
        ic:    in     DByte;    -- code d'instruction
        cycle: in     Triad;    -- micro-instruction step (i.e. n° cycle dans l'instruction)
	mic:   buffer Mic_Type  -- code de micro-instruction
	);
attribute SUM_SPLIT of mic: signal is CASCADED; -- saves one cell if number of products > 16
end entity;

architecture idl_arc of INSTRUCTION_DECODER_LOGIC is


-- Déclaration des alias de champs d'instructions pour chaque groupe de format

-- Format I 
alias f1_tag:  Wire          is ic(15);
alias f1_op3:  Triad         is ic(14 downto 12);       -- OPeration 3 opérandes
alias f1_crsa: Selector_Type is ic(ALPHA-1+8 downto 8); -- Registre Source A
alias f1_crsb: Selector_Type is ic(ALPHA-1+4 downto 4); -- Registre Source B
alias f1_crd:  Selector_Type is ic(ALPHA-1 downto 0);   -- Registre Destination

-- Format II 
alias f2_op2:  Nibble        is ic(11 downto 8);        -- Operation 2 opérandes
alias f2_tag:  Nibble        is ic(15 downto 12);
alias f2_crs:  Selector_Type is ic(ALPHA-1+4 downto 4); -- Registre Source
alias f2_crd:  Selector_Type is ic(ALPHA-1 downto 0);   -- Registre destination

-- Format III
alias f3_tag:   Pair          is ic(15 downto 14);         -- tag
alias f3_type:  Pair          is ic(13 downto 12);         -- type operande
alias f3_d:     Wire          is ic(7);                    -- direction
alias f3_cra:   Selector_Type is ic(ALPHA-1+8 downto 0+8); -- registre A
alias f3_mode:  Triad         is ic(6 downto 4);           -- mode d'adressage
alias f3_crb:   Selector_Type is ic(ALPHA-1 downto 0);     -- registre B

-- Format IV
alias f4_cc  : Nibble        is ic(11 downto 8);
alias f4_tag : Nibble        is ic(15 downto 12);
alias f4_cr  : Selector_Type is ic(ALPHA-1 downto 0);
alias f4_mode: Triad         is ic(6 downto 4);

-- Format V
alias f5_tag : Pentad        is ic(15 downto 11);
alias f5_op1 : Triad         is ic(10 downto 8);
alias f5_mode: Triad         is ic(6 downto 4);
alias f5_cr  : Selector_Type is ic(ALPHA-1 downto 0);

-- Format VI
alias f6_op0:  Triad is ic(10 downto 8);

-- Format VII
alias f7_tag:  Triad  is ic (15 downto 13);
alias f7_opq:  Wire   is ic(12);
alias f7_cr :  Selector_Type is ic(ALPHA-1+8 downto 8);
alias f7_qvc:  Byte   is ic(7 downto 0);

-- Format VIII
alias f8_tag:  Nibble is ic(15 downto 12);
alias f8_cc:   Nibble is ic(11 downto 8);
alias f8_disp: Byte   is ic(7 downto 0);


signal fc: Nibble;
attribute SYNTHESIS_OFF of fc: signal is TRUE;

begin
                                 
-------------------------------------------
-- FORMAT DETECTOR: DéTERMINATION DU FORMAT
-------------------------------------------

fc <=
    F1_CODE
        when (ic and F1_MASK) = F1_MARK else
    F2_CODE
        when (ic and F2_MASK) = F2_MARK else
    F3_CODE
        when (((ic and F3_MASK) = F3_MARK1)
           or ((ic and F3_MASK) = F3_MARK2) 
           or ((ic and F3_MASK) = F3_MARK3))
	  	else
    F4_CODE
	    when (ic and F4_MASK) = F4_MARK else
    F5_CODE
	    when (ic and F5_MASK) = F5_MARK else
    F6_CODE
	    when (ic and F6_MASK) = F6_MARK else
    F7_CODE
	    when (ic and F7_MASK) = F7_MARK else
    F8_CODE
	    when (ic and F8_MASK) = F8_MARK else
    FC_ERROR;

----------------------------------------------------------------
-- MIC GENERATOR: construction de la micro-instruction
----------------------------------------------------------------
--

mic_gen_proc: process (fc, cycle, ic,
    f1_op3, f1_crsa, f1_crsb, f1_crd, f2_op2, f2_crs, f2_crd, 
    f3_mode, f3_d, f3_type, f3_cra, f3_crb,
    f4_cc, f4_mode, f4_cr, f5_op1, f5_mode, f5_cr, 
    f6_op0, f7_opq, f7_cr, f7_qvc, f8_cc, f8_disp)      -- processus "combinatoire" déclenché
                                           -- si l'une des entrées change;
variable micv: Mic_Type := MIC_ERROR;      -- code de microinstruction en construction

begin



mic <= micv;  -- affecte le contenu de la variable micv au signal mic

end process;

end architecture;
