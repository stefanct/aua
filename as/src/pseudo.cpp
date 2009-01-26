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
	replace_functions["jmp"] = &_replace_jmp;
	replace_functions["rjmpi"] = &_replace_rjmpi;
	replace_functions["sb"] = &_replace_scb;
	replace_functions["cb"] = &_replace_scb;
	replace_functions["rotr"] = &_replace_roti;
	replace_functions["rotl"] = &_replace_roti;
}
