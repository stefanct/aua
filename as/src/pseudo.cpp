#include <stdlib.h>
#include <assert.h>

#include <boost/lexical_cast.hpp>

#include "pseudo.h"
#include "as.h"

#include <map>

using namespace std;
using namespace boost;

typedef void (*replace_fun)(vector<loc>&, loc& l);

map<string, replace_fun> replace_functions;

void _replace_nop(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "ldi";
	l_new.params.push_back("$0");
	l_new.params.push_back("0");
	locs.push_back(l_new);
}

void _replace_ret(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "brez";
	l_new.params.push_back("$0");
	l_new.params.push_back("$31");
	locs.push_back(l_new);
}

void _replace_jmp(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "brez";
	l_new.params.push_back("$0");
	l_new.params.push_back(l.params[0]);
	locs.push_back(l_new);
}

void _replace_rjmpi(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "brezi";
	l_new.params.push_back("$0");
	l_new.params.push_back(l.params[0]);
	locs.push_back(l_new);
}

void _replace_cmpgt(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "cmplte";
	l_new.params.push_back(l.params[1]);
	l_new.params.push_back(l.params[0]);
	locs.push_back(l_new);
}

void _replace_cmpgtu(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "cmplteu";
	l_new.params.push_back(l.params[1]);
	l_new.params.push_back(l.params[0]);
	locs.push_back(l_new);
}

void _replace_cmpgte(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "cmplt";
	l_new.params.push_back(l.params[1]);
	l_new.params.push_back(l.params[0]);
	locs.push_back(l_new);
}

void _replace_cmpgteu(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "cmpltu";
	l_new.params.push_back(l.params[1]);
	l_new.params.push_back(l.params[0]);
	locs.push_back(l_new);
}

void _replace_scb(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "scb";
	l_new.params.push_back(l.params[0]);
	const char* arg = l.params[1].c_str();
	char* end_ptr;
	int imm = strtol(arg, &end_ptr, 0);
	assert(arg!=end_ptr);
	assert(imm<16);
	assert(imm>0);
	imm+=l.instr[0]=='s'?16:0;
	DBG("imm: %d", imm);
	l_new.params.push_back(lexical_cast<string>(imm));
	locs.push_back(l_new);
}

void _replace_roti(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "roti";
	l_new.params.push_back(l.params[0]);
	const char* arg = l.params[1].c_str();
	char* end_ptr;
	int imm = strtol(arg, &end_ptr, 0);
	assert(arg!=end_ptr);
	assert(imm<16);
	assert(imm>0);
	imm+=l.instr[3]=='r'?16:0; // rotr? Nicht rotl
	l_new.params.push_back(lexical_cast<string>(imm));
	locs.push_back(l_new);
}

void _replace_swpb(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "roti";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("8");
	locs.push_back(l_new);
}

void _replace_set(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "not";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("$0");
	locs.push_back(l_new);
}

void _replace_clr(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "mov";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("$0");
	locs.push_back(l_new);
}

void _replace_inc(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "addi";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("1");
	locs.push_back(l_new);
}

void _replace_dec(vector<loc>& locs, loc& l){
	loc l_new;
	l_new.instr = "addi";
	l_new.params.push_back(l.params[0]);
	l_new.params.push_back("-1");
	locs.push_back(l_new);
}

void replace_pseudo_instructions(vector<loc>& locs, loc& l){
	replace_fun f = replace_functions[l.instr];
	if(f){
		f(locs, l);
	}
	else{
		locs.push_back(l);
	}
}

void load_pseudo_instructions(){
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
}
