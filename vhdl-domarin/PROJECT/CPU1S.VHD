
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
RI(0) <= C;
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
component muxn_2
	generic ( N : Integer := 4);
	port (						
		s : in Std_Logic;
		x0 : in Std_Logic_Vector(N-1 downto 0);
		x1 : in Std_Logic_Vector(N-1 downto 0);
		y : buffer Std_Logic_Vector(N-1 downto 0)
		);
end component;
component muxn_4
	generic ( N : Integer :=4);
	port (					
		s : in Std_Logic_Vector(1 downto 0);
		x0 : in Std_Logic_Vector(N-1 downto 0);
		x1 : in Std_Logic_Vector(N-1 downto 0);
		x2 : in Std_Logic_Vector(N-1 downto 0);
		x3 : in Std_Logic_Vector(N-1 downto 0);
		y : buffer Std_Logic_Vector(N-1 downto 0)
		);
end component;
component REGN
	generic( N : Integer := 4); 
	port(
		L : in Std_Logic; 
		R : in Std_Logic; 
		clock : in Std_Logic; 
		D : in Std_Logic_Vector(N-1 downto 0); 
		Q : buffer Std_Logic_Vector(N-1 downto 0) 
		);
end component;
component cntn
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
end component;
subtype Wire is Std_Logic;
subtype Pair is Std_Logic_vector(1 downto 0);
subtype Triad is Std_Logic_vector(2 downto 0);
subtype Nibble is Std_Logic_vector(3 downto 0);
subtype Pentad is Std_Logic_vector(4 downto 0); 
subtype Byte is Std_Logic_vector(7 downto 0);
subtype DByte is Std_Logic_vector(15 downto 0);
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
		if ADR='1' then 
			for k in 0 to N/2-1 loop
				rv(k) := b(k+N/2); 
 		    	rv(k+N/2) := b(k); 
			end loop;
		else
			for k in 0 to N/2-1 loop
				rv(k) := b(k); 
 		    	rv(k+N/2) := b(k+N/2); 
			end loop;
		end if;
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
--tprf1.vhd
--=====================================================

library ieee;										-- importe la bibliothèque "ieee"
use basic_pack.all;							
use ieee.std_logic_1164.all; 						--rend visible "tous" les éléments
													-- du paquetage "std_logic_1164"
													-- de la bibliothèque "ieee",
													
													
													
entity TRIPLE_PORT_REG_FILE is
	generic( alpha : Integer := 2; M : Integer := 4; N : Integer := 4); 						
	port(
		clock : in Std_Logic; 								
		R : in Std_Logic; 									
		L : in Std_Logic; 									
		INS : in Std_Logic_Vector(alpha-1 downto 0);		
		OAS : in Std_Logic_Vector(alpha-1 downto 0); 		
		OBS : in Std_Logic_Vector(alpha-1 downto 0);		
		I : in Std_Logic_Vector(N-1 downto 0); 				
		OA : buffer Std_Logic_Vector(N-1 downto 0); 		
		OB : buffer Std_Logic_Vector(N-1 downto 0)		
		);					
end entity;
architecture tprf_arch of TRIPLE_PORT_REG_FILE is
signal R0, R1, R2, R3 : Std_Logic_Vector(N-1 downto 0);		
signal L0, L1, L2, L3 : Std_Logic;							
begin
regn_0 : REGN									
	generic map (N => N)						
	port map (
		L => L0,
		R => R,
		clock => clock,
		D => I,
		Q => R0);
regn_1: REGN									
	generic map (N => N)						
	port map (
		L => L1,
		R => R,
		clock => clock,
		D => I,
		Q => R1);
regn_2: REGN									
	generic map (N => N)						
	port map (
		L => L2,
		R => R,
		clock => clock,
		D => I,
		Q => R2);
regn_3: REGN									
	generic map (N => N)						
	port map (
		L => L3,
		R => R,
		clock => clock,
		D => I,
		Q => R3);
muxn_4_a : MUXN_4
	generic map (N => N)						
	port map (
		s => OAS,
		x0 => R0,
		x1 => R1,
		x2 => R2,
		x3 => R3,
		y => OA);
muxn_4_b : MUXN_4
	generic map (N => N)						
	port map (
		s => OBS,
		x0 => R0,
		x1 => R1,
		x2 => R2,
		x3 => R3,
		y => OB);
	
L0 <= L when INS = "00" else '0';
L1 <= L when INS = "01" else '0';
L2 <= L when INS = "10" else '0';
L3 <= L when INS = "11" else '0';
end architecture;
--=====================================================
--micpck1.vhd
--=====================================================

library ieee;                
use ieee.std_logic_1164.all; 
use basic_pack.all;     
package MIC_PACK is
Constant ALPHA: Integer := 2; 
                              
Subtype Selector_Type is Std_Logic_Vector(ALPHA-1 downto 0); 
                                                             
type Mic_Type is record
            alsu_op   : Pentad;         
            alsu_ais  : Pair;           
            alsu_bis  : Pair;           
            alsu_uvc  : Pair;           
            rf_oas    : Selector_Type;  
            rf_obs    : Selector_Type;  
            rf_ins    : Selector_Type;  
            rf_l      : Wire;           
            abus_s    : Wire;           
            cbus_typ  : Wire;           
            cbus_wrt  : Wire;           
            cbus_str  : Wire;           
            sr_l      : Wire;           
            pc_i      : Wire;           
            bc_cc     : Nibble;         
            ir_l      : Wire;           
            msg       : Pair;           
            next_cycle : Triad;         
end record;
end package;

--=====================================================
--cpupck1.vhd
--=====================================================

library ieee; 				 		
use ieee.std_logic_1164.all;
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
end package;

--=====================================================
--cpu1.vhd
--=====================================================

library ieee;
use ieee.std_logic_1164.all; 
use basic_pack.all; 
use cpu_pack.all;   
use mic_pack.all;   
                         
                         
entity MICRO_MACHINE is
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
        abus:  buffer Std_Logic_Vector(N-1 downto 1); 
        mic:   in     MIC_Type;  
        ic:    buffer DByte      
        );
end entity;
architecture micro_machine_arc of MICRO_MACHINE is
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
alias nic:          DByte is dbus_in(15 downto 0); 
alias qvc:          Byte is ic(7 downto 0);        
alias branch_address_d2: Std_Logic_Vector(N-2 downto 0) is alsu_result(N-1 downto 1);
----attribute SYNTHESIS_OFF of alsu_a:   signal is TRUE;    
----attribute SYNTHESIS_OFF of alsu_b:   signal is TRUE;    
----attribute SYNTHESIS_OFF of alsu_result: signal is TRUE; 
----attribute SYNTHESIS_OFF of pc_l:     signal is TRUE;    
----attribute SYNTHESIS_OFF of abus0:    signal is TRUE;    
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
-- INSTANCES DES COMPOSANTS AVEC LEURS CONNEXIONS à SPECIFIER CI-APRèS:
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
    generic map (
        N  => N-1 )     
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
    generic map (
        N  => 4 )     
    port map (
        clock => clock ,  
        R     => cpu_reset ,  
        L     => mic.sr_L ,  
        D     => new_flags ,  
        Q     => flags ); 
mux_a  : MUXN_4  
    generic map (
        N   => N )  
    port map (
        s   => mic.alsu_ais ,  
        x0  => pc ,  
        x1  => rf_oa ,  
        x2  => (others => '0'),  
        x3  => sr ,  
		y   => alsu_a ); 
mux_b  : MUXN_4  
    generic map (
        N   => N )  
    port map (
        s   => mic.alsu_bis ,  
        x0  => rf_ob ,  
        x1  => dbus_in ,  
        x2  => qv,  
        x3  => uv,  
        y   => alsu_b ); 
mux_address : MUXN_2  
    generic map (
        N   => N )  
    port map (
        s   => mic.abus_s ,  
        x0  => pc ,  
        x1  => rf_ob ,  
        y   => cpu_address ); 
alsu: ALSUN     
    generic map (
        N   => N)   
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
end architecture;
