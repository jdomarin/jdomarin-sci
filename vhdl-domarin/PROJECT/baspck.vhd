-- (C) Alexandre Parodi - November 2004

-- File baspck.vhd

-- Defines package basic_pack:

-- Usual types: DByte, Byte, Nibble, Triad, Pair, Wire.

-- Basic components:

-- MUXN_2, MUXN_4;
-- LFFN, 
-- REGN, CNTN with initial data.

library ieee; 				 -- import IEEE LIBRARY			
use ieee.std_logic_1164.all; -- ALL items of STD_LOGIC_1164 PACKAGE

-- PACKAGE DEFINITION

package basic_pack is

-- USUAL TYPES

subtype DByte  is Std_Logic_Vector (15 downto 0); -- 16 bits word
subtype Byte   is Std_Logic_Vector (7 downto 0);  -- 8 bits word
subtype Pentad is Std_Logic_Vector (4 downto 0);  -- 5 bits word
subtype Nibble is Std_Logic_Vector (3 downto 0);  -- 4 bits word
subtype Triad  is Std_Logic_Vector (2 downto 0);  -- 3 bits word
subtype Pair   is Std_Logic_Vector (1 downto 0);  -- 2 bits word
subtype Wire   is Std_Logic;                      -- 1 bit


-- COMBINATORIAL COMPONENTS

component MUXN_2                   --2xN -> 1xN multiplexer
    generic(N: integer := 4);
    port(
	S:  in     std_logic;                       --1 bit select command
	X0: in     std_logic_vector(N-1 downto 0);  --N bits data input #0
	X1: in     std_logic_vector(N-1 downto 0);  --N bits data input #1
	Y:  buffer std_logic_vector(N-1 downto 0)); --N bits data output
end component;

component MUXN_4                   --4xN -> 1xN multiplexer
	generic(N: integer :=4);
	port(
	S:  in	   std_logic_vector(1 downto 0);	--2 bits select command
	X0: in	   std_logic_vector(N-1 downto 0);	--N bits data input #0
	X1: in	   std_logic_vector(N-1 downto 0);	--N bits data input #1
	X2: in	   std_logic_vector(N-1 downto 0);	--N bits data input #2
	X3: in	   std_logic_vector(N-1 downto 0);	--N bits data input #3
	Y:  buffer std_logic_vector(N-1 downto 0));	--N bits data output
end component;



-- SEQUENTIAL COMPONENTS

-- ASYNCHRONOUS SEQUENTIAL COMPONENTS

component LFFN               -- N bits Latch Flip-Flop
    generic(N: integer := 4);                      -- data width in bits
    port(
        G: in     std_logic;                       -- gate command
        D: in     std_logic_vector(N-1 downto 0);  -- data input
	Q: buffer std_logic_vector(N-1 downto 0)); -- data output
end component;


-- SYNCHRONOUS SEQUENTIAL COMPONENTS


component REGN               -- N bits REGister with reset
        generic(N: integer := 4);                     -- data width
        port(
        clock:  in   std_logic;                       --clock
        R:    in     std_logic;                       --reset command
        L:    in     std_logic;                       --load command
        D:    in     std_logic_vector(N-1 downto 0);  --data input
        Q:    buffer std_logic_vector(N-1 downto 0)); --data output
end component;

component CNTN               -- N bits synchronous binary counter with reset and initial data input
    generic (N: integer :=4);	                      --data width
    port(
        clock: in     std_logic;                      --clock
        R:     in     std_logic;                      --synchronous reset
        L:     in     std_logic;                      --load command
        T:     in     std_logic;                      --increment command
        V:     in     std_logic_vector(N-1 downto 0); --init data input
	D:     in     std_logic_vector(N-1 downto 0); --data input
        Q:     buffer std_logic_vector(N-1 downto 0); --count output
        C:     buffer std_logic                       --carry output
        );
end component;


end package;