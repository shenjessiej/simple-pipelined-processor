# Uttam Rao (ur6yr)
# An example file in our custom HCL variant, with lots of comments

register pP {  
    # our own internal register. P_pc is its output, p_pc is its input.
	pc:64 = 0; # 64-bits wide; 0 is its default value.
	
	# we could add other registers to the P register bank
	# register bank should be a lower-case letter and an upper-case letter, in that order.
	
	# there are also two other signals we can optionally use:
	# "bubble_P = true" resets every register in P to its default value
	# "stall_P = true" causes P_pc not to change, ignoring p_pc's value
} 

# "pc" is a pre-defined input to the instruction memory and is the 
# address to fetch 6 bytes from (into pre-defined output "i10bytes").
pc = P_pc;

# we can define our own input/output "wires" of any number of 0<bits<=80
wire opcode:8, icode:4, valC:64, rB:4, rA:4;

# the x[i..j] means "just the bits between i and j".  x[0..1] is the 
# low-order bit, similar to what the c code "x&1" does; "x&7" is x[0..3]
opcode = i10bytes[0..8];   # first byte read from instruction memory
icode = opcode[4..8];      # top nibble of that byte
valC = [
	icode == JXX : i10bytes[8..72];
	1	     : i10bytes[16..80];
];
rA = i10bytes[12..16];
rB = i10bytes[8..12];

/* we could also have done i10bytes[4..8] directly, but I wanted to
 * demonstrate more bit slicing... and all 3 kinds of comments      */
// this is the third kind of comment

# named constants can help make code readable
const TOO_BIG = 0xC; # the first unused icode in Y86-64

# some named constants are built-in: the icodes, ifuns, STAT_??? and REG_???



# Stat is a built-in output; STAT_HLT means "stop", STAT_AOK means 
# "continue".  The following uses the mux syntax described in the 
# textbook
Stat = [
	icode == NOP    : STAT_AOK;
	icode == JXX    : STAT_AOK;
	icode == IRMOVQ : STAT_AOK;
	icode == RRMOVQ : STAT_AOK;
	icode == HALT   : STAT_HLT;
	1               : STAT_INS;
];


# let's also read and write a register in the register file; to do that we
# first pick a register to read
reg_srcA = [
	icode == RRMOVQ : rA;
	1		: REG_NONE;
];
# and a register to write; in this case the same one
reg_dstE = [

	icode == IRMOVQ : rB;
	icode == RRMOVQ : rB;
	1		: REG_NONE;
];


# and a value to write.  Let's decide what to do based on the ifun
reg_inputE = [

	icode == IRMOVQ : valC;
	icode == RRMOVQ : reg_outputA;
	1		: 0;
];

# to make progress, we have to update the PC...

wire mux : 64;
mux = [

	icode == NOP    : P_pc + 1;
	icode == JXX    : valC;
	icode == IRMOVQ : P_pc + 10;
	icode == RRMOVQ : P_pc + 2;
	icode == HALT	: P_pc + 1;
	1	        : 0xBADBADBAD;
];
	

p_pc = mux; # you may use math ops directly...

