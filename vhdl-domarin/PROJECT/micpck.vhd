-- (C) Alexandre Parodi - 2001-Mars 2007

-- file micpck.vhd

library ieee;                	
use ieee.std_logic_1164.all;
use work.basic_pack.all;

---------------------------------------------------
-- MIC_PACK PACKAGE DEFINITION for 16 bits RISC CPU
---------------------------------------------------

-- This package contains the definition of:

--    * ALPHA constant (register selector size)

--    * Selector_Type type

--    * Micro Instruction Code type;

--    * Micro Instruction Code fields values;

--    * Micro Instruction Code default values: MIC_ERROR and MIC_NOCARE.


package MIC_PACK is

--------------------------
-- Register Selectors
--------------------------

constant ALPHA: Integer := 2; -- Selector size from 1 to 4
subtype Selector_Type is Std_logic_Vector(alpha-1 downto 0);


----------------
-- Mic_Type
----------------

type Mic_Type is record

-- ALSU related commands:
    alsu_op:  Pentad;-- OPeration           (ADD, ADC, SUB, NEG, AND, OR, XOR, NOT, PSB, LDB, STB, SWB, SRL, SRA, RRC, RLB, EXT)
    alsu_ais: Pair;  -- A Input Select      (ALSU input A may be PC, OA, ZERO, SR)
    alsu_bis: Pair;  -- B Input Select      (ALSU input B may be OB, DBUS, QV, UV)
    alsu_uvc: Pair;  -- Micro Value Code    (0, 1, 2, 3)

-- Register File:
    rf_oas:   Selector_Type;  -- A Output Select  (register content to appear at OA)
    rf_obs:   Selector_Type;  -- B Output Select  (register content to appear at OB)
    rf_ins:   Selector_Type;  -- Input Select     (register to load)
    rf_l:     Wire;           -- Load             (=1 to load one register)

-- Address BUS:	
    abus_s:   Wire;  -- mux Select command;       (PC, OA ou OB selon architecture)

-- Control BUS:
    cbus_typ: Wire;  -- TYPe         (=1 when data is a Byte)
    cbus_wrt: Wire;  -- WRiTe        (=1 when CPU writes to memory or IO)
    cbus_str: Wire;  -- STRobe       (=1 when data bus is used)
    
-- CONTROL:
    sr_l:       Wire;   -- Status Register Load command
    pc_i:       Wire;   -- Program Counter Increment command
    bc_cc:      Nibble; -- Branch Controller Condition Code
    ir_l:       Wire;   -- Instruction Register Load command
    msg:        Pair;   -- MeSsaGe
    next_cycle: Triad;  -- next cycle

end record;



----------------------------
-- MIC fields constants
----------------------------

--ALSU OPeration command values:
constant ALSU_OP_NOCARE: Pentad := "-----"; -- when ALSU is not used
--2 operands operations :
constant ALSU_OP_ADD: Pentad := "00110"; -- ADD                         R = A # B
constant ALSU_OP_ADC: Pentad := "00000"; -- ADd with Carry              R = A # B # CF
constant ALSU_OP_SUB: Pentad := "00111"; -- SUBstract                   R = A # /B # 1
constant ALSU_OP_XOR: Pentad := "00001"; -- eXclusive OR                R = A xor B
constant ALSU_OP_AND: Pentad := "00100"; -- AND                         R = A . B
constant ALSU_OP_OR:  Pentad := "00101"; -- OR                          R = A + B
--1 operand operations :
constant ALSU_OP_NEG: Pentad := "10111"; -- NEGate                      R = /B # 1 
constant ALSU_OP_NOT: Pentad := "10100"; -- NOT                         R = /B
constant ALSU_OP_SRL: Pentad := "10010"; -- Shift Right Logical         R = B >> 1
constant ALSU_OP_SRA: Pentad := "10011"; -- Shift Right Arithmetic      R = B / 2
constant ALSU_OP_RRC: Pentad := "10001"; -- Rotate Right through Carry  R = B >> 1 + 2**N . CF 
constant ALSU_OP_SWP: Pentad := "11010"; -- Swap half words             R = swap(B)
constant ALSU_OP_EXT: Pentad := "11101"; -- EXTend right byte sign      R = extend(B)
constant ALSU_OP_RLB: Pentad := "11011"; -- Rotate Left Barrel          R = rlb(B)
--transfer operations :
constant ALSU_OP_PSB: Pentad := "01100"; -- Pass B                      R = B
constant ALSU_OP_LDB: Pentad := "01011"; -- LoaD Byte                   R =
constant ALSU_OP_STB: Pentad := "01010"; -- STore Byte                  R =

--ALSU A Input Select command values:
constant ALSU_AIS_PC:     Pair  := "00"; -- A = Progam Counter
constant ALSU_AIS_OA:     Pair  := "01"; -- A = registers Output A
constant ALSU_AIS_ZERO:   Pair  := "10"; -- A = zero
constant ALSU_AIS_SR:     Pair  := "11"; -- A = SR
constant ALSU_AIS_NOCARE: Pair  := "--"; -- does not care about A input value

--ALSU B Input Select command values:
constant ALSU_BIS_OB:     Pair  := "00"; -- B = registers Output B
constant ALSU_BIS_DBUS:   Pair  := "01"; -- B = Data BUS value
constant ALSU_BIS_QV:     Pair  := "10"; -- B = Quick Value
constant ALSU_BIS_UV:     Pair  := "11"; -- B = Micro Value
constant ALSU_BIS_NOCARE: Pair  := "--"; -- does not care about B input

--ALSU Micro Value Codes:
constant ALSU_UVC_0:      Pair := "00"; -- 0
constant ALSU_UVC_1:      Pair := "01"; -- 1
constant ALSU_UVC_2:      Pair := "10"; -- 2
constant ALSU_UVC_3:      Pair := "11"; -- 3
constant ALSU_UVC_NOCARE: Pair := "--"; -- does not care about UVC


-- Register File output A and destination Selector command values:
constant RF_OAS_NOCARE:  Selector_type := (others => '-');
constant RF_OAS_R0:      Selector_Type := (others => '0');               -- R0
constant RF_OAS_R1:      Selector_Type := (0=>'1', others=>'0');         -- R1
constant RF_OAS_R2:      Selector_Type := (1=>'1', others=>'0');         -- R2
constant RF_OAS_R3:      Selector_Type := (1=>'1', 0=>'1', others=>'0'); -- R3
constant RF_OAS_SP:      Selector_Type := (others=>'1'); -- Stack Pointer (last reg)

-- Register File Output B register Selector command values:
constant RF_OBS_NOCARE:  Selector_Type := (others => '-');
constant RF_OBS_R0:      Selector_Type := (others => '0');              -- R0
constant RF_OBS_R1:      Selector_Type := (0=>'1', others=>'0');        -- R1
constant RF_OBS_R2:      Selector_Type := (1=>'1', others=>'0');        -- R2
constant RF_OBS_R3:      Selector_Type := (1=>'1', 0=>'1', others=>'0');-- R3
constant RF_OBS_SP:      Selector_Type := (others=>'1'); -- Stack Pointer (last reg)

-- Register File Input register Selector command values:
constant RF_INS_NOCARE:  Selector_Type := (others => '-');
constant RF_INS_R0:      Selector_Type := (others => '0');              -- R0
constant RF_INS_R1:      Selector_Type := (0=>'1', others=>'0');        -- R1
constant RF_INS_R2:      Selector_Type := (1=>'1', others=>'0');        -- R2
constant RF_INS_R3:      Selector_Type := (1=>'1', 0=>'1', others=>'0');-- R3
constant RF_INS_SP:      Selector_Type := (others=>'1'); -- Stack Pointer (last reg)

-- Register File Load command values:
constant RF_L_HOLD: Wire := '0'; -- hold registers values
constant RF_L_LOAD: Wire := '1'; -- load one register

-- Address Bus Select command values:
constant ABUS_S_PC:     Wire := '0'; -- ABUS = PC
constant ABUS_S_OA:     Wire := '1'; -- ABUS = REGisters output A (other version)
constant ABUS_S_OB:     Wire := '1'; -- ABUS = REGisters output B (for general architecture)
constant ABUS_S_NOCARE: Wire := '-'; -- does not care (use only when bus is released!)

-- Control BUS TYPe command values:
constant CBUS_TYP_WORD:   Wire := '0'; -- WORD
constant CBUS_TYP_BYTE:   Wire := '1'; -- HALF WORD
constant CBUS_TYP_NOCARE: Wire := '-'; -- does not care (use only when bus is released!)

-- Control BUS WRiTe command values:
constant CBUS_WRT_READ:   Wire := '0'; -- CPU reads
constant CBUS_WRT_WRITE:  Wire := '1'; -- CPU writes
constant CBUS_WRT_NOCARE: Wire := '-'; -- does not care (use only when bus is released!)

-- Control BUS STRobe command values:
constant CBUS_STR_USE:     Wire := '1'; -- CPU uses DBUS
constant CBUS_STR_RELEASE: Wire := '0'; -- CPU releases DBUS

-- Status Register Load command values:
constant SR_L_HOLD: Wire := '0'; -- no incrementation: if L=0 PC does not change
constant SR_L_LOAD: Wire := '1'; -- increment: PC <- PC + 2

-- Program Counter Increment command values:
constant PC_I_NOINC:  Wire := '0'; -- no incrementation: if L=0 PC does not change
constant PC_I_INC:    Wire := '1'; -- increment: PC <- PC + 2
constant PC_I_NOCARE: Wire := '-'; -- does not care (use only when PC loads!)


--Branch Controller Condition Code values:
constant BC_CC_NV:     Nibble := "0000";  -- no branch, i.e. PC IS NeVer loaded (PC_L=0)
constant BC_CC_AL:     Nibble := "0001";  -- branch always, i.e. PC IS ALways loaded (PC_L=1)
constant BC_CC_EQ:     Nibble := "0010";  -- if result is EQual to 0
constant BC_CC_NE:     Nibble := "0011";  -- if result is Not Equal to 0
constant BC_CC_GE:     Nibble := "0100";  -- if signed result is Greater or Equal to 0
constant BC_CC_LE:     Nibble := "0101";  -- if signed result is Lower or Equal to 0
constant BC_CC_GT:     Nibble := "0110";  -- if signed result is strictly GreaTer than 0
constant BC_CC_LW:     Nibble := "0111";  -- if signed result is strictly LoWer than 0
constant BC_CC_AE:     Nibble := "1000";  -- if unsigned result is Above or Equal to 0
constant BC_CC_BE:     Nibble := "1001";  -- if unsigned result is Below or Equal to 0
constant BC_CC_AB:     Nibble := "1010";  -- if unsigned result is ABove 0
constant BC_CC_BL:     Nibble := "1011";  -- if unsigned result is BeLow 0
constant BC_CC_VS:     Nibble := "1100";  -- if V flag Set
constant BC_CC_VC:     Nibble := "1101";  -- if V flag Cleared
constant BC_CC_NS:     Nibble := "1110";  -- if N flag Set
constant BC_CC_NC:     Nibble := "1111";  -- if N flag Cleared


-- Instruction Register Load command values:
constant IR_L_HOLD: Wire := '0'; -- hold current instruction code
constant IR_L_LOAD: Wire := '1'; -- load instruction code


-- MeSsaGe values:
constant MSG_OK:                  Pair := "00"; -- Decoder works fine
constant MSG_ILLEGAL_INSTRUCTION: Pair := "01"; -- Decoder detected an illegal instruction


-- Next Cycle command values:
constant NEXT_CYCLE_RESET:  Triad := "000"; -- back to cycle #0
constant NEXT_CYCLE_NOCARE: Triad := "---"; -- no care
constant CYCLE_0:      Triad := o"0";  -- go to cycle 0
constant CYCLE_1:      Triad := o"1";  -- go to cycle 1
constant CYCLE_2:      Triad := o"2";  -- go to cycle 2
constant CYCLE_3:      Triad := o"3";  -- go to cycle 3
constant CYCLE_4:      Triad := o"4";  -- go to cycle 4
constant CYCLE_5:      Triad := o"5";  -- go to cycle 5
constant CYCLE_6:      Triad := o"6";  -- go to cycle 6
constant CYCLE_7:      Triad := o"7";  -- go to cycle 7


---------------------------------------
-- SPECIAL MIC VALUES
---------------------------------------


-- MIC ERROR value: it commands an ERROR notice, i.e.:
--    o it sends an "illegal instruction" error code to the message field
--    o it keeps the same PC value, (the program then stays idle);
--    o resets the cycle, (the micro-program stays idle);
--    o keeps the SR;
--    o keeps all the registers, (to debug);
--    o puts PC onto ABUS (to get the error location);
--    o disconnects DBUS from both CPU and MCU;

-- the following constant is used only for illegal instruction code values

-- SUPPRESSED IN 2010-2011 VERSION:
-- now signals in idl0.vhd
-- because assigning fields at the constant declaration causes trouble to Galaxy
constant MIC_ERROR: Mic_Type := (
    alsu_op    => ALSU_OP_NOCARE,
    alsu_ais   => ALSU_AIS_NOCARE,
    alsu_bis   => ALSU_BIS_NOCARE,
    alsu_uvc   => ALSU_UVC_NOCARE,

    rf_oas     => RF_OAS_NOCARE,
    rf_obs     => RF_OBS_NOCARE,
    rf_ins     => RF_INS_NOCARE,
    rf_l       => RF_L_HOLD,	
    
    abus_s     => ABUS_S_PC,        -- puts PC onto ABUS

    cbus_typ   => CBUS_TYP_WORD,
    cbus_wrt   => CBUS_WRT_READ,    -- DBUS is not connected at MCU side
    cbus_str   => CBUS_STR_RELEASE, -- DBUS is not connected at CPU side

    sr_l       => SR_L_HOLD,
    pc_i       => PC_I_NOINC,
    bc_cc      => BC_CC_NV,
    ir_l       => IR_L_HOLD,
    msg        => MSG_ILLEGAL_INSTRUCTION, -- we assume the error results from an illegal instruction      
    next_cycle => NEXT_CYCLE_RESET);


-- the following constant is only used to assign mic 
-- for cases that *cannot* happen even with wrong instruction codes.

constant MIC_NOCARE: Mic_Type := (
    alsu_op  => ALSU_OP_NOCARE,
    alsu_ais => ALSU_AIS_NOCARE,
    alsu_bis => ALSU_BIS_NOCARE,
    alsu_uvc => ALSU_UVC_NOCARE,

    rf_oas   => RF_OAS_NOCARE,
    rf_obs   => RF_OBS_NOCARE,
    rf_ins   => RF_INS_NOCARE,
    rf_l     => '-',	
    
    abus_s   => '-',  

    cbus_typ => '-',
    cbus_wrt => '-', 
    cbus_str => '-',

    sr_l     => '-',
    pc_i     => '-',
    bc_cc    => "----",
    ir_l     => '-',
    msg      => "--",   
    next_cycle => NEXT_CYCLE_NOCARE);

end package;