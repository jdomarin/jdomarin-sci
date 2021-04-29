-- file idlpck.vhd

-- VHDL - (C) Alexandre Parodi - 2001 - Mars 2007

library ieee;
use ieee.std_logic_1164.all;
use work.basic_pack.all;
use work.mic_pack.all;

package idl_pack is


-- FORMAT CODES

constant FC_ERROR:    Nibble := x"0"; -- Format error                    -- unrecognized format 
constant F1_CODE:     Nibble := x"1"; -- Format I   (Hexa of 1 = "0001") -- 3 registers instructions
constant F2_CODE:     Nibble := x"2"; -- Format II  (Hexa of 2 = "0010") -- 2 registers instructions
constant F3_CODE:     NIBBLE := x"3"; -- Format III                      -- transfer instructions
constant F4_CODE:     Nibble := x"4"; -- Format IV                       -- long relative jumps 
constant F5_CODE:     Nibble := x"5"; -- Format V                        -- 1 register instructions
constant F6_CODE:     Nibble := x"6"; -- Format VI                       -- no register instructions
constant F7_CODE:     Nibble := x"7"; -- Format VII                      -- quick instructions
constant F8_CODE:     Nibble := x"8"; -- Format VIII                     -- short relative jumps


-- CONDITION CODES

constant CC_NV  :   Nibble := "0000"; -- NeVer
constant CC_AL  :   Nibble := "0001"; -- ALways
constant CC_EQ  :   Nibble := "0010"; -- EQual
constant CC_NE  :   Nibble := "0011"; -- Not Equal
constant CC_GE  :   Nibble := "0100"; -- Greater or Equal
constant CC_LE  :   Nibble := "0101"; -- Lower or Equal
constant CC_GT  :   Nibble := "0110"; -- GreaTer
constant CC_LW  :   Nibble := "0111"; -- LoWer
constant CC_AE  :   Nibble := "1000"; -- Above or Equal
constant CC_BE  :   Nibble := "1001"; -- Below or Equal
constant CC_AB  :   Nibble := "1010"; -- ABove
constant CC_BL  :   Nibble := "1011"; -- BeLow

constant CC_VS  :   Nibble := "1100"; -- V flag Set
constant CC_VC  :   Nibble := "1101"; -- V flag Cleared
constant CC_NS  :   Nibble := "1110"; -- N flag Set
constant CC_NC  :   Nibble := "1111"; -- N flag Cleared


--ADDRESSING MODE CODES

constant MODE_IMMEDIATE:            Triad := "000"; --0
constant MODE_REGISTER:             Triad := "001"; --1
constant MODE_INDIRECT:             Triad := "010"; --2
constant MODE_INDIRECT_POST_INC:    Triad := "011"; --3
constant MODE_INDIRECT_PRE_DEC:     Triad := "100"; --4
constant MODE_DIRECT:               Triad := "101"; --5
constant MODE_INDEXED:              Triad := "110"; --6
constant MODE_INDIRECT_PRE_INDEXED: Triad := "111"; --7


-- FORMAT I CONSTANTS

constant F1_MASK :   DByte := "1000000000000000"; -- Format I mask
constant F1_MARK :   DByte := "1000000000000000"; -- Format I mark
constant F1_TAG_F1:  Wire  := '1';

constant F1_OP3_ADC: Triad := "000"; -- ADd Carry
constant F1_OP3_XOR: Triad := "001"; -- bit wise eXclusive OR
constant F1_OP3_DIV: Triad := "010"; -- DIVide
constant F1_OP3_MUL: Triad := "011"; -- MULtiply
constant F1_OP3_AND: Triad := "100"; -- bit wise AND
constant F1_OP3_OR:  Triad := "101"; -- bit wise inclusive OR
constant F1_OP3_ADD: Triad := "110"; -- ADD
constant F1_OP3_SUB: Triad := "111"; -- SUBstract

-- FORMAT II CONSTANTS

constant F2_MASK :   DByte  := "1111000000000000"; -- Format II mask
constant F2_MARK :   DByte  := "0100000000000000"; -- Format II mark
constant F2_TAG_F2:  Nibble := "0100";

constant F2_OP2_RLC: Nibble := "0000"; -- Rotate Left through Carry
constant F2_OP2_RRC: Nibble := "0001"; -- Rotate Right through Carry
constant F2_OP2_SRL: Nibble := "0010"; -- Shift Right Logical
constant F2_OP2_SRA: Nibble := "0011"; -- Shift Right Arithmetic
constant F2_OP2_NOT: Nibble := "0100"; -- bit wise NOT
constant F2_OP2_SBB: Nibble := "0101"; -- SuBstract Borrow
constant F2_OP2_SHL: Nibble := "0110"; -- SHift Left
constant F2_OP2_NEG: Nibble := "0111"; -- NEGate
constant F2_OP2_INP: Nibble := "1000"; -- INPut
constant F2_OP2_OUT: Nibble := "1001"; -- OUTput
constant F2_OP2_SWB: Nibble := "1010"; -- SWap Bytes
constant F2_OP2_RLB: Nibble := "1011"; -- Rotate Left by one Byte
constant F2_OP2_ANI: Nibble := "1100"; -- ANd Immediate
constant F2_OP2_EXT: Nibble := "1101"; -- EXTend sign
constant F2_OP2_ADI: Nibble := "1110"; -- ADd Immediate
constant F2_OP2_CMP: Nibble := "1111"; -- CoMPare


--FORMAT III CONSTANTS

constant F3_MASK  :   DByte  := "1111000000000000"; -- Format III mask
constant F3_MARK1 :   DByte  := "0101000000000000"; -- Format III mark
constant F3_MARK2 :   DByte  := "0110000000000000"; -- Format III mark
constant F3_MARK3 :   DByte  := "0111000000000000"; -- Format III mark
constant F3_TAG_F3:   Pair   := "01";

constant F3_TYPE_WORD: Pair := "10";
constant F3_TYPE_BYTE: Pair := "01";
constant F3_TYPE_LONG: Pair := "11";

constant F3_D_LD: Wire:= '1';  -- LoaD
constant F3_D_ST: Wire:= '0';  -- STore

constant F3_D_LOD: Wire:= '1'; -- LoaD  (old version)
constant F3_D_STO: Wire:= '0'; -- STore (old version)

constant F3_MODE_IMMEDIATE:            Triad := MODE_IMMEDIATE;
constant F3_MODE_REGISTER:             Triad := MODE_REGISTER;
constant F3_MODE_INDIRECT:             Triad := MODE_INDIRECT;
constant F3_MODE_INDIRECT_POST_INC:    Triad := MODE_INDIRECT_POST_INC;
constant F3_MODE_INDIRECT_PRE_DEC:     Triad := MODE_INDIRECT_PRE_DEC;
constant F3_MODE_DIRECT:               Triad := MODE_DIRECT;
constant F3_MODE_INDEXED:              Triad := MODE_INDEXED;
constant F3_MODE_INDIRECT_PRE_INDEXED: Triad := MODE_INDIRECT_PRE_INDEXED;


--FORMAT IV CONSTANTS
constant F4_MASK   :   DByte  := "1111000010000000"; -- Format IV mask
constant F4_MARK   :   DByte  := "0000000010000000"; -- Format IV mark
constant F4_CC_TAG :   Nibble := "0000";

constant F4_CC_NB  :   Nibble := CC_NV;
constant F4_CC_BR  :   Nibble := CC_AL; -- Format VIII condition code
constant F4_CC_EQ  :   Nibble := CC_EQ; -- Format VIII condition code
constant F4_CC_NE  :   Nibble := CC_NE; -- Format VIII condition code
constant F4_CC_GE  :   Nibble := CC_GE; -- Format VIII condition code
constant F4_CC_LE  :   Nibble := CC_LE; -- Format VIII condition code
constant F4_CC_GT  :   Nibble := CC_GT; -- Format VIII condition code
constant F4_CC_LW  :   Nibble := CC_LW; -- Format VIII condition code
constant F4_CC_AE  :   Nibble := CC_AE; -- Format VIII condition code
constant F4_CC_BE  :   Nibble := CC_BE; -- Format VIII condition code
constant F4_CC_AB  :   Nibble := CC_AB; -- Format VIII condition code
constant F4_CC_BL  :   Nibble := CC_BL; -- Format VIII condition code

constant F4_MODE_IMMEDIATE:            Triad := MODE_IMMEDIATE;
constant F4_MODE_INDIRECT:             Triad := MODE_INDIRECT;
constant F4_MODE_INDIRECT_POST_INC:       Triad := MODE_INDIRECT_POST_INC;
constant F4_MODE_INDIRECT_PRE_DEC:        Triad := MODE_INDIRECT_PRE_DEC;
constant F4_MODE_DIRECT:               Triad := MODE_DIRECT;
constant F4_MODE_INDEXED:              Triad := MODE_INDEXED;
constant F4_MODE_INDIRECT_PRE_INDEXED: Triad := MODE_INDIRECT_PRE_INDEXED;


--FORMAT V CONSTANTS

constant F5_MASK  :   DByte  := "1111100010000000"; -- Format V mask
constant F5_MARK  :   DByte  := "0000100000000000"; -- Format V mark

constant F5_OP1_JPA : Triad  := "000"; -- JumP Absolute
constant F5_OP1_JEA : Triad  := "001"; -- Jump to Effective Address
constant F5_OP1_JSR : Triad  := "010"; -- Jump to Subroutine
constant F5_OP1_TRP : Triad  := "011"; -- TRaP
constant F5_OP1_TST : Triad  := "100"; -- TeST
constant F5_OP1_TSR : Triad  := "101"; -- TeSt and Reset
constant F5_OP1_MSR : Triad  := "110"; -- Move Status Register
constant F5_OP1_MPC : Triad  := "111"; -- Move Program Counter

constant F5_MODE_INDIRECT:             Triad := MODE_INDIRECT;
constant F5_MODE_INDIRECT_POST_INC:    Triad := MODE_INDIRECT_POST_INC;
constant F5_MODE_INDIRECT_PRE_DEC:     Triad := MODE_INDIRECT_PRE_DEC;
constant F5_MODE_DIRECT:               Triad := MODE_DIRECT;
constant F5_MODE_INDEXED:              Triad := MODE_INDEXED;
constant F5_MODE_INDIRECT_PRE_INDEXED: Triad := MODE_INDIRECT_PRE_INDEXED;


--FORMAT VI CONSTANTS

constant F6_MASK  :   DByte  := "1111100011111111"; -- Format VI mask
constant F6_MARK  :   DByte  := "0000000000000000"; -- Format VI mark

constant F6_OP0_NOP : Triad  := "000"; -- No OPeration
constant F6_OP0_HLT : Triad  := "001"; -- HaLT
constant F6_OP0_RTS : Triad  := "010"; -- ReTurn from Subroutine
constant F6_OP0_RTI : Triad  := "011"; -- ReTurn from Interrupt
constant F6_OP0_CLC : Triad  := "100"; -- CLear Carry
constant F6_OP0_STC : Triad  := "101"; -- SeT Carry
constant F6_OP0_DSI : Triad  := "110"; -- DiSable Interrupt
constant F6_OP0_ENI : Triad  := "111"; -- ENable Interrupt


--FORMAT VII

constant F7_MASK  :   DByte  := "1110000000000000"; -- Format VII mask
constant F7_MARK  :   DByte  := "0010000000000000"; -- Format VII mark

constant F7_OPQ_LDQ : Wire   := '0'; -- LoaD Quick
constant F7_OPQ_ADQ : Wire   := '1'; -- ADd Quick


--FORMAT VIII

constant F8_MASK   :   DByte  := "1111000000000000"; -- Format VIII mask
constant F8_MARK   :   DByte  := "0001000000000000"; -- Format VIII mark

constant F8_CC_NB  :   Nibble := CC_NV;
constant F8_CC_BR  :   Nibble := CC_AL; 
constant F8_CC_EQ  :   Nibble := CC_EQ; 
constant F8_CC_NE  :   Nibble := CC_NE; 
constant F8_CC_GE  :   Nibble := CC_GE; 
constant F8_CC_LE  :   Nibble := CC_LE; 
constant F8_CC_GT  :   Nibble := CC_GT; 
constant F8_CC_LW  :   Nibble := CC_LW; 
constant F8_CC_AE  :   Nibble := CC_AE; 
constant F8_CC_BE  :   Nibble := CC_BE; 
constant F8_CC_AB  :   Nibble := CC_AB; 
constant F8_CC_BL  :   Nibble := CC_BL;
 
constant F8_CC_VS  :   Nibble := CC_VS;
constant F8_CC_VC  :   Nibble := CC_VC; 
constant F8_CC_NS  :   Nibble := CC_NS;
constant F8_CC_NC  :   Nibble := CC_NC;

end package;
