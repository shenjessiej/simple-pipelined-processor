########## the PC and condition codes registers #############
register fF { pc:64 = 0; }


########## Fetch #############
pc = F_pc;


d_icode = i10bytes[4..8];
d_ifun = i10bytes[0..4];
d_rA = i10bytes[12..16];
d_rB = i10bytes[8..12];

d_valC = [
	d_icode in { JXX } : i10bytes[8..72];
	1 : i10bytes[16..80];
];

wire offset:64, valP:64;
offset = [
	d_icode in { HALT, NOP, RET } : 1;
	d_icode in { RRMOVQ, OPQ, PUSHQ, POPQ } : 2;
	d_icode in { JXX, CALL } : 9;
	1 : 10;
];
valP = F_pc + offset;


########## Decode #############

d_Stat = [
	d_icode == HALT : STAT_HLT;
	d_icode > 0xb : STAT_INS;
	1 : STAT_AOK;
];


# destination selection
d_dstE = [
	d_icode in {IRMOVQ, RRMOVQ} : d_rB;
	1 : REG_NONE;
];

# source selection
reg_srcA = [
	d_icode in {RRMOVQ} : d_rA;
	1 : REG_NONE;
];

register dW {
	
	icode:4 = NOP;
	ifun:4 = 0;
	rA:4 = REG_NONE;
	rB:4 = REG_NONE;
	valC:64	= 0;
	rvalA:64 = 0;
	dstE:4 = REG_NONE;
	Stat:3 = STAT_AOK;
	
}

d_rvalA = [
	reg_dstE == reg_srcA && reg_srcA != REG_NONE : reg_inputE;
	1 : reg_outputA
];


########## Execute #############



########## Memory #############




########## Writeback #############

reg_dstE = W_dstE;


reg_inputE = [ # unlike book, we handle the "forwarding" actions (something + 0) here
	W_icode == RRMOVQ : W_rvalA;
	W_icode in {IRMOVQ} : W_valC;
        1: 0xBADBADBAD;
];



########## PC and Status updates #############
Stat = W_Stat;


f_pc = valP;



