-- VHDL - (C) Alexandre Parodi - 2001 - Novembre 2006
-- Auteur : J�r�my Domarin & Youssef Benfaida
-- Fichier idl1.vhd

library ieee;
use ieee.std_logic_1164.all;

use work.basic_pack.all; 									-- use the BASIC_PACK package from the WORK (default) library
use work.mic_pack.all;   									-- use the MIC_PACK package from the WORK (default) library
use work.idl_pack.all;   									-- use the IDL_PACK package from the WORK (default) library

entity INSTRUCTION_DECODER_LOGIC is
    port (
        ic:    in     DByte;    							-- code d'instruction
        cycle: in     Triad;    							-- micro-instruction step (i.e. n� cycle dans l'instruction)
		mic:   buffer Mic_Type  							-- code de micro-instruction
	);
attribute SUM_SPLIT of mic: signal is CASCADED; 			-- saves one cell if number of products > 16
end entity;

architecture idl_arc of INSTRUCTION_DECODER_LOGIC is


------------------------- D�claration des alias de champs d'instructions pour chaque groupe de format ----------------------

-- Format I 
alias f1_tag:  Wire          is ic(15);
alias f1_op3:  Triad         is ic(14 downto 12);       	-- OPeration 3 op�randes
alias f1_crsa: Selector_Type is ic(ALPHA-1+8 downto 8); 	-- Registre Source A
alias f1_crsb: Selector_Type is ic(ALPHA-1+4 downto 4); 	-- Registre Source B
alias f1_crd:  Selector_Type is ic(ALPHA-1 downto 0);   	-- Registre Destination

-- Format II 
alias f2_op2:  Nibble        is ic(11 downto 8);        	-- Operation 2 op�randes
alias f2_tag:  Nibble        is ic(15 downto 12);
alias f2_crs:  Selector_Type is ic(ALPHA-1+4 downto 4); 	-- Registre Source
alias f2_crd:  Selector_Type is ic(ALPHA-1 downto 0);   	-- Registre destination

-- Format III
alias f3_tag:   Pair          is ic(15 downto 14);         	-- tag
alias f3_type:  Pair          is ic(13 downto 12);         	-- type operande
alias f3_d:     Wire          is ic(7);                    	-- direction
alias f3_cra:   Selector_Type is ic(ALPHA-1+8 downto 0+8); 	-- registre A
alias f3_mode:  Triad         is ic(6 downto 4);           	-- mode d'adressage
alias f3_crb:   Selector_Type is ic(ALPHA-1 downto 0);     	-- registre B

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
                                 
---------------------------------------------------------------------------------------------------------------------------
-- FORMAT DETECTOR: D�TERMINATION DU FORMAT
---------------------------------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------------------------------
-- MIC GENERATOR: construction de la micro-instruction
--------------------------------------------------------------------------------------------------------------------------
--

mic_gen_proc: process (fc, cycle, ic,
    f1_op3, f1_crsa, f1_crsb, f1_crd, f2_op2, f2_crs, f2_crd, 
    f3_mode, f3_d, f3_type, f3_cra, f3_crb,
    f4_cc, f4_mode, f4_cr, f5_op1, f5_mode, f5_cr, 
    f6_op0, f7_opq, f7_cr, f7_qvc, f8_cc, f8_disp)      -- processus "combinatoire" d�clench�
                                           -- si l'une des entr�es change;
variable micv: Mic_Type := MIC_ERROR;      -- code de microinstruction en construction

begin

------------------------------------ Instructions du groupe 1 --------------------------------------------------------------

if (fc = F1_CODE) then 										-- l'instruction est du groupe de format 1
	if (f1_op3 /= F1_OP3_MUL and f1_op3 /= F1_op3_DIV) then		-- l'op�ration est r�alis�e avec l'ALSU
		micv.alsu_op	:= "00" & f1_op3;					-- P= concat�nation de 00 et du champ op3 de l'instruction ic
		micv.alsu_ais	:= ALSU_AIS_OA;						-- l'entr�e A de l'ALSU re�oit la sortie OA du bloc de reg RF		
		micv.alsu_bis	:= ALSU_BIS_OB;						-- l'entr�e B de l'ALSU re�oit la sortie OB du bloc de reg RF
		micv.alsu_uvc	:= ALSU_UVC_NOCARE;					-- UVC sans importance car non utilis�: = --
		micv.rf_oas     := f1_crsa     ; 					-- OA=contenu du registre indiqu� par le champ crsa=i, R0  R1  R2  R3  SP  NOCARE
        micv.rf_obs     := f1_crsb     ; 					-- OB=contenu du registre indiqu� par le champ crsb=j, R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := f1_crd      ; 					-- Registre destination de RF indiqu� par crd=k, R0  R1  R2  R3  SP  NOCARE
        micv.rf_l       := RF_L_LOAD   ; 					-- On charge le registre destination de RF, HOLD  LOAD
        micv.abus_s     := ABUS_S_PC   ; 					-- On envoie PC sur le bus d'adresse ABUS, PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				-- On transf�re une instruction donc un mot, WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				-- On lit l'instruction suivante dans la m�moire, READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE    ; 				-- On utilise le bus pour le transfert de cette instruction, RELEASE   USE
        micv.sr_l       := SR_L_LOAD       ; 				-- On charge les nouveaux indicateurs dans SR, HOLD   LOAD
        micv.pc_i       := PC_I_INC        ; 				-- On incr�mente le PC, NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV        ; 				-- Ne charge jamais PC klk soit indicateurs =>pc_l=br=0=>CC=0=NV, NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_l       := IR_L_LOAD       ; 				-- On charge IR avec l'instruction suivante, HOLD   LOAD
        micv.msg        := MSG_OK          ; 				-- Pas de probl�me, OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0	       ; 				-- Prochain cycle=0, NOCARE  0 1 2 3 4 5 6 7
	 else													-- Op�ration non ex�cutable("illegal instruction")
	 	micv	:= MIC_ERROR;								-- On pr�vient de l'erreur avec MIC_ERROR dont msg=1
   end if;

------------------------------------ Instructions du groupe 2 --------------------------------------------------------------

elsif (fc = F2_CODE) then								-- l'instruction est du groupe de format 2
	if(f2_op2=F2_OP2_NOT or f2_op2=F2_OP2_NEG or f2_op2=F2_OP2_SRL or f2_op2=F2_OP2_SRA or f2_op2=F2_OP2_RRC or f2_op2=F2_OP2_RLB or f2_op2=F2_OP2_SWB or f2_op2=F2_OP2_EXT) then
		micv.alsu_op    := "1" & f2_op2    ; 				-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        micv.alsu_ais   := ALSU_AIS_OA   ; 					-- PC  OA  SR ZERO NOCARE
        micv.alsu_bis   := ALSU_BIS_OB   ; 					-- OB  DBUS  QV  UV  NOCARE
        micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				-- 0  1  2  3  NOCARE
        micv.rf_oas     := f2_crs     ; 					-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_obs     := RF_OBS_NOCARE     ; 					-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := f2_crd     ; 				-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_l       := RF_L_LOAD       ; 				-- HOLD  LOAD
        micv.abus_s     := ABUS_S_PC     ; 					-- PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				-- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				-- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE   ; 				-- RELEASE   USE
        micv.sr_l       := SR_L_LOAD       ; 				-- HOLD   LOAD
        micv.pc_i       := PC_I_INC       ; 				-- NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV      ; 					-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_l       := IR_L_LOAD       ; 				-- HOLD   LOAD
        micv.msg        := MSG_OK        ; 					-- OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0      ;					-- NOCARE  0 1 2 3 4 5 6 7
	else
		micv := MIC_ERROR; 									-- on pr�vient de l'erreur avec MIC_ERROR dont .msg=1
	end if;

------------------------------------ Instructions du groupe 3 --------------------------------------------------------------

elsif (fc = F3_CODE) then 									-- l'instruction est une op�ration du groupe 3
	if f3_d = F3_D_LD then									-- LDW Rk, Rj
		if f3_mode = F3_MODE_REGISTER then					-- mode registre
			micv.alsu_op    := ALSU_OP_PSB    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        	micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        	micv.alsu_bis   := ALSU_BIS_OB   ; 				-- OB  DBUS  QV  UV  NOCARE
        	micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        	micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        	micv.rf_obs     := f3_crb    ; 					-- R0  R1  R2  R3  SP  NOCARE
        	micv.rf_ins     := f3_cra     ; 				-- R0  R1  R2  R3  SP  NOCARE
        	micv.rf_l       := RF_L_LOAD       ; 			-- HOLD  LOAD
        	micv.abus_s     := ABUS_S_PC     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        	micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        	micv.cbus_wrt   := CBUS_WRT_READ   ; 			-- READ    WRITE    NOCARE
        	micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        	micv.sr_l       := SR_L_LOAD       ; 			-- HOLD   LOAD
        	micv.pc_i       := PC_I_INC       ; 			-- NOINC  INC   NOCARE
        	micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        	micv.ir_l       := IR_L_LOAD       ; 			-- HOLD   LOAD
        	micv.msg        := MSG_OK        ; 				-- OK   ILLEGAL_INSTRUCTION
        	micv.next_cycle := CYCLE_0      ; 				-- NOCARE  0 1 2 3 4 5 6 7
		elsif f3_mode = F3_MODE_INDIRECT then				-- mode indirect en 2 cycles
			if cycle = CYCLE_0 then						-- cycle 0
				micv.alsu_op    := ALSU_OP_PSB    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        		micv.alsu_bis   := ALSU_BIS_OB   ; 				-- OB  DBUS  QV  UV  NOCARE
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_obs     := f3_crb    ; 					-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_ins     := f3_cra     ; 				-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_l       := RF_L_LOAD       ; 			-- HOLD  LOAD
        		micv.abus_s     := ABUS_S_OB     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			-- READ    WRITE    NOCARE
        		micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        		micv.sr_l       := SR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.pc_i       := PC_I_NOINC       ; 			-- NOINC  INC   NOCARE
        		micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        		micv.ir_l       := IR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.msg        := MSG_OK        ; 				-- OK   ILLEGAL_INSTRUCTION
        		micv.next_cycle := CYCLE_1      ; 				-- incr�mente le num�ro de cycle
			elsif cycle = CYCLE_1 then		--cycle 1
				micv.alsu_op    := ALSU_OP_PSB    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        		micv.alsu_bis   := ALSU_BIS_DBUS   ; 				-- OB  DBUS  QV  UV  NOCARE
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_obs     := RF_OBS_NOCARE    ; 					-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_ins     := RF_INS_NOCARE     ; 				-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_l       := RF_L_HOLD       ; 			-- HOLD  LOAD
        		micv.abus_s     := ABUS_S_PC     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			-- READ    WRITE    NOCARE
        		micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        		micv.sr_l       := SR_L_HOLD       ; 			-- HOLD   LOAD
        		micv.pc_i       := PC_I_INC       ; 			-- NOINC  INC   NOCARE
        		micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        		micv.ir_l       := IR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.msg        := MSG_OK        ; 				-- OK   ILLEGAL_INSTRUCTION
        		micv.next_cycle := CYCLE_0      ; 				-- NOCARE  0 1 2 3 4 5 6 7
			else		-- ni cycle 0 ni cycle 1
				micv.alsu_op    := ALSU_OP_NOCARE    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        		micv.alsu_bis   := ALSU_BIS_NOCARE   ; 				-- OB  DBUS  QV  UV  NOCARE
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_obs     := RF_OBS_NOCARE    ; 					-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_ins     := RF_INS_NOCARE     ; 				-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_l       := RF_L_LOAD       ; 			-- HOLD  LOAD
        		micv.abus_s     := ABUS_S_PC     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			-- READ    WRITE    NOCARE
        		micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        		micv.sr_l       := SR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.pc_i       := PC_I_NOCARE       ; 			-- NOINC  INC   NOCARE
        		micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        		micv.ir_l       := IR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.msg        := MSG_ILLEGAL_INSTRUCTION        ; 	-- OK   ILLEGAL_INSTRUCTION
        		micv.next_cycle := NEXT_CYCLE_NOCARE      ; 				-- NOCARE  0 1 2 3 4 5 6 7
			end if;
		elsif f3_mode = F3_MODE_IMMEDIATE then				-- mode imm�diat en 2 cycles
			if cycle = CYCLE_0 then	--cycle 0
				micv.alsu_op    := ALSU_OP_PSB    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        		micv.alsu_bis   := ALSU_BIS_DBUS  ; 				-- OB  DBUS  QV  UV  NOCARE
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_obs     := RF_OBS_NOCARE    ; 					-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_ins     := f3_cra     ; 				-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_l       := RF_L_LOAD       ; 			-- HOLD  LOAD
        		micv.abus_s     := ABUS_S_PC     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			-- READ    WRITE    NOCARE
        		micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        		micv.sr_l       := SR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.pc_i       := PC_I_INC     ; 			-- NOINC  INC   NOCARE
        		micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        		micv.ir_l       := IR_L_HOLD       ; 			-- HOLD   LOAD
        		micv.msg        := MSG_OK        ; 				-- OK   ILLEGAL_INSTRUCTION
        		micv.next_cycle := CYCLE_1      ; 				-- NOCARE  0 1 2 3 4 5 6 7
			elsif cycle = CYCLE_1 then		--cycle 1
				micv.alsu_op    := ALSU_OP_PSB    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        		micv.alsu_bis   := ALSU_BIS_DBUS   ; 				-- OB  DBUS  QV  UV  NOCARE
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_obs     := RF_OBS_NOCARE    ; 					-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_ins     := RF_INS_NOCARE     ; 				-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_l       := RF_L_HOLD       ; 			-- HOLD  LOAD
        		micv.abus_s     := ABUS_S_PC     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			-- READ    WRITE    NOCARE
        		micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        		micv.sr_l       := SR_L_HOLD       ; 			-- HOLD   LOAD
        		micv.pc_i       := PC_I_INC       ; 			-- NOINC  INC   NOCARE
        		micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        		micv.ir_l       := IR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.msg        := MSG_OK        ; 				-- OK   ILLEGAL_INSTRUCTION
        		micv.next_cycle := CYCLE_0      ; 				-- NOCARE  0 1 2 3 4 5 6 7
			else			-- ni cycle 0 ni cycle 1
				micv.alsu_op    := ALSU_OP_NOCARE    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        		micv.alsu_bis   := ALSU_BIS_NOCARE   ; 				-- OB  DBUS  QV  UV  NOCARE
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_obs     := RF_OBS_NOCARE    ; 					-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_ins     := RF_INS_NOCARE     ; 				-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_l       := RF_L_LOAD       ; 			-- HOLD  LOAD
        		micv.abus_s     := ABUS_S_PC     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			-- READ    WRITE    NOCARE
        		micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        		micv.sr_l       := SR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.pc_i       := PC_I_NOCARE       ; 			-- NOINC  INC   NOCARE
        		micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        		micv.ir_l       := IR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.msg        := MSG_ILLEGAL_INSTRUCTION        ; 				-- OK   ILLEGAL_INSTRUCTION
        		micv.next_cycle := NEXT_CYCLE_NOCARE      ; 				-- NOCARE  0 1 2 3 4 5 6 7
			end if;
		else
			micv := MIC_ERROR; 								-- on pr�vient de l'erreur avec MIC_ERROR dont .msg=1
		end if;
	elsif f3_d = F3_D_ST then								-- STW Rk, (Rj)
		if f3_mode = F3_MODE_INDIRECT then					-- mode indirect en 2 cycles
			if cycle = CYCLE_0 then						-- cycle 0
				micv.alsu_op    := ALSU_OP_PSB    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        		micv.alsu_bis   := ALSU_BIS_OB   ; 				-- OB  DBUS  QV  UV  NOCARE
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_obs     := f3_crb    ; 					-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_ins     := f3_cra     ; 				-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_l       := RF_L_LOAD       ; 			-- HOLD  LOAD
        		micv.abus_s     := ABUS_S_OB     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        		micv.cbus_wrt   := CBUS_WRT_WRITE   ; 			-- READ    WRITE    NOCARE
        		micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        		micv.sr_l       := SR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.pc_i       := PC_I_NOINC       ; 			-- NOINC  INC   NOCARE
        		micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        		micv.ir_l       := IR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.msg        := MSG_OK        ; 				-- OK   ILLEGAL_INSTRUCTION
        		micv.next_cycle := CYCLE_1      ; 				-- NOCARE  0 1 2 3 4 5 6 7
			elsif cycle = CYCLE_1 then					-- cycle 1
				micv.alsu_op    := ALSU_OP_PSB    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        		micv.alsu_bis   := ALSU_BIS_DBUS   ; 				-- OB  DBUS  QV  UV  NOCARE
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_obs     := f3_crb    ; 					-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_ins     := f3_cra     ; 				-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_l       := RF_L_HOLD       ; 			-- HOLD  LOAD
        		micv.abus_s     := ABUS_S_PC     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        		micv.cbus_wrt   := CBUS_WRT_WRITE   ; 			-- READ    WRITE    NOCARE
        		micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        		micv.sr_l       := SR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.pc_i       := PC_I_INC       ; 			-- NOINC  INC   NOCARE
        		micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        		micv.ir_l       := IR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.msg        := MSG_OK        ; 				-- OK   ILLEGAL_INSTRUCTION
        		micv.next_cycle := CYCLE_0      ; 				-- NOCARE  0 1 2 3 4 5 6 7
			else			-- ni cycle 0 ni cycle 1
				micv.alsu_op    := ALSU_OP_NOCARE    ; 			-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			-- PC  OA  SR ZERO NOCARE
        		micv.alsu_bis   := ALSU_BIS_NOCARE   ; 				-- OB  DBUS  QV  UV  NOCARE
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			-- 0  1  2  3  NOCARE
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_obs     := RF_OBS_NOCARE    ; 					-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_ins     := RF_INS_NOCARE     ; 				-- R0  R1  R2  R3  SP  NOCARE
        		micv.rf_l       := RF_L_LOAD       ; 			-- HOLD  LOAD
        		micv.abus_s     := ABUS_S_PC     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			-- WORD  BYTE   NOCARE
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			-- READ    WRITE    NOCARE
        		micv.cbus_str   := CBUS_STR_USE   ; 			-- RELEASE   USE
        		micv.sr_l       := SR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.pc_i       := PC_I_NOCARE       ; 			-- NOINC  INC   NOCARE
        		micv.bc_cc      := BC_CC_NV      ; 				-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        		micv.ir_l       := IR_L_LOAD       ; 			-- HOLD   LOAD
        		micv.msg        := MSG_ILLEGAL_INSTRUCTION        ; 				-- OK   ILLEGAL_INSTRUCTION
        		micv.next_cycle := NEXT_CYCLE_NOCARE      ; 				-- NOCARE  0 1 2 3 4 5 6 7
			end if;
		else
			micv := MIC_ERROR; 								-- on pr�vient de l'erreur avec MIC_ERROR dont .msg=1
		end if;
	 else
			micv := MIC_ERROR; 								-- on pr�vient de l'erreur avec MIC_ERROR dont .msg=1
	 end if;

------------------------------------ Instructions du groupe 5 --------------------------------------------------------------

elsif (fc = F5_CODE) then									-- l'instruction est du groupe de format 5
	if f5_mode = F5_MODE_INDIRECT then						-- mode indirect
		if(f5_op1 = F5_OP1_JEA) then						-- jump at effective address
			micv.alsu_op    := ALSU_OP_PSB    ; 				-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        	micv.alsu_ais   := ALSU_AIS_NOCARE   ; 				-- PC  OA  SR ZERO NOCARE
        	micv.alsu_bis   := ALSU_BIS_OB   ; 					-- OB  DBUS  QV  UV  NOCARE
        	micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				-- 0  1  2  3  NOCARE
        	micv.rf_oas     := RF_OAS_NOCARE    ; 				-- R0  R1  R2  R3  SP  NOCARE
        	micv.rf_obs     := f5_cr    ; 				-- R0  R1  R2  R3  SP  NOCARE
        	micv.rf_ins     := RF_INS_NOCARE     ; 						-- R0  R1  R2  R3  SP  NOCARE
        	micv.rf_l       := RF_L_HOLD       ; 				-- HOLD  LOAD
        	micv.abus_s     := ABUS_S_PC     ; 					-- PC    OA (or OB depending on architecture) NOCARE
        	micv.cbus_typ   := CBUS_TYP_WORD   ; 				-- WORD  BYTE   NOCARE
        	micv.cbus_wrt   := CBUS_WRT_READ   ; 				-- READ    WRITE    NOCARE
        	micv.cbus_str   := CBUS_STR_USE   ; 				-- RELEASE   USE
        	micv.sr_l       := SR_L_HOLD       ; 				-- HOLD   LOAD
        	micv.pc_i       := PC_I_NOCARE       ; 				-- NOINC  INC   NOCARE
        	micv.bc_cc      := BC_CC_AL      ; 					-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        	micv.ir_l       := IR_L_LOAD       ; 				-- HOLD   LOAD
        	micv.msg        := MSG_OK        ; 					-- OK   ILLEGAL_INSTRUCTION
        	micv.next_cycle := CYCLE_0      ; 					-- NOCARE  0 1 2 3 4 5 6 7
		elsif(f5_op1 = F5_OP1_MPC) then							-- move program counter
	    	micv.alsu_op    := ALSU_OP_OR    ; 					-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        	micv.alsu_ais   := ALSU_AIS_PC   ; 					-- PC  OA  SR ZERO NOCARE
        	micv.alsu_bis   := ALSU_BIS_UV	   ; 					-- OB  DBUS  QV  UV  NOCARE
        	micv.alsu_uvc   := ALSU_UVC_0; 						-- 0  1  2  3  NOCARE
        	micv.rf_oas     := RF_OAS_NOCARE    ; 				-- R0  R1  R2  R3  SP  NOCARE
        	micv.rf_obs     := RF_OBS_NOCARE    ; 				-- R0  R1  R2  R3  SP  NOCARE
        	micv.rf_ins     := f5_cr    ; 						-- R0  R1  R2  R3  SP  NOCARE
        	micv.rf_l       := RF_L_LOAD       ; 				-- HOLD  LOAD
        	micv.abus_s     := ABUS_S_PC     ; 					-- PC    OA (or OB depending on architecture) NOCARE
        	micv.cbus_typ   := CBUS_TYP_WORD   ; 				-- WORD  BYTE   NOCARE
        	micv.cbus_wrt   := CBUS_WRT_READ   ; 				-- READ    WRITE    NOCARE
        	micv.cbus_str   := CBUS_STR_USE   ; 				-- RELEASE   USE
        	micv.sr_l       := SR_L_LOAD      ; 				-- HOLD   LOAD
        	micv.pc_i       := PC_I_INC       ; 				-- NOINC  INC   NOCARE
        	micv.bc_cc      := BC_CC_NV      ; 					-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        	micv.ir_l       := IR_L_LOAD       ; 				-- HOLD   LOAD
        	micv.msg        := MSG_OK        ; 					-- OK   ILLEGAL_INSTRUCTION
        	micv.next_cycle := CYCLE_0      ; 					-- NOCARE  0 1 2 3 4 5 6 7
		else
			micv := MIC_ERROR; 									-- on pr�vient de l'erreur avec MIC_ERROR dont .msg=1
		end if; --f5_op1
	else
			micv := MIC_ERROR; 								-- on pr�vient de l'erreur avec MIC_ERROR dont .msg=1
	end if; --f5_mode
------------------------------------ Instructions du groupe 6 --------------------------------------------------------------

elsif (fc = F6_CODE) then									-- l'instruction est du groupe de format 6
	if(f6_op0 = F6_OP0_NOP) then							-- no operation
	  	micv.alsu_op    := "00" & f6_op0    ; 				-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        micv.alsu_ais   := ALSU_AIS_NOCARE   ; 					-- PC  OA  SR ZERO NOCARE
        micv.alsu_bis   := ALSU_BIS_NOCARE   ; 					-- OB  DBUS  QV  UV  NOCARE
        micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				-- 0  1  2  3  NOCARE
        micv.rf_oas     := RF_OAS_NOCARE     ; 					-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_obs     := RF_OBS_NOCARE     ; 					-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := RF_INS_NOCARE     ; 				-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_l       := RF_L_HOLD       ; 				-- HOLD  LOAD
        micv.abus_s     := ABUS_S_PC     ; 					-- PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				-- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				-- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE   ; 				-- RELEASE   USE
        micv.sr_l       := SR_L_HOLD       ; 				-- HOLD   LOAD
        micv.pc_i       := PC_I_INC       ; 				-- NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV      ; 					-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_l       := IR_L_LOAD       ; 				-- HOLD   LOAD
        micv.msg        := MSG_OK        ; 					-- OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0      ;	 				-- NOCARE  0 1 2 3 4 5 6 7
	  else
		micv := MIC_ERROR; 									-- on pr�vient de l'erreur avec MIC_ERROR dont .msg=1
	  end if;
	
------------------------------------ Instructions du groupe 7 --------------------------------------------------------------

elsif (fc = F7_CODE) then									-- l'instruction est du groupe de format 7
	if(f7_opq = F7_OPQ_LDQ) then							-- LoaD Quick
	  	micv.alsu_op    := ALSU_OP_PSB    ; 				-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        micv.alsu_ais   := ALSU_AIS_NOCARE   ; 					-- PC  OA  SR ZERO NOCARE
        micv.alsu_bis   := ALSU_BIS_QV   ; 					-- OB  DBUS  QV  UV  NOCARE
        micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				-- 0  1  2  3  NOCARE
        micv.rf_oas     := RF_OAS_NOCARE     ; 				-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_obs     := RF_OBS_NOCARE     ; 				-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := f7_cr     ; 						-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_l       := RF_L_LOAD       ; 				-- HOLD  LOAD
        micv.abus_s     := ABUS_S_PC     ; 					-- PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				-- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				-- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE   ; 				-- RELEASE   USE
        micv.sr_l       := SR_L_LOAD       ; 				-- HOLD   LOAD
        micv.pc_i       := PC_I_INC       ; 				-- NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV      ; 					-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_l       := IR_L_LOAD       ; 				-- HOLD   LOAD
        micv.msg        := MSG_OK        ; 					-- OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0      ; 					-- NOCARE  0 1 2 3 4 5 6 7
	elsif (f7_opq = F7_OPQ_ADQ) then						-- ADd Quick
	  	micv.alsu_op    := ALSU_OP_ADD    ; 				-- NOCARE ADD ADC SUB NEG AND OR XOR NOT SRL SRA RRC PSB LDB STB EXT SWP RLB
        micv.alsu_ais   := ALSU_AIS_OA   ; 					-- PC  OA  SR ZERO NOCARE
        micv.alsu_bis   := ALSU_BIS_QV   ; 					-- OB  DBUS  QV  UV  NOCARE
        micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				-- 0  1  2  3  NOCARE
        micv.rf_oas     := RF_OAS_NOCARE   ; 				-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_obs     := RF_OBS_NOCARE     ; 				-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := f7_cr     ; 						-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_l       := RF_L_LOAD       ; 				-- HOLD  LOAD
        micv.abus_s     := ABUS_S_PC     ; 					-- PC    OA (or OB depending on architecture) NOCARE
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				-- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				-- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE   ; 				-- RELEASE   USE
        micv.sr_l       := SR_L_LOAD       ; 				-- HOLD   LOAD
        micv.pc_i       := PC_I_INC       ; 				-- NOINC  INC   NOCARE
        micv.bc_cc      := BC_CC_NV      ; 					-- NV AL EQ NE GE LE GT LW AE BE AB BL VS VC NS NC
        micv.ir_l       := IR_L_LOAD       ; 				-- HOLD   LOAD
        micv.msg        := MSG_OK        ; 					-- OK   ILLEGAL_INSTRUCTION
        micv.next_cycle := CYCLE_0      ; 					-- NOCARE  0 1 2 3 4 5 6 7
	else
		micv := MIC_ERROR; 									-- on pr�vient de l'erreur avec MIC_ERROR dont .msg=1
	end if;
	
------------------------------------ Instructions du groupe 8 --------------------------------------------------------------

elsif (fc = F8_CODE) then
	  micv.alsu_op    := ALSU_OP_ADD    ; 													-- l'instruction est du groupe de format 8 (1 seul cycle)
        micv.alsu_ais   := ALSU_AIS_PC   ; 				-- branche PC sur entr�e A de l'ALSU
        micv.alsu_bis   := ALSU_BIS_QV   ; 				-- branche QV sur l'entr�e B de l'ALSU
        micv.alsu_uvc   := ALSU_UVC_NOCARE ; 				
        micv.rf_oas     := RF_OAS_NOCARE   ; 				
        micv.rf_obs     := RF_OBS_NOCARE   ; 				
        micv.rf_ins     := RF_INS_NOCARE   ; 				
        micv.rf_l       := RF_L_HOLD      ; 				-- HOLD  LOAD
        micv.abus_s     := ABUS_S_PC    ; 				-- utilise le bus d'adresse pour la mise � jour de PC
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				-- WORD  BYTE   NOCARE
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				-- READ    WRITE    NOCARE
        micv.cbus_str   := CBUS_STR_USE   ; 				-- RELEASE   USE
        micv.sr_l       := SR_L_HOLD   ; 				-- HOLD   LOAD
        micv.pc_i       := PC_I_INC    ; 				-- incr�mentation du PC
        micv.bc_cc      := f8_cc; 					-- mettre dans bc_cc le code de condition des instructions du groupe 8
        micv.ir_l       := IR_L_LOAD   ; 				-- charge le registre d'instruction comme usuellement
        micv.msg        := MSG_OK     ; 	
        micv.next_cycle := CYCLE_0    ; 	
else
	micv := MIC_ERROR; 
end if;

mic <= micv;  												-- affecte le contenu de la variable micv au signal mic

end process;

end architecture;
