#include <stdlib.h>
#include <assert.h>

#include <boost/lexical_cast.hpp>

#include "pseudo.h"
#include "as.h"
#include "msg.h"

#include <map>

using namespace std;
using namespace boost;

typedef int (*replace_fun)(loc& l);

map<string, replace_fun> replace_functions;

Msg msg;

int _replace_nop(loc& l) {
	loc l_new;
	l_new.instr = "ldi";
	l_new.params.push_back("$0");
	l_new.params.push_back("0");
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_ret(loc& l) {
	loc l_new;
	l_new.instr = "brez";
	l_new.params.push_back("$0");
	l_new.params.push_back("$31");
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_jmp(loc& l) {
	loc l_new;
	l_new.instr = "brez";
	l_new.params.push_back("$0");
	l_new.params.push_back(l.params[0]);
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_rjmpi(loc& l) {
	loc l_new;
	l_new.instr = "brezi";
	l_new.params.push_back("$0");
	l_new.params.push_back(l.params[0]);
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_cmpgt(loc& l) {
	loc l_new;
	l_new.instr = "cmplte";
	l_new.params.push_back(l.params[1]);
	l_new.params.push_back(l.params[0]);
	l.loc_replaced.push_back(l_new);
	return 0;
}

int _replace_cmpgtu(loc& l) {
	loc l_new;
	l_new.instr = "cmplteu";
	l_new.params.push_back(l.params[1]);
	l_new.params.push_back(l.params[0]);
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_cmpgte(loc& l) {
	loc l_new;
	l_new.instr = "cmplt";
	l_new.params.push_back(l.params[1]);
	l_new.params.push_back(l.params[0]);
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_cmpgteu(loc& l) {
	loc l_new;
	l_new.instr = "cmpltu";
	l_new.params.push_back(l.params[1]);
	l_new.params.push_back(l.params[0]);
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_scb(loc& l) {
	loc l_new;
	l_new.instr = "scb";
	l_new.params.push_back(l.params[0]);
	const char* arg = l.params[1].c_str();
	char* end_ptr;
	int imm = strtol(arg, &end_ptr, 0);
	assert(arg!=end_ptr);
	assert(imm<16);
	assert(imm>0);
	imm += l.instr[0] == 's' ? 16 : 0;DBG("imm: %d", imm);
	l_new.params.push_back(lexical_cast<string> (imm));
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_roti(loc& l) {
	loc l_new;
	l_new.instr = "roti";
	l_new.params.push_back(l.params[0]);
	const char* arg = l.params[1].c_str();
	char* end_ptr;
	int imm = strtol(arg, &end_ptr, 0);
	assert(arg!=end_ptr);
	assert(imm<16);
	assert(imm>0);
	imm += l.instr[3] == 'r' ? 16 : 0; // rotr? Nicht rotl
	l_new.params.push_back(lexical_cast<string> (imm));
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_swpb(loc& l) {
	loc l_new;
	l_new.instr = "roti";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("8");
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_set(loc& l) {
	loc l_new;
	l_new.instr = "not";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("$0");
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_clr(loc& l) {
	loc l_new;
	l_new.instr = "mov";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("$0");
	l.loc_replaced.push_back(l_new);
	return 0;
}

int _replace_inc(loc& l) {
	loc l_new;
	l_new.instr = "addi";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("1");
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_dec(loc& l) {
	loc l_new;
	l_new.instr = "addi";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("-1");
	l.loc_replaced.push_back(l_new);
	return 1;
}

int _replace_ldiw(loc& l) {
	loc l_new[3];

	l_new[0].instr = "ldih";
	l_new[0].params.push_back(l.params[0]);
	l_new[0].params.push_back(l.params[1]);
	l.loc_replaced.push_back(l_new[0]);

	l_new[1].instr = "lsli";
	l_new[1].params.push_back(l.params[0]);
	l_new[1].params.push_back("8");
	l.loc_replaced.push_back(l_new[1]);

	l_new[2].instr = "ldil";
	l_new[2].params.push_back(l.params[0]);
	l_new[2].params.push_back(l.params[1]);
	l.loc_replaced.push_back(l_new[2]);
	return 3;
}

int _replace_push(loc& l) {
	loc l_new[2];

	l_new[0].instr = "st";
	l_new[0].params.push_back(l.params[0]);
	l_new[0].params.push_back("$sp");
	l.loc_replaced.push_back(l_new[0]);

	l_new[1].instr = "addi";
	l_new[1].params.push_back("$sp");
	l_new[1].params.push_back("-2");
	l.loc_replaced.push_back(l_new[1]);

	return 2;
}

int _replace_pop(loc& l){
	loc l_new[2];

	l_new[0].instr = "addi";
	l_new[0].params.push_back("$sp");
	l_new[0].params.push_back("2");
	l.loc_replaced.push_back(l_new[0]);

	l_new[1].instr = "ld";
	l_new[1].params.push_back(l.params[0]);
	l_new[1].params.push_back("$sp");
	l.loc_replaced.push_back(l_new[1]);

	return 2;
}

int _replace_call(loc& l){
	loc l_new[5];

	l_new[0].instr = "st";
	l_new[0].params.push_back("$ra");
	l_new[0].params.push_back("$sp");
	l.loc_replaced.push_back(l_new[0]);

	l_new[1].instr = "addi";
	l_new[1].params.push_back("$sp");
	l_new[1].params.push_back("-2");
	l.loc_replaced.push_back(l_new[1]);

	l_new[2].instr = "jmpl";
	l_new[2].params.push_back(l.params[0]);
	l.loc_replaced.push_back(l_new[2]);

	l_new[3].instr = "addi";
	l_new[3].params.push_back("$sp");
	l_new[3].params.push_back("2");
	l.loc_replaced.push_back(l_new[3]);

	l_new[4].instr = "ld";
	l_new[4].params.push_back("$ra");
	l_new[4].params.push_back("$sp");
	l.loc_replaced.push_back(l_new[4]);

	return 5;
}

int replace_pseudo_instructions(loc& l) {
	replace_fun f = replace_functions[l.instr];
	if (f) {
		return f(l);
	}
	return 1;
}

void load_pseudo_instructions() {
	replace_functions["nop"] = &_replace_nop;
	replace_functions["ret"] = &_replace_ret;
	replace_functions["jmp"] = &_replace_jmp;
	replace_functions["rjmpi"] = &_replace_rjmpi;
	replace_functions["cmpgt"] = &_replace_cmpgt;
	replace_functions["cmpgtu"] = &_replace_cmpgtu;
	replace_functions["cmpgte"] = &_replace_cmpgte;
	replace_functions["cmpgteu"] = &_replace_cmpgteu;
	replace_functions["sb"] = &_replace_scb;
	replace_functions["cb"] = &_replace_scb;
	replace_functions["rotr"] = &_replace_roti;
	replace_functions["rotl"] = &_replace_roti;
	replace_functions["swpb"] = &_replace_swpb;
	replace_functions["set"] = &_replace_set;
	replace_functions["clr"] = &_replace_clr;
	replace_functions["inc"] = &_replace_inc;
	replace_functions["dec"] = &_replace_dec;
	replace_functions["ldiw"] = &_replace_ldiw;
	replace_functions["push"] = &_replace_push;
	replace_functions["pop"] = &_replace_pop;
	replace_functions["call"] = &_replace_call;
}
