-- (C) Alexandre Parodi - November 2000
--
-- File tprf.vhd
--
-- This file specifies a synchronous TRIPLE PORT (or channel) REGISTER FILE
-- of M words by N bits
--
-- Each port has one selector of size alpha in bits.
--
-- This memory has three ports (one input I, and two outputs A and B)
-- that be accessed simultaneously for reading and loading.
--
--
-- It uses an array of length STD_LOGIC_VECTORs of size N
-- that contain the words.
--
--                             I  
--                             |
--                             /N
--                             |
--                             v
--                       +-----------+
--             clock---->|>          |<----L
--                       |           |
--               INS---->|TRIPLE PORT|<----R
--                       | REG FILE  |
--               OAS---->|           |<----OBS
--                       +--+-----+--+
--                          |     | 
--                         N/     /N
--                          |     |
--                          v     v
--                          OA    OB
library ieee;
use ieee.std_logic_1164.all;

package subroutine_pack is
function convert_slv_to_int(slv: Std_Logic_Vector) return Integer;
-- this function converts a Std_Logic_Vector into an Integer
end package;

package body subroutine_pack is

function convert_slv_to_int(slv: Std_Logic_Vector) return Integer is

-- this function converts a Std_Logic_Vector into an Integer

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
        alpha: Integer := 2;  -- number of bits in address
        M:     Integer := 4;  -- number of registers 1 to 2**alpha
        N:     Integer := 4   -- number of bits in each word
        );
    port (
        clock: in     Std_Logic;                                  -- clock
        R:     in     Std_Logic;                                  -- reset command
        L:     in     Std_Logic;                                  -- load command
        ins:   in     Std_Logic_Vector(alpha-1 downto 0); -- location where to load
        oas:   in     Std_Logic_Vector(alpha-1 downto 0); -- location to read at OA
        obs:   in     Std_Logic_Vector(alpha-1 downto 0); -- location to read at OB
        i:     in     Std_Logic_Vector(N-1 downto 0);     -- data to load
        oa:    buffer Std_Logic_Vector(N-1 downto 0);     -- data output A
        ob:    buffer Std_Logic_Vector(N-1 downto 0)      -- data output B
        );
end entity;

architecture triple_port_reg_file_arc of TRIPLE_PORT_REG_FILE is

type Table_MN is array (0 to M-1) of std_logic_vector(N-1 downto 0);
signal REG: Table_MN;           -- M REGisters of size N bits content
signal index_a: Integer := 0; -- index to Table content for port output_A
signal index_b: Integer := 0; -- index to Table content for port output_B
signal index_i: Integer := 0; -- index to Table content for port input

begin

index_i <= convert_slv_to_int(ins);
index_a <= convert_slv_to_int(oas); -- Warp synthesizer needs this intermediate signal
index_b <= convert_slv_to_int(obs); -- converts the Std_Logic_Vector selector into Integer index

oa <= reg(index_a); -- this works because index_a is an Integer
ob <= reg(index_b);

reg_file_proc: process (clock)

begin
if (clock'event and clock = '1') then      -- if clock ^
    if (r = '1') then      
        reset_loop: for k in 0 to M-1 loop
	        reg(k) <= (others => '0');     --reg(k) <- 00..00
        end loop;
    elsif (L = '1') then
        reg(index_i) <= i;
    end if;
end if;

end process;

end architecture;
