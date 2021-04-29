
--=====================================================
--muxn_2.vhd
--=====================================================

library ieee;	-- importe la bibliothèque "ieee"
use ieee.std_logic_1164.all; --rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee",
							
							
							
entity muxn_2 is
	generic ( N : Integer := 4);
	port (					
		s : in Std_Logic;
		x0 : in Std_Logic_Vector(N-1 downto 0);
		x1 : in Std_Logic_Vector(N-1 downto 0);
		y : buffer Std_Logic_Vector(N-1 downto 0)
		);
end entity;
architecture MUXN_2_arch of MUXN_2 is 
begin
y <= x0 when s = '0' else
	x1;
end architecture;
--=====================================================
--muxn_4.vhd
--=====================================================

library ieee;	-- importe la bibliothèque "ieee"
use ieee.std_logic_1164.all; --rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee",
							
							
							
entity muxn_4 is
	generic ( N : Integer :=4);
	port (					
		s : in Std_Logic_Vector(1 downto 0);
		x0 : in Std_Logic_Vector(N-1 downto 0);
		x1 : in Std_Logic_Vector(N-1 downto 0);
		x2 : in Std_Logic_Vector(N-1 downto 0);
		x3 : in Std_Logic_Vector(N-1 downto 0);
		y : buffer Std_Logic_Vector(N-1 downto 0)
		);
end entity;
architecture MUXN_4_arch of MUXN_4 is 
begin
with s select
	Y <= x0 when "00", 
		x1 when "01", 
		x2 when "10", 
		x3 when others; 
end architecture;
--=====================================================
--regn.vhd
--=====================================================

library ieee;	-- importe la bibliothèque "ieee"
use ieee.std_logic_1164.all; --rend visible "tous" les éléments
							-- du paquetage "std_logic_1164"
							-- de la bibliothèque "ieee",
							
							
							
entity regn is
	generic( N : Integer := 4); 
	port(
		clock : in Std_Logic; 
		R : in Std_Logic; 
		L : in Std_Logic; 
		D : in Std_Logic_Vector(N-1 downto 0); 
		Q : buffer Std_Logic_Vector(N-1 downto 0) 
		);
end entity;
architecture REGN_arch of REGN is
begin
proc: process (clock)
begin
	if (clock'event and clock='1') then 
		if(R='1') then
			Q <= (others => '0');
		elsif (L='1') then 
			Q <= D;
		end if;
	end if;	
end process;
end architecture;
--=====================================================
--cntn.vhd
--=====================================================

library ieee;										-- importe la bibliothèque "ieee"
use ieee.std_logic_1164.all; 						--rend visible "tous" les éléments
													-- du paquetage "std_logic_1164"
													-- de la bibliothèque "ieee",
													
													
													
entity cntn is
	generic( N : Integer := 4); 					
	port(
		clock : in Std_Logic; 						
		R : in Std_Logic; 							
		L : in Std_Logic; 							
		T : in Std_Logic;							
		V : in Std_Logic_Vector(N-1 downto 0);		
		D : in Std_Logic_Vector(N-1 downto 0); 		
		Q : buffer Std_Logic_Vector(N-1 downto 0); 	
		C : buffer Std_Logic						
		);					
end entity;
architecture CNTN_arch of CNTN is
signal RC : std_logic_vector(N-1 downto 0);
signal RI : std_logic_vector(N-1 downto 0);
signal QQ_n : std_logic_vector(N-1 downto 0);
begin			
RI(0) <= T;
QQ_n <= Q xor RI;
RC <= Q and RI;
carry_gen : for i in 1 to N-1 generate
				RI(i) <= RC(i-1);
				end generate;
C <= RC(N-1);
proc: process (clock)
begin
	if (clock'event and clock='1') then
    	if(R='1') then
			Q <= V;									
		elsif (L='1') then
 	    	Q <= D;									
			elsif (T='1') then
 		    	Q <= QQ_n;							
		end if;
	end if;
end process;
end architecture;
--=====================================================
--baspck.vhd
--=====================================================

library ieee; 				 
use ieee.std_logic_1164.all; 
package basic_pack is
subtype DByte  is Std_Logic_Vector (15 downto 0); 
subtype Byte   is Std_Logic_Vector (7 downto 0);  
subtype Pentad is Std_Logic_Vector (4 downto 0);  
subtype Nibble is Std_Logic_Vector (3 downto 0);  
subtype Triad  is Std_Logic_Vector (2 downto 0);  
subtype Pair   is Std_Logic_Vector (1 downto 0);  
subtype Wire   is Std_Logic;                      
component MUXN_2                   
    generic(N: integer := 4);
    port(
	S:  in     std_logic;                       
	X0: in     std_logic_vector(N-1 downto 0);  
	X1: in     std_logic_vector(N-1 downto 0);  
	Y:  buffer std_logic_vector(N-1 downto 0)); 
end component;
component MUXN_4                   
	generic(N: integer :=4);
	port(
	S:  in	   std_logic_vector(1 downto 0);	
	X0: in	   std_logic_vector(N-1 downto 0);	
	X1: in	   std_logic_vector(N-1 downto 0);	
	X2: in	   std_logic_vector(N-1 downto 0);	
	X3: in	   std_logic_vector(N-1 downto 0);	
	Y:  buffer std_logic_vector(N-1 downto 0));	
end component;
component LFFN               
    generic(N: integer := 4);                      
    port(
        G: in     std_logic;                       
        D: in     std_logic_vector(N-1 downto 0);  
	Q: buffer std_logic_vector(N-1 downto 0)); 
end component;
component REGN               
        generic(N: integer := 4);                     
        port(
        clock:  in   std_logic;                       
        R:    in     std_logic;                       
        L:    in     std_logic;                       
        D:    in     std_logic_vector(N-1 downto 0);  
        Q:    buffer std_logic_vector(N-1 downto 0)); 
end component;
component CNTN               
    generic (N: integer :=4);	                      
    port(
        clock: in     std_logic;                      
        R:     in     std_logic;                      
        L:     in     std_logic;                      
        T:     in     std_logic;                      
        V:     in     std_logic_vector(N-1 downto 0); 
	D:     in     std_logic_vector(N-1 downto 0); 
        Q:     buffer std_logic_vector(N-1 downto 0); 
        C:     buffer std_logic                       
        );
end component;
end package;
--=====================================================
--alsun.vhd
--=====================================================

library ieee;										-- importe la bibliothèque "ieee"
use ieee.std_logic_1164.all; 						--rend visible "tous" les éléments
													-- du paquetage "std_logic_1164"
													-- de la bibliothèque "ieee",
													
													
													
entity alsun is
	generic( N : Integer := 4); 					
	port(
		P : in std_logic_vector(4 downto 0); 
		I : in std_logic; 
		ADR : in std_logic; 
		A : in std_logic_vector(N-1 downto 0); 
		B : in std_logic_vector(N-1 downto 0); 
		R : buffer std_logic_vector(N-1 downto 0); 
		C : buffer std_logic; 
		V : buffer std_logic 
		);					
end entity;
architecture ALSUN_arch of ALSUN is
signal RC: Std_Logic_Vector(N-1 downto 0);
signal RI: Std_Logic_Vector(N-1 downto 0);
attribute SYNTHESIS_OFF of RI : signal is FALSE;
constant ALSU_ADD : std_logic_vector(4 downto 0) := "00110"; 
constant ALSU_ADC : std_logic_vector(4 downto 0) := "00000"; 
constant ALSU_SUB : std_logic_vector(4 downto 0) := "00111"; 
constant ALSU_AND : std_logic_vector(4 downto 0) := "00100"; 
constant ALSU_OR : std_logic_vector(4 downto 0) := "00101"; 
constant ALSU_XOR : std_logic_vector(4 downto 0) := "00001"; 
constant ALSU_NOT : std_logic_vector(4 downto 0) := "10100"; 
constant ALSU_NEG : std_logic_vector(4 downto 0) := "10111"; 
constant ALSU_SRL : std_logic_vector(4 downto 0) := "10010"; 
constant ALSU_SRA : std_logic_vector(4 downto 0) := "10011"; 
constant ALSU_RRC : std_logic_vector(4 downto 0) := "10001"; 
constant ALSU_SWP : std_logic_vector(4 downto 0) := "11010"; 
constant ALSU_EXT : std_logic_vector(4 downto 0) := "11101"; 
constant ALSU_LDW : std_logic_vector(4 downto 0) := "01101"; 
constant ALSU_STW : std_logic_vector(4 downto 0) := "01100"; 
begin
RI(0)<=	I when P=ALSU_ADC else
		'0' when P=ALSU_ADD else
		'1' when P=ALSU_SUB else
		'1' when P=ALSU_NEG else
		'-'; 
RC <=	(A and B) or (RI and B) or (RI and A) when P=ALSU_ADC else
		(A and B) or (RI and B) or (RI and A) when P=ALSU_ADD else 
		(A and (not B)) or (A and RI) or ((not B) and RI) when P=ALSU_SUB else
		(not B) and RI when P=ALSU_NEG;
		
carry_gen : for j in 1 to N-1 generate
				RI(j) <= RC(j-1); 
			end generate;
Alsu_proc: process (A, B, ADR, R, C, V, RI, P, RC)
Variable rv: std_logic_vector(N-1 downto 0);
begin
case P is 
	when ALSU_XOR =>
		rv := A xor B;
		v <= '0';
		c <= '0';
	when ALSU_AND =>
		rv := A and B;
		v <= '0';
		c <= '0';
	when ALSU_OR =>
		rv := A or B;
		v <= '0';
		c <= '0';
	when ALSU_NOT =>
		rv := not B;
		v <= '0';
		c <= '0';
	when ALSU_ADD =>
		rv := (A xor B) xor RI;
		v <= RC(N-1) xor RC(N-2);
		c <= RC(N-1);
	when ALSU_SUB =>
		c <= '0';
		v <= '0'; 
		for k in 0 to N-1 loop
			rv(k) := not(A(k) xor (not B(k)));
		end loop;
	when ALSU_NEG =>
		rv := (not B) xor RI;
		v <= RC(N-1) xor RC(N-2);
		c <= not(RC(N-1));
	when ALSU_SRL =>
		c <= B(N-1);
		v <= '0';
		rv(0) := '0';
		for k in 1 to N-1 loop
			rv(k) := B(k-1);
		end loop;
	
	when ALSU_SRA =>
	 	rv(N-1) := B(N-1);
		c <= B(0);
		v <= '0';
		rv(0) := '0';
		for k in 0 to N-2 loop
			rv(k) := B(k+1);
		end loop;
	
	when ALSU_RRC =>
	 	rv(N-1) := I;
		c <= B(0);
		v <= '0';
		for k in 0 to N-2 loop
			rv(k) := B(k+1);
		end loop;
	
	when ALSU_SWP =>
		c <= '0';
		v <= '0';
		for k in 0 to N/2-1 loop
			rv(k) := b(k+N/2); 
 		    rv(k+N/2) := b(k); 
		end loop;
	
	when ALSU_EXT =>
		for k in 0 to N/2-1 loop
			rv(k+N/2) := b(N/2-1);
			rv(k) := b(k);
		end loop;
		c <= '0';
		v <= '0';
	
	when ALSU_LDW =>
		c <= '0';
		v <= '0';
			for k in 0 to N/2-1 loop
				rv(k) := b(k); 
 		    	rv(k+N/2) := b(k+N/2); 
			end loop;
	when ALSU_STW =>
		c <= '0';
		v <= '0';
			for k in 0 to N/2-1 loop
				rv(k) := b(k); 
 		    	rv(k+N/2) := b(k+N/2); 
			end loop;
	when others => 
		rv := (others => '-'); 
end case;
R <= rv;
end process;
end architecture;

--=====================================================
--bc.vhd
--=====================================================

library ieee;										-- importe la bibliothèque "ieee"
use ieee.std_logic_1164.all; 						--rend visible "tous" les éléments
													-- du paquetage "std_logic_1164"
													-- de la bibliothèque "ieee",
													
													
													
entity branch_controller is
	port(
		NF : in Std_Logic; 							
		CF : in Std_Logic; 							
		VF : in Std_Logic; 							
		ZF : in Std_Logic;							
		CC : in Std_Logic_Vector(3 downto 0);		
		BR : buffer Std_Logic						
		);					
end entity;
architecture BC_arch of branch_controller is
constant BC_NV : Std_Logic_Vector(3 downto 0) := "0000";	
constant BC_AL : Std_Logic_Vector(3 downto 0) := "0001";	
constant BC_EQ : Std_Logic_Vector(3 downto 0) := "0010";	
constant BC_NE : Std_Logic_Vector(3 downto 0) := "0011";	
constant BC_GE : Std_Logic_Vector(3 downto 0) := "0100";	
constant BC_LE : Std_Logic_Vector(3 downto 0) := "0101";	
constant BC_GT : Std_Logic_Vector(3 downto 0) := "0110";	
constant BC_LW : Std_Logic_Vector(3 downto 0) := "0111";	
constant BC_AE : Std_Logic_Vector(3 downto 0) := "1000";	
constant BC_BE : Std_Logic_Vector(3 downto 0) := "1001";	
constant BC_AB : Std_Logic_Vector(3 downto 0) := "1010";	
constant BC_BL : Std_Logic_Vector(3 downto 0) := "1011";	
constant BC_VS : Std_Logic_Vector(3 downto 0) := "1100";	
constant BC_VC : Std_Logic_Vector(3 downto 0) := "1101";	
constant BC_NS : Std_Logic_Vector(3 downto 0) := "1110";	
constant BC_NC : Std_Logic_Vector(3 downto 0) := "1111";	
begin
with CC select
	BR <= '0'when BC_NV,
		  '1' when BC_AL,
		  ZF when BC_EQ,
		  not ZF when BC_NE,
		  not (NF xor VF) when BC_GE,
		  (NF xor VF) or ZF when BC_LE,
		  (not (NF xor VF)) and (not ZF) when BC_GT,
		  NF xor VF when BC_LW,
		  not CF when BC_AE,
		  CF or ZF when BC_BE,
		  (not CF) and (not ZF) when BC_AB,
		  CF when BC_BL,
		  VF when BC_VS,
		  not VF when BC_VC,
		  NF when BC_NS,
		  not NF when BC_NC,
		  '0' when others;
end architecture;
--=====================================================
--tprf.vhd
--=====================================================

library ieee;
use ieee.std_logic_1164.all;
package subroutine_pack is
function convert_slv_to_int(slv: Std_Logic_Vector) return Integer;
end package;
package body subroutine_pack is
function convert_slv_to_int(slv: Std_Logic_Vector) return Integer is
variable result:    Integer := 0;
variable bit_value: Integer := 0;
begin
result := 0;
bit_loop: for i in slv'low to slv'high loop
    if (slv(i) = '1') then
        bit_value := 2**(i);
    else
        bit_value := 0;
    end if;
    result := result + bit_value; 
end loop;
return result;
end function;
end package body;
library ieee;
use ieee.std_logic_1164.all;
use subroutine_pack.all;
 
entity TRIPLE_PORT_REG_FILE is
    generic (
        alpha: Integer := 2;  
        M:     Integer := 4;  
        N:     Integer := 4   
        );
    port (
        clock: in     Std_Logic;                                  
        R:     in     Std_Logic;                                  
        L:     in     Std_Logic;                                  
        ins:   in     Std_Logic_Vector(alpha-1 downto 0); 
        oas:   in     Std_Logic_Vector(alpha-1 downto 0); 
        obs:   in     Std_Logic_Vector(alpha-1 downto 0); 
        i:     in     Std_Logic_Vector(N-1 downto 0);     
        oa:    buffer Std_Logic_Vector(N-1 downto 0);     
        ob:    buffer Std_Logic_Vector(N-1 downto 0)      
        );
end entity;
architecture triple_port_reg_file_arc of TRIPLE_PORT_REG_FILE is
type Table_MN is array (0 to M-1) of std_logic_vector(N-1 downto 0);
signal REG: Table_MN;           
signal index_a: Integer := 0; 
signal index_b: Integer := 0; 
signal index_i: Integer := 0; 
begin
index_i <= convert_slv_to_int(ins);
index_a <= convert_slv_to_int(oas); 
index_b <= convert_slv_to_int(obs); 
oa <= reg(index_a); 
ob <= reg(index_b);
reg_file_proc: process (clock)
begin
if (clock'event and clock = '1') then      
    if (r = '1') then      
        reset_loop: for k in 0 to M-1 loop
	        reg(k) <= (others => '0');     
        end loop;
    elsif (L = '1') then
        reg(index_i) <= i;
    end if;
end if;
end process;
end architecture;

--=====================================================
--micpck.vhd
--=====================================================

library ieee;                	
use ieee.std_logic_1164.all;
use basic_pack.all;
package MIC_PACK is
constant ALPHA: Integer := 2; 
subtype Selector_Type is Std_logic_Vector(alpha-1 downto 0);
type Mic_Type is record
    alsu_op:  Pentad;
    alsu_ais: Pair;  
    alsu_bis: Pair;  
    alsu_uvc: Pair;  
    rf_oas:   Selector_Type;  
    rf_obs:   Selector_Type;  
    rf_ins:   Selector_Type;  
    rf_l:     Wire;           
    abus_s:   Wire;  
    cbus_typ: Wire;  
    cbus_wrt: Wire;  
    cbus_str: Wire;  
    
    sr_l:       Wire;   
    pc_i:       Wire;   
    bc_cc:      Nibble; 
    ir_l:       Wire;   
    msg:        Pair;   
    next_cycle: Triad;  
end record;
constant ALSU_OP_NOCARE: Pentad := "-----"; 
constant ALSU_OP_ADD: Pentad := "00110"; 
constant ALSU_OP_ADC: Pentad := "00000"; 
constant ALSU_OP_SUB: Pentad := "00111"; 
constant ALSU_OP_XOR: Pentad := "00001"; 
constant ALSU_OP_AND: Pentad := "00100"; 
constant ALSU_OP_OR:  Pentad := "00101"; 
constant ALSU_OP_NEG: Pentad := "10111"; 
constant ALSU_OP_NOT: Pentad := "10100"; 
constant ALSU_OP_SRL: Pentad := "10010"; 
constant ALSU_OP_SRA: Pentad := "10011"; 
constant ALSU_OP_RRC: Pentad := "10001"; 
constant ALSU_OP_SWP: Pentad := "11010"; 
constant ALSU_OP_EXT: Pentad := "11101"; 
constant ALSU_OP_RLB: Pentad := "11011"; 
constant ALSU_OP_PSB: Pentad := "01100"; 
constant ALSU_OP_LDB: Pentad := "01011"; 
constant ALSU_OP_STB: Pentad := "01010"; 
constant ALSU_AIS_PC:     Pair  := "00"; 
constant ALSU_AIS_OA:     Pair  := "01"; 
constant ALSU_AIS_ZERO:   Pair  := "10"; 
constant ALSU_AIS_SR:     Pair  := "11"; 
constant ALSU_AIS_NOCARE: Pair  := "--"; 
constant ALSU_BIS_OB:     Pair  := "00"; 
constant ALSU_BIS_DBUS:   Pair  := "01"; 
constant ALSU_BIS_QV:     Pair  := "10"; 
constant ALSU_BIS_UV:     Pair  := "11"; 
constant ALSU_BIS_NOCARE: Pair  := "--"; 
constant ALSU_UVC_0:      Pair := "00"; 
constant ALSU_UVC_1:      Pair := "01"; 
constant ALSU_UVC_2:      Pair := "10"; 
constant ALSU_UVC_3:      Pair := "11"; 
constant ALSU_UVC_NOCARE: Pair := "--"; 
constant RF_OAS_NOCARE:  Selector_type := (others => '-');
constant RF_OAS_R0:      Selector_Type := (others => '0');               
constant RF_OAS_R1:      Selector_Type := (0=>'1', others=>'0');         
constant RF_OAS_R2:      Selector_Type := (1=>'1', others=>'0');         
constant RF_OAS_R3:      Selector_Type := (1=>'1', 0=>'1', others=>'0'); 
constant RF_OAS_SP:      Selector_Type := (others=>'1'); 
constant RF_OBS_NOCARE:  Selector_Type := (others => '-');
constant RF_OBS_R0:      Selector_Type := (others => '0');              
constant RF_OBS_R1:      Selector_Type := (0=>'1', others=>'0');        
constant RF_OBS_R2:      Selector_Type := (1=>'1', others=>'0');        
constant RF_OBS_R3:      Selector_Type := (1=>'1', 0=>'1', others=>'0');
constant RF_OBS_SP:      Selector_Type := (others=>'1'); 
constant RF_INS_NOCARE:  Selector_Type := (others => '-');
constant RF_INS_R0:      Selector_Type := (others => '0');              
constant RF_INS_R1:      Selector_Type := (0=>'1', others=>'0');        
constant RF_INS_R2:      Selector_Type := (1=>'1', others=>'0');        
constant RF_INS_R3:      Selector_Type := (1=>'1', 0=>'1', others=>'0');
constant RF_INS_SP:      Selector_Type := (others=>'1'); 
constant RF_L_HOLD: Wire := '0'; 
constant RF_L_LOAD: Wire := '1'; 
constant ABUS_S_PC:     Wire := '0'; 
constant ABUS_S_OA:     Wire := '1'; 
constant ABUS_S_OB:     Wire := '1'; 
constant ABUS_S_NOCARE: Wire := '-'; 
constant CBUS_TYP_WORD:   Wire := '0'; 
constant CBUS_TYP_BYTE:   Wire := '1'; 
constant CBUS_TYP_NOCARE: Wire := '-'; 
constant CBUS_WRT_READ:   Wire := '0'; 
constant CBUS_WRT_WRITE:  Wire := '1'; 
constant CBUS_WRT_NOCARE: Wire := '-'; 
constant CBUS_STR_USE:     Wire := '1'; 
constant CBUS_STR_RELEASE: Wire := '0'; 
constant SR_L_HOLD: Wire := '0'; 
constant SR_L_LOAD: Wire := '1'; 
constant PC_I_NOINC:  Wire := '0'; 
constant PC_I_INC:    Wire := '1'; 
constant PC_I_NOCARE: Wire := '-'; -- does not care (use only when PC loads!)
constant BC_CC_NV:     Nibble := "0000";  
constant BC_CC_AL:     Nibble := "0001";  
constant BC_CC_EQ:     Nibble := "0010";  
constant BC_CC_NE:     Nibble := "0011";  
constant BC_CC_GE:     Nibble := "0100";  
constant BC_CC_LE:     Nibble := "0101";  
constant BC_CC_GT:     Nibble := "0110";  
constant BC_CC_LW:     Nibble := "0111";  
constant BC_CC_AE:     Nibble := "1000";  
constant BC_CC_BE:     Nibble := "1001";  
constant BC_CC_AB:     Nibble := "1010";  
constant BC_CC_BL:     Nibble := "1011";  
constant BC_CC_VS:     Nibble := "1100";  
constant BC_CC_VC:     Nibble := "1101";  
constant BC_CC_NS:     Nibble := "1110";  
constant BC_CC_NC:     Nibble := "1111";  
constant IR_L_HOLD: Wire := '0'; 
constant IR_L_LOAD: Wire := '1'; 
constant MSG_OK:                  Pair := "00"; 
constant MSG_ILLEGAL_INSTRUCTION: Pair := "01"; 
constant NEXT_CYCLE_RESET:  Triad := "000"; 
constant NEXT_CYCLE_NOCARE: Triad := "---"; 
constant CYCLE_0:      Triad := o"0";  
constant CYCLE_1:      Triad := o"1";  
constant CYCLE_2:      Triad := o"2";  
constant CYCLE_3:      Triad := o"3";  
constant CYCLE_4:      Triad := o"4";  
constant CYCLE_5:      Triad := o"5";  
constant CYCLE_6:      Triad := o"6";  
constant CYCLE_7:      Triad := o"7";  
--    o it sends an "illegal instruction" error code to the message field
constant MIC_ERROR: Mic_Type := (
    alsu_op    => ALSU_OP_NOCARE,
    alsu_ais   => ALSU_AIS_NOCARE,
    alsu_bis   => ALSU_BIS_NOCARE,
    alsu_uvc   => ALSU_UVC_NOCARE,
    rf_oas     => RF_OAS_NOCARE,
    rf_obs     => RF_OBS_NOCARE,
    rf_ins     => RF_INS_NOCARE,
    rf_l       => RF_L_HOLD,	
    
    abus_s     => ABUS_S_PC,        
    cbus_typ   => CBUS_TYP_WORD,
    cbus_wrt   => CBUS_WRT_READ,    
    cbus_str   => CBUS_STR_RELEASE, 
    sr_l       => SR_L_HOLD,
    pc_i       => PC_I_NOINC,
    bc_cc      => BC_CC_NV,
    ir_l       => IR_L_HOLD,
    msg        => MSG_ILLEGAL_INSTRUCTION, 
    next_cycle => NEXT_CYCLE_RESET);
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
--=====================================================
--idlpck.vhd
--=====================================================

library ieee;
use ieee.std_logic_1164.all;
use basic_pack.all;
use mic_pack.all;
package idl_pack is
constant FC_ERROR:    Nibble := x"0"; 
constant F1_CODE:     Nibble := x"1"; -- Format I   (Hexa of 1 = "0001") 
constant F2_CODE:     Nibble := x"2"; -- Format II  (Hexa of 2 = "0010") 
constant F3_CODE:     NIBBLE := x"3"; 
constant F4_CODE:     Nibble := x"4"; 
constant F5_CODE:     Nibble := x"5"; 
constant F6_CODE:     Nibble := x"6"; 
constant F7_CODE:     Nibble := x"7"; 
constant F8_CODE:     Nibble := x"8"; 
constant CC_NV  :   Nibble := "0000"; 
constant CC_AL  :   Nibble := "0001"; 
constant CC_EQ  :   Nibble := "0010"; 
constant CC_NE  :   Nibble := "0011"; 
constant CC_GE  :   Nibble := "0100"; 
constant CC_LE  :   Nibble := "0101"; 
constant CC_GT  :   Nibble := "0110"; 
constant CC_LW  :   Nibble := "0111"; 
constant CC_AE  :   Nibble := "1000"; 
constant CC_BE  :   Nibble := "1001"; 
constant CC_AB  :   Nibble := "1010"; 
constant CC_BL  :   Nibble := "1011"; 
constant CC_VS  :   Nibble := "1100"; 
constant CC_VC  :   Nibble := "1101"; 
constant CC_NS  :   Nibble := "1110"; 
constant CC_NC  :   Nibble := "1111"; 
constant MODE_IMMEDIATE:            Triad := "000"; 
constant MODE_REGISTER:             Triad := "001"; 
constant MODE_INDIRECT:             Triad := "010"; 
constant MODE_INDIRECT_POST_INC:    Triad := "011"; 
constant MODE_INDIRECT_PRE_DEC:     Triad := "100"; 
constant MODE_DIRECT:               Triad := "101"; 
constant MODE_INDEXED:              Triad := "110"; 
constant MODE_INDIRECT_PRE_INDEXED: Triad := "111"; 
constant F1_MASK :   DByte := "1000000000000000"; 
constant F1_MARK :   DByte := "1000000000000000"; 
constant F1_TAG_F1:  Wire  := '1';
constant F1_OP3_ADC: Triad := "000"; 
constant F1_OP3_XOR: Triad := "001"; 
constant F1_OP3_DIV: Triad := "010"; 
constant F1_OP3_MUL: Triad := "011"; 
constant F1_OP3_AND: Triad := "100"; 
constant F1_OP3_OR:  Triad := "101"; 
constant F1_OP3_ADD: Triad := "110"; 
constant F1_OP3_SUB: Triad := "111"; 
constant F2_MASK :   DByte  := "1111000000000000"; 
constant F2_MARK :   DByte  := "0100000000000000"; 
constant F2_TAG_F2:  Nibble := "0100";
constant F2_OP2_RLC: Nibble := "0000"; 
constant F2_OP2_RRC: Nibble := "0001"; 
constant F2_OP2_SRL: Nibble := "0010"; 
constant F2_OP2_SRA: Nibble := "0011"; 
constant F2_OP2_NOT: Nibble := "0100"; 
constant F2_OP2_SBB: Nibble := "0101"; 
constant F2_OP2_SHL: Nibble := "0110"; 
constant F2_OP2_NEG: Nibble := "0111"; 
constant F2_OP2_INP: Nibble := "1000"; 
constant F2_OP2_OUT: Nibble := "1001"; 
constant F2_OP2_SWB: Nibble := "1010"; 
constant F2_OP2_RLB: Nibble := "1011"; 
constant F2_OP2_ANI: Nibble := "1100"; 
constant F2_OP2_EXT: Nibble := "1101"; 
constant F2_OP2_ADI: Nibble := "1110"; 
constant F2_OP2_CMP: Nibble := "1111"; 
constant F3_MASK  :   DByte  := "1111000000000000"; 
constant F3_MARK1 :   DByte  := "0101000000000000"; 
constant F3_MARK2 :   DByte  := "0110000000000000"; 
constant F3_MARK3 :   DByte  := "0111000000000000"; 
constant F3_TAG_F3:   Pair   := "01";
constant F3_TYPE_WORD: Pair := "10";
constant F3_TYPE_BYTE: Pair := "01";
constant F3_TYPE_LONG: Pair := "11";
constant F3_D_LD: Wire:= '1';  
constant F3_D_ST: Wire:= '0';  
constant F3_D_LOD: Wire:= '1'; 
constant F3_D_STO: Wire:= '0'; 
constant F3_MODE_IMMEDIATE:            Triad := MODE_IMMEDIATE;
constant F3_MODE_REGISTER:             Triad := MODE_REGISTER;
constant F3_MODE_INDIRECT:             Triad := MODE_INDIRECT;
constant F3_MODE_INDIRECT_POST_INC:    Triad := MODE_INDIRECT_POST_INC;
constant F3_MODE_INDIRECT_PRE_DEC:     Triad := MODE_INDIRECT_PRE_DEC;
constant F3_MODE_DIRECT:               Triad := MODE_DIRECT;
constant F3_MODE_INDEXED:              Triad := MODE_INDEXED;
constant F3_MODE_INDIRECT_PRE_INDEXED: Triad := MODE_INDIRECT_PRE_INDEXED;
constant F4_MASK   :   DByte  := "1111000010000000"; 
constant F4_MARK   :   DByte  := "0000000010000000"; 
constant F4_CC_TAG :   Nibble := "0000";
constant F4_CC_NB  :   Nibble := CC_NV;
constant F4_CC_BR  :   Nibble := CC_AL; 
constant F4_CC_EQ  :   Nibble := CC_EQ; 
constant F4_CC_NE  :   Nibble := CC_NE; 
constant F4_CC_GE  :   Nibble := CC_GE; 
constant F4_CC_LE  :   Nibble := CC_LE; 
constant F4_CC_GT  :   Nibble := CC_GT; 
constant F4_CC_LW  :   Nibble := CC_LW; 
constant F4_CC_AE  :   Nibble := CC_AE; 
constant F4_CC_BE  :   Nibble := CC_BE; 
constant F4_CC_AB  :   Nibble := CC_AB; 
constant F4_CC_BL  :   Nibble := CC_BL; 
constant F4_MODE_IMMEDIATE:            Triad := MODE_IMMEDIATE;
constant F4_MODE_INDIRECT:             Triad := MODE_INDIRECT;
constant F4_MODE_INDIRECT_POST_INC:       Triad := MODE_INDIRECT_POST_INC;
constant F4_MODE_INDIRECT_PRE_DEC:        Triad := MODE_INDIRECT_PRE_DEC;
constant F4_MODE_DIRECT:               Triad := MODE_DIRECT;
constant F4_MODE_INDEXED:              Triad := MODE_INDEXED;
constant F4_MODE_INDIRECT_PRE_INDEXED: Triad := MODE_INDIRECT_PRE_INDEXED;
constant F5_MASK  :   DByte  := "1111100010000000"; 
constant F5_MARK  :   DByte  := "0000100000000000"; 
constant F5_OP1_JPA : Triad  := "000"; 
constant F5_OP1_JEA : Triad  := "001"; 
constant F5_OP1_JSR : Triad  := "010"; 
constant F5_OP1_TRP : Triad  := "011"; 
constant F5_OP1_TST : Triad  := "100"; 
constant F5_OP1_TSR : Triad  := "101"; 
constant F5_OP1_MSR : Triad  := "110"; 
constant F5_OP1_MPC : Triad  := "111"; 
constant F5_MODE_INDIRECT:             Triad := MODE_INDIRECT;
constant F5_MODE_INDIRECT_POST_INC:    Triad := MODE_INDIRECT_POST_INC;
constant F5_MODE_INDIRECT_PRE_DEC:     Triad := MODE_INDIRECT_PRE_DEC;
constant F5_MODE_DIRECT:               Triad := MODE_DIRECT;
constant F5_MODE_INDEXED:              Triad := MODE_INDEXED;
constant F5_MODE_INDIRECT_PRE_INDEXED: Triad := MODE_INDIRECT_PRE_INDEXED;
constant F6_MASK  :   DByte  := "1111100011111111"; 
constant F6_MARK  :   DByte  := "0000000000000000"; 
constant F6_OP0_NOP : Triad  := "000"; 
constant F6_OP0_HLT : Triad  := "001"; 
constant F6_OP0_RTS : Triad  := "010"; 
constant F6_OP0_RTI : Triad  := "011"; 
constant F6_OP0_CLC : Triad  := "100"; 
constant F6_OP0_STC : Triad  := "101"; 
constant F6_OP0_DSI : Triad  := "110"; 
constant F6_OP0_ENI : Triad  := "111"; 
constant F7_MASK  :   DByte  := "1110000000000000"; 
constant F7_MARK  :   DByte  := "0010000000000000"; 
constant F7_OPQ_LDQ : Wire   := '0'; 
constant F7_OPQ_ADQ : Wire   := '1'; 
constant F8_MASK   :   DByte  := "1111000000000000"; 
constant F8_MARK   :   DByte  := "0001000000000000"; 
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

--=====================================================
--idl1.vhd
--=====================================================

library ieee;
use ieee.std_logic_1164.all;
use basic_pack.all; 									
use mic_pack.all;   									
use idl_pack.all;   									
entity INSTRUCTION_DECODER_LOGIC is
    port (
        ic:    in     DByte;    							
        cycle: in     Triad;    							
		mic:   buffer Mic_Type  							
	);
attribute SUM_SPLIT of mic: signal is CASCADED; 			
end entity;
architecture idl_arc of INSTRUCTION_DECODER_LOGIC is
alias f1_tag:  Wire          is ic(15);
alias f1_op3:  Triad         is ic(14 downto 12);       	
alias f1_crsa: Selector_Type is ic(ALPHA-1+8 downto 8); 	
alias f1_crsb: Selector_Type is ic(ALPHA-1+4 downto 4); 	
alias f1_crd:  Selector_Type is ic(ALPHA-1 downto 0);   	
alias f2_op2:  Nibble        is ic(11 downto 8);        	
alias f2_tag:  Nibble        is ic(15 downto 12);
alias f2_crs:  Selector_Type is ic(ALPHA-1+4 downto 4); 	
alias f2_crd:  Selector_Type is ic(ALPHA-1 downto 0);   	
alias f3_tag:   Pair          is ic(15 downto 14);         	
alias f3_type:  Pair          is ic(13 downto 12);         	
alias f3_d:     Wire          is ic(7);                    	
alias f3_cra:   Selector_Type is ic(ALPHA-1+8 downto 0+8); 	
alias f3_mode:  Triad         is ic(6 downto 4);           	
alias f3_crb:   Selector_Type is ic(ALPHA-1 downto 0);     	
alias f4_cc  : Nibble        is ic(11 downto 8);
alias f4_tag : Nibble        is ic(15 downto 12);
alias f4_cr  : Selector_Type is ic(ALPHA-1 downto 0);
alias f4_mode: Triad         is ic(6 downto 4);
alias f5_tag : Pentad        is ic(15 downto 11);
alias f5_op1 : Triad         is ic(10 downto 8);
alias f5_mode: Triad         is ic(6 downto 4);
alias f5_cr  : Selector_Type is ic(ALPHA-1 downto 0);
alias f6_op0:  Triad is ic(10 downto 8);
alias f7_tag:  Triad  is ic (15 downto 13);
alias f7_opq:  Wire   is ic(12);
alias f7_cr :  Selector_Type is ic(ALPHA-1+8 downto 8);
alias f7_qvc:  Byte   is ic(7 downto 0);
alias f8_tag:  Nibble is ic(15 downto 12);
alias f8_cc:   Nibble is ic(11 downto 8);
alias f8_disp: Byte   is ic(7 downto 0);
signal fc: Nibble;
attribute SYNTHESIS_OFF of fc: signal is TRUE;
begin
                                 
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
mic_gen_proc: process (fc, cycle, ic,
    f1_op3, f1_crsa, f1_crsb, f1_crd, f2_op2, f2_crs, f2_crd, 
    f3_mode, f3_d, f3_type, f3_cra, f3_crb,
    f4_cc, f4_mode, f4_cr, f5_op1, f5_mode, f5_cr, 
    f6_op0, f7_opq, f7_cr, f7_qvc, f8_cc, f8_disp)      -- processus "combinatoire" déclenché
                                           
variable micv: Mic_Type := MIC_ERROR;      
begin
if (fc = F1_CODE) then 										
	if (f1_op3 /= F1_OP3_MUL and f1_op3 /= F1_op3_DIV) then		
		micv.alsu_op	:= "00" & f1_op3;					
		micv.alsu_ais	:= ALSU_AIS_OA;						
		micv.alsu_bis	:= ALSU_BIS_OB;						
		micv.alsu_uvc	:= ALSU_UVC_NOCARE;					
		micv.rf_oas     := f1_crsa     ; 					
        micv.rf_obs     := f1_crsb     ; 					
        micv.rf_ins     := f1_crd      ; 					
        micv.rf_l       := RF_L_LOAD   ; 					
        micv.abus_s     := ABUS_S_PC   ; 					
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				
        micv.cbus_str   := CBUS_STR_USE    ; 				
        micv.sr_l       := SR_L_LOAD       ; 				
        micv.pc_i       := PC_I_INC        ; 				
        micv.bc_cc      := BC_CC_NV        ; 				
        micv.ir_l       := IR_L_LOAD       ; 				
        micv.msg        := MSG_OK          ; 				
        micv.next_cycle := CYCLE_0	       ; 				
	 else													-- Opération non exécutable("illegal instruction")
	 	micv	:= MIC_ERROR;								
   end if;
elsif (fc = F2_CODE) then								
	if(f2_op2=F2_OP2_NOT or f2_op2=F2_OP2_NEG or f2_op2=F2_OP2_SRL or f2_op2=F2_OP2_SRA or f2_op2=F2_OP2_RRC or f2_op2=F2_OP2_RLB or f2_op2=F2_OP2_SWB or f2_op2=F2_OP2_EXT) then
		micv.alsu_op    := "1" & f2_op2    ; 				
        micv.alsu_ais   := ALSU_AIS_OA   ; 					
        micv.alsu_bis   := ALSU_BIS_OB   ; 					
        micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				
        micv.rf_oas     := f2_crs     ; 					
        micv.rf_obs     := RF_OBS_NOCARE     ; 					-- R0  R1  R2  R3  SP  NOCARE
        micv.rf_ins     := f2_crd     ; 				
        micv.rf_l       := RF_L_LOAD       ; 				
        micv.abus_s     := ABUS_S_PC     ; 					
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				
        micv.cbus_str   := CBUS_STR_USE   ; 				
        micv.sr_l       := SR_L_LOAD       ; 				
        micv.pc_i       := PC_I_INC       ; 				
        micv.bc_cc      := BC_CC_NV      ; 					
        micv.ir_l       := IR_L_LOAD       ; 				
        micv.msg        := MSG_OK        ; 					
        micv.next_cycle := CYCLE_0      ;					
	else
		micv := MIC_ERROR; 									
	end if;
elsif (fc = F3_CODE) then 									
	if f3_d = F3_D_LD then									
		if f3_mode = F3_MODE_REGISTER then					
			micv.alsu_op    := ALSU_OP_PSB    ; 			
        	micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        	micv.alsu_bis   := ALSU_BIS_OB   ; 				
        	micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        	micv.rf_oas     := RF_OAS_NOCARE     ; 			
        	micv.rf_obs     := f3_crb    ; 					
        	micv.rf_ins     := f3_cra     ; 				
        	micv.rf_l       := RF_L_LOAD       ; 			
        	micv.abus_s     := ABUS_S_PC     ; 				
        	micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        	micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        	micv.cbus_str   := CBUS_STR_USE   ; 			
        	micv.sr_l       := SR_L_LOAD       ; 			
        	micv.pc_i       := PC_I_INC       ; 			
        	micv.bc_cc      := BC_CC_NV      ; 				
        	micv.ir_l       := IR_L_LOAD       ; 			
        	micv.msg        := MSG_OK        ; 				
        	micv.next_cycle := CYCLE_0      ; 				
		elsif f3_mode = F3_MODE_INDIRECT then				
			if cycle = CYCLE_0 then						
				micv.alsu_op    := ALSU_OP_PSB    ; 			
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        		micv.alsu_bis   := ALSU_BIS_OB   ; 				
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			
        		micv.rf_obs     := f3_crb    ; 					
        		micv.rf_ins     := f3_cra     ; 				
        		micv.rf_l       := RF_L_LOAD       ; 			
        		micv.abus_s     := ABUS_S_PC     ; 				
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        		micv.cbus_str   := CBUS_STR_USE   ; 			
        		micv.sr_l       := SR_L_LOAD       ; 			
        		micv.pc_i       := PC_I_NOINC       ; 			
        		micv.bc_cc      := BC_CC_NV      ; 				
        		micv.ir_l       := IR_L_LOAD       ; 			
        		micv.msg        := MSG_OK        ; 				
        		micv.next_cycle := CYCLE_1      ; 				
			elsif cycle = CYCLE_1 then		
				micv.alsu_op    := ALSU_OP_PSB    ; 			
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        		micv.alsu_bis   := ALSU_BIS_OB   ; 				
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			
        		micv.rf_obs     := f3_crb    ; 					
        		micv.rf_ins     := f3_cra     ; 				
        		micv.rf_l       := RF_L_LOAD       ; 			
        		micv.abus_s     := ABUS_S_PC     ; 				
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        		micv.cbus_str   := CBUS_STR_USE   ; 			
        		micv.sr_l       := SR_L_LOAD       ; 			
        		micv.pc_i       := PC_I_INC       ; 			
        		micv.bc_cc      := BC_CC_NV      ; 				
        		micv.ir_l       := IR_L_LOAD       ; 			
        		micv.msg        := MSG_OK        ; 				
        		micv.next_cycle := CYCLE_0      ; 				
			else		
				micv.alsu_op    := ALSU_OP_NOCARE    ; 			
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        		micv.alsu_bis   := ALSU_BIS_NOCARE   ; 				
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			
        		micv.rf_obs     := RF_OBS_NOCARE    ; 					
        		micv.rf_ins     := RF_INS_NOCARE     ; 				
        		micv.rf_l       := RF_L_LOAD       ; 			
        		micv.abus_s     := ABUS_S_PC     ; 				
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        		micv.cbus_str   := CBUS_STR_USE   ; 			
        		micv.sr_l       := SR_L_LOAD       ; 			
        		micv.pc_i       := PC_I_NOCARE       ; 			
        		micv.bc_cc      := BC_CC_NV      ; 				
        		micv.ir_l       := IR_L_LOAD       ; 			
        		micv.msg        := MSG_ILLEGAL_INSTRUCTION        ; 	
        		micv.next_cycle := NEXT_CYCLE_NOCARE      ; 				
			end if;
		elsif f3_mode = F3_MODE_IMMEDIATE then				
			if cycle = CYCLE_0 then	
				micv.alsu_op    := ALSU_OP_PSB    ; 			
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        		micv.alsu_bis   := ALSU_BIS_DBUS  ; 				
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			
        		micv.rf_obs     := f3_crb    ; 					
        		micv.rf_ins     := f3_cra     ; 				
        		micv.rf_l       := RF_L_LOAD       ; 			
        		micv.abus_s     := ABUS_S_PC     ; 				-- PC    OA (or OB depending on architecture) NOCARE
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        		micv.cbus_str   := CBUS_STR_USE   ; 			
        		micv.sr_l       := SR_L_LOAD       ; 			
        		micv.pc_i       := PC_I_INC     ; 			
        		micv.bc_cc      := BC_CC_NV      ; 				
        		micv.ir_l       := IR_L_HOLD       ; 			
        		micv.msg        := MSG_OK        ; 				
        		micv.next_cycle := CYCLE_1      ; 				
			elsif cycle = CYCLE_1 then		
				micv.alsu_op    := ALSU_OP_PSB    ; 			
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        		micv.alsu_bis   := ALSU_BIS_DBUS   ; 				
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			
        		micv.rf_obs     := f3_crb    ; 					
        		micv.rf_ins     := f3_cra     ; 				
        		micv.rf_l       := RF_L_LOAD       ; 			
        		micv.abus_s     := ABUS_S_PC     ; 				
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        		micv.cbus_str   := CBUS_STR_USE   ; 			
        		micv.sr_l       := SR_L_LOAD       ; 			
        		micv.pc_i       := PC_I_INC       ; 			
        		micv.bc_cc      := BC_CC_NV      ; 				
        		micv.ir_l       := IR_L_LOAD       ; 			
        		micv.msg        := MSG_OK        ; 				
        		micv.next_cycle := CYCLE_0      ; 				
			else			
				micv.alsu_op    := ALSU_OP_NOCARE    ; 			
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        		micv.alsu_bis   := ALSU_BIS_NOCARE   ; 				
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			
        		micv.rf_obs     := RF_OBS_NOCARE    ; 					
        		micv.rf_ins     := RF_INS_NOCARE     ; 				
        		micv.rf_l       := RF_L_LOAD       ; 			
        		micv.abus_s     := ABUS_S_PC     ; 				
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        		micv.cbus_str   := CBUS_STR_USE   ; 			
        		micv.sr_l       := SR_L_LOAD       ; 			
        		micv.pc_i       := PC_I_NOCARE       ; 			
        		micv.bc_cc      := BC_CC_NV      ; 				
        		micv.ir_l       := IR_L_LOAD       ; 			
        		micv.msg        := MSG_ILLEGAL_INSTRUCTION        ; 				
        		micv.next_cycle := NEXT_CYCLE_NOCARE      ; 				
			end if;
		else
			micv := MIC_ERROR; 								
		end if;
	elsif f3_d = F3_D_ST then								
		if f3_mode = F3_MODE_INDIRECT then					
			if cycle = CYCLE_0 then						
				micv.alsu_op    := ALSU_OP_PSB    ; 			
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        		micv.alsu_bis   := ALSU_BIS_OB   ; 				
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			
        		micv.rf_obs     := f3_crb    ; 					
        		micv.rf_ins     := f3_cra     ; 				
        		micv.rf_l       := RF_L_LOAD       ; 			
        		micv.abus_s     := ABUS_S_PC     ; 				
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        		micv.cbus_str   := CBUS_STR_USE   ; 			
        		micv.sr_l       := SR_L_LOAD       ; 			
        		micv.pc_i       := PC_I_NOINC       ; 			
        		micv.bc_cc      := BC_CC_NV      ; 				
        		micv.ir_l       := IR_L_LOAD       ; 			
        		micv.msg        := MSG_OK        ; 				
        		micv.next_cycle := CYCLE_1      ; 				
			elsif cycle = CYCLE_1 then					
				micv.alsu_op    := ALSU_OP_PSB    ; 			
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        		micv.alsu_bis   := ALSU_BIS_OB   ; 				
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			
        		micv.rf_obs     := f3_crb    ; 					
        		micv.rf_ins     := f3_cra     ; 				
        		micv.rf_l       := RF_L_LOAD       ; 			
        		micv.abus_s     := ABUS_S_PC     ; 				
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        		micv.cbus_str   := CBUS_STR_USE   ; 			
        		micv.sr_l       := SR_L_LOAD       ; 			
        		micv.pc_i       := PC_I_INC       ; 			
        		micv.bc_cc      := BC_CC_NV      ; 				
        		micv.ir_l       := IR_L_LOAD       ; 			
        		micv.msg        := MSG_OK        ; 				
        		micv.next_cycle := CYCLE_0      ; 				
			else			
				micv.alsu_op    := ALSU_OP_NOCARE    ; 			
        		micv.alsu_ais   := ALSU_AIS_NOCARE   ; 			
        		micv.alsu_bis   := ALSU_BIS_NOCARE   ; 				
        		micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 			
        		micv.rf_oas     := RF_OAS_NOCARE     ; 			
        		micv.rf_obs     := RF_OBS_NOCARE    ; 					
        		micv.rf_ins     := RF_INS_NOCARE     ; 				
        		micv.rf_l       := RF_L_LOAD       ; 			
        		micv.abus_s     := ABUS_S_PC     ; 				
        		micv.cbus_typ   := CBUS_TYP_WORD   ; 			
        		micv.cbus_wrt   := CBUS_WRT_READ   ; 			
        		micv.cbus_str   := CBUS_STR_USE   ; 			
        		micv.sr_l       := SR_L_LOAD       ; 			
        		micv.pc_i       := PC_I_NOCARE       ; 			
        		micv.bc_cc      := BC_CC_NV      ; 				
        		micv.ir_l       := IR_L_LOAD       ; 			
        		micv.msg        := MSG_ILLEGAL_INSTRUCTION        ; 				
        		micv.next_cycle := NEXT_CYCLE_NOCARE      ; 				
			end if;
		else
			micv := MIC_ERROR; 								
		end if;
	 else
			micv := MIC_ERROR; 								
	 end if;
elsif (fc = F5_CODE) then									
	if f5_mode = F5_MODE_INDIRECT then						
		if(f5_op1 = F5_OP1_JEA) then						
			micv.alsu_op    := ALSU_OP_PSB    ; 				
        	micv.alsu_ais   := ALSU_AIS_NOCARE   ; 				
        	micv.alsu_bis   := ALSU_BIS_OB   ; 					
        	micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				
        	micv.rf_oas     := RF_OAS_NOCARE    ; 				
        	micv.rf_obs     := RF_OBS_NOCARE    ; 				
        	micv.rf_ins     := f5_cr     ; 						
        	micv.rf_l       := RF_L_HOLD       ; 				
        	micv.abus_s     := ABUS_S_PC     ; 					
        	micv.cbus_typ   := CBUS_TYP_WORD   ; 				
        	micv.cbus_wrt   := CBUS_WRT_READ   ; 				
        	micv.cbus_str   := CBUS_STR_USE   ; 				
        	micv.sr_l       := SR_L_HOLD       ; 				
        	micv.pc_i       := PC_I_NOCARE       ; 				
        	micv.bc_cc      := BC_CC_AL      ; 					
        	micv.ir_l       := IR_L_LOAD       ; 				
        	micv.msg        := MSG_OK        ; 					
        	micv.next_cycle := CYCLE_0      ; 					
		elsif(f5_op1 = F5_OP1_MPC) then							
	    	micv.alsu_op    := ALSU_OP_OR    ; 					
        	micv.alsu_ais   := ALSU_AIS_PC   ; 					
        	micv.alsu_bis   := ALSU_BIS_UV	   ; 					
        	micv.alsu_uvc   := ALSU_UVC_0; 						
        	micv.rf_oas     := RF_OAS_NOCARE    ; 				
        	micv.rf_obs     := RF_OBS_NOCARE    ; 				
        	micv.rf_ins     := f5_cr    ; 						
        	micv.rf_l       := RF_L_LOAD       ; 				
        	micv.abus_s     := ABUS_S_PC     ; 					
        	micv.cbus_typ   := CBUS_TYP_WORD   ; 				
        	micv.cbus_wrt   := CBUS_WRT_READ   ; 				
        	micv.cbus_str   := CBUS_STR_USE   ; 				
        	micv.sr_l       := SR_L_LOAD      ; 				
        	micv.pc_i       := PC_I_INC       ; 				
        	micv.bc_cc      := BC_CC_NV      ; 					
        	micv.ir_l       := IR_L_LOAD       ; 				
        	micv.msg        := MSG_OK        ; 					
        	micv.next_cycle := CYCLE_0      ; 					
		else
			micv := MIC_ERROR; 									
		end if; 
	else
			micv := MIC_ERROR; 								
	end if; 
elsif (fc = F6_CODE) then									
	if(f6_op0 = F6_OP0_NOP) then							
	  	micv.alsu_op    := "00" & f6_op0    ; 				
        micv.alsu_ais   := ALSU_AIS_NOCARE   ; 					
        micv.alsu_bis   := ALSU_BIS_NOCARE   ; 					
        micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				
        micv.rf_oas     := RF_OAS_NOCARE     ; 					
        micv.rf_obs     := RF_OBS_NOCARE     ; 					
        micv.rf_ins     := RF_INS_NOCARE     ; 				
        micv.rf_l       := RF_L_HOLD       ; 				
        micv.abus_s     := ABUS_S_PC     ; 					
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				
        micv.cbus_str   := CBUS_STR_USE   ; 				
        micv.sr_l       := SR_L_HOLD       ; 				
        micv.pc_i       := PC_I_INC       ; 				
        micv.bc_cc      := BC_CC_NV      ; 					
        micv.ir_l       := IR_L_LOAD       ; 				
        micv.msg        := MSG_OK        ; 					
        micv.next_cycle := CYCLE_0      ;	 				
	  else
		micv := MIC_ERROR; 									
	  end if;
	
elsif (fc = F7_CODE) then									
	if(f7_opq = F7_OPQ_LDQ) then							
	  	micv.alsu_op    := ALSU_OP_PSB    ; 				
        micv.alsu_ais   := ALSU_AIS_NOCARE   ; 					
        micv.alsu_bis   := ALSU_BIS_QV   ; 					
        micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				
        micv.rf_oas     := RF_OAS_NOCARE     ; 				
        micv.rf_obs     := RF_OBS_NOCARE     ; 				
        micv.rf_ins     := f7_cr     ; 						
        micv.rf_l       := RF_L_LOAD       ; 				
        micv.abus_s     := ABUS_S_PC     ; 					
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				
        micv.cbus_str   := CBUS_STR_USE   ; 				
        micv.sr_l       := SR_L_LOAD       ; 				
        micv.pc_i       := PC_I_INC       ; 				
        micv.bc_cc      := BC_CC_NV      ; 					
        micv.ir_l       := IR_L_LOAD       ; 				
        micv.msg        := MSG_OK        ; 					
        micv.next_cycle := CYCLE_0      ; 					
	elsif (f7_opq = F7_OPQ_ADQ) then						
	  	micv.alsu_op    := ALSU_OP_ADD    ; 				
        micv.alsu_ais   := ALSU_AIS_NOCARE   ; 					
        micv.alsu_bis   := ALSU_BIS_QV   ; 					
        micv.alsu_uvc   := ALSU_UVC_NOCARE   ; 				
        micv.rf_oas     := RF_OAS_NOCARE   ; 				
        micv.rf_obs     := RF_OBS_NOCARE     ; 				
        micv.rf_ins     := f7_cr     ; 						
        micv.rf_l       := RF_L_LOAD       ; 				
        micv.abus_s     := ABUS_S_PC     ; 					
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				
        micv.cbus_str   := CBUS_STR_USE   ; 				
        micv.sr_l       := SR_L_LOAD       ; 				
        micv.pc_i       := PC_I_INC       ; 				
        micv.bc_cc      := BC_CC_NV      ; 					
        micv.ir_l       := IR_L_LOAD       ; 				
        micv.msg        := MSG_OK        ; 					
        micv.next_cycle := CYCLE_0      ; 					
	else
		micv := MIC_ERROR; 									
	end if;
	
elsif (fc = F8_CODE) then
	  micv.alsu_op    := ALSU_OP_ADD    ; 													
        micv.alsu_ais   := ALSU_AIS_PC   ; 				
        micv.alsu_bis   := ALSU_BIS_QV   ; 				
        micv.alsu_uvc   := ALSU_UVC_NOCARE ; 				
        micv.rf_oas     := RF_OAS_NOCARE   ; 				
        micv.rf_obs     := RF_OBS_NOCARE   ; 				
        micv.rf_ins     := RF_INS_NOCARE   ; 				
        micv.rf_l       := RF_L_HOLD      ; 				
        micv.abus_s     := ABUS_S_PC    ; 				
        micv.cbus_typ   := CBUS_TYP_WORD   ; 				
        micv.cbus_wrt   := CBUS_WRT_READ   ; 				
        micv.cbus_str   := CBUS_STR_USE   ; 				
        micv.sr_l       := SR_L_HOLD   ; 				
        micv.pc_i       := PC_I_INC    ; 				
        micv.bc_cc      := f8_cc; 					
        micv.ir_l       := IR_L_LOAD   ; 				
        micv.msg        := MSG_OK     ; 	
        micv.next_cycle := CYCLE_0    ; 	
else
	micv := MIC_ERROR; 
end if;
mic <= micv;  												
end process;
end architecture;

--=====================================================
--cpupck.vhd
--=====================================================

library ieee; 				 		
use ieee.std_logic_1164.all;
use basic_pack.all;
use mic_pack.all;
package cpu_pack is
component ALSUN
   generic(N: Integer := 4);
   port(
     p:   in     Std_Logic_Vector(4 downto 0);   
     i:   in     Std_Logic;                      
     adr: in     Std_Logic;                      
     a:   in     Std_Logic_Vector(N-1 downto 0); 
     b:   in     Std_Logic_Vector(N-1 downto 0); 
     r:   buffer Std_Logic_Vector(N-1 downto 0); 
     c:   buffer Std_Logic;                      
     v:   buffer Std_Logic);                     
end component;
component BRANCH_CONTROLLER 
    port (
        cc: in Std_Logic_Vector(3 downto 0); 
        nf: in Std_Logic;                    
        cf: in Std_Logic;                    
        vf: in Std_Logic;                    
        zf: in Std_Logic;                    
        br: buffer Std_Logic);               
end component;
component TRIPLE_PORT_REG_FILE   
    generic (
        alpha:             Integer := 2;  
        M:                 Integer := 4;  
        N:                 Integer := 4); 
    port (
        clock:             in Std_Logic; 
        R:                 in Std_Logic; 
        L:                 in Std_Logic; 
        ins:               in Std_Logic_Vector(alpha-1 downto 0); 
        oas:               in Std_Logic_Vector(alpha-1 downto 0); 
        obs:               in Std_Logic_Vector(alpha-1 downto 0); 
        i:                 in     Std_Logic_Vector(N-1 downto 0);  
        oa:                buffer Std_Logic_Vector(N-1 downto 0);  
        ob:                buffer Std_Logic_Vector(N-1 downto 0)); 
end component;
component INSTRUCTION_DECODER_LOGIC 
    port (
        ic    :  in     DByte;     
        cycle :  in     Triad;     
        mic   :  buffer Mic_Type); 
end component;
end package;

--=====================================================
--cpu.vhd
--=====================================================

library ieee;
use ieee.std_logic_1164.all; 
use basic_pack.all; 
use cpu_pack.all;   
use mic_pack.all;   
                         
                         
entity CPU is
    generic (
        M:   Integer := 4  ;
        N:   Integer := 16  
        );                  
    port (
        
        clock: in     Std_Logic; 
        n_rst: in     Std_Logic; 
        n_str: buffer Std_Logic; 
        wrt:   buffer Std_Logic; 
        be0:   buffer Std_Logic; 
        be1:   buffer Std_Logic; 
        dbus:  inout  Std_Logic_Vector(N-1 downto 0); 
        abus:  buffer Std_Logic_Vector(N-1 downto 1) 
        );
end entity;
architecture micro_machine_arc of CPU is
subtype  Word is Std_Logic_Vector(N-1 downto 0); 
constant NOCARE_WORD: Word := (others => '-');   -- "--..-" (mot sans importance)
constant HIZ_WORD:    Word := (others => 'Z');   -- "ZZ..Z" (mot débranché)
constant ZERO_WORD:   Word := (others => '0');   -- "00..0" (mot zéro)
constant START_ADDRESS_D2: Std_Logic_Vector(N-2 downto 0) := (1=>'0', others => '1');
signal pcd2:       Std_Logic_Vector(N-2 downto 0); 
signal pc:          Word;     
signal uv:          Word;     
signal qv:          Word;     
signal rf_oa:       Word;     
signal rf_ob:       Word;     
signal alsu_a:      Word;     
signal alsu_b:      Word;     
signal cos:         Wire;     
signal coz:         Wire;     
signal cov:         Wire;     
signal coc:         Wire;     
signal new_flags:   Nibble;   
signal nf:          Wire;     
signal cf:          Wire;     
signal zf:          Wire;     
signal vf:          Wire;     
signal flags:       Nibble;   
signal sr:          Word;     
signal alsu_result: Word;     
signal dbus_in:     Word;     
signal abus0:       Wire;     
signal cpu_reset:   Wire;     
signal cpu_address: Word;     
signal pc_L:        Wire;     
signal mic:   		MIC_Type;  
signal ic:    		DByte;      
signal cycle:		Triad;		
alias nic:          DByte is dbus_in(15 downto 0); 
alias qvc:          Byte is ic(7 downto 0);        
alias branch_address_d2: Std_Logic_Vector(N-2 downto 0) is alsu_result(N-1 downto 1);
attribute SYNTHESIS_OFF of alsu_a:   signal is TRUE;    
attribute SYNTHESIS_OFF of alsu_b:   signal is TRUE;    
attribute SYNTHESIS_OFF of alsu_result: signal is TRUE; 
attribute SYNTHESIS_OFF of pc_l:     signal is TRUE;    
attribute SYNTHESIS_OFF of abus0:    signal is TRUE;    
attribute SYNTHESIS_OFF of mic:    signal is TRUE;    
begin
dbus <= alsu_result when ((mic.cbus_str and mic.cbus_wrt) = '1') else HIZ_WORD; 
-- équivalent au tampon ("buffer") et à la porte ET du schéma bloc
-- sinon DBUS est débranché, donc en haute-impédance "High Z", = ZZ..Z
dbus_in <= dbus; 
be0       <= not abus0;                  
be1       <= not(mic.cbus_typ xor abus0);
cpu_reset <= not n_rst;                  
n_str     <= not mic.cbus_str;           
wrt       <= mic.cbus_wrt;               
abus_gen: for k in 1 to N-1 generate
    abus(k) <= cpu_address(k); 
end generate;
abus0 <= cpu_address(0);       
pc <= pcd2 & '0';              
coz <= '1' when alsu_result=ZERO_WORD else '0'; 
cos <= alsu_result(N-1);                        
new_flags <= (coz, cov, coc, cos);              
(zf, vf, cf, nf) <= flags;                       
sr <= (3=>zf, 2=>vf, 1=>cf, 0=>nf, others=>'0'); 
qvl_gen: for k in 0 to 7 generate
    QV(k) <= QVC(k); 
end generate;
qvm_gen: for k in 8 to N-1 generate
    QV(k) <= QVC(7);  
end generate;
uv <= (1=>mic.alsu_uvc(1), 0=>mic.alsu_uvc(0), others=>'0');
-- =================================================================
rf: TRIPLE_PORT_REG_FILE          
    generic map (
        alpha => alpha ,  
        M     => M ,  
        N     => N )  
    port map (
        clock => clock ,  
        R     => cpu_reset ,  
        L     => mic.rf_L ,  
        INS   => mic.rf_ins ,  
        OAS   => mic.rf_oas ,  
        OBS   => mic.rf_obs,  
        I     => alsu_result,  
        OA    => rf_oa ,  
        OB    => rf_ob ); 
prg_cnt : CNTN  
    generic map (N  => N-1 )     
    port map (
        clock => clock ,  
        R     => cpu_reset ,  
        L     => pc_L ,  
        T     => mic.pc_i ,  
        V     => START_ADDRESS_D2 ,  
        D     => branch_address_d2 ,  
        Q     => pcd2  
		);
sta_reg : REGN  
    generic map (N  => 4 )     
    port map (
        clock => clock ,  
        R     => cpu_reset ,  
        L     => mic.sr_L ,  
        D     => new_flags ,  
        Q     => flags ); 
mux_a  : MUXN_4  
    generic map (N   => N )  
    port map (
        s   => mic.alsu_ais ,  
        x0  => pc ,  
        x1  => rf_oa ,  
        x2  => (others => '0'),  
        x3  => sr ,  
		y   => alsu_a ); 
mux_b  : MUXN_4  
    generic map (N   => N )  
    port map (
        s   => mic.alsu_bis ,  
        x0  => rf_ob ,  
        x1  => dbus_in ,  
        x2  => qv,  
        x3  => uv,  
        y   => alsu_b ); 
mux_address : MUXN_2  
    generic map (N   => N )  
    port map (
        s   => mic.abus_s ,  
        x0  => pc ,  
        x1  => rf_ob ,  
        y   => cpu_address ); 
alsu: ALSUN     
    generic map (N   => N)   
    port map (
        p   => mic.alsu_op ,  
        i   => CF ,  
        adr => abus0 ,  
        a   => alsu_a ,  
        b   => alsu_b ,  
        r   => alsu_result ,  
        c   => coc ,  
        v   => cov ); 
bc:  BRANCH_CONTROLLER 
    port map (
        cc  => mic.bc_cc ,  
        nf  => nf ,  
        cf  => cf ,  
        vf  => vf ,  
        zf  => zf ,  
        br  => pc_L ); 
ir : REGN  
    generic map (
        N  => N )     
    port map (
        clock => clock ,  
        R     => cpu_reset ,  
        L     => mic.ir_L ,  
        D     => nic ,  
        Q     => ic ); 
cycle_reg : REGN
	generic map (N  => 3 )     
    port map (
        clock => clock,  
        R     => cpu_reset,  
        L     => '1',  
        D     => mic.next_cycle,  
		Q => cycle 
        ); 
idl : INSTRUCTION_DECODER_LOGIC
    port map (
        ic		=> ic,    
        cycle	=> cycle,    
		mic		=> mic);  
end architecture;
