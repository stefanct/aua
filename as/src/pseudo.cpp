#include "pseudo.h"
#include "as.h"

#include <map>

using namespace std;

typedef void (*replace_fun)(vector<loc>&, loc& l);

map<string, replace_fun> replace_functions;

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
	replace_functions["jmp"] = &_replace_jmp;
	replace_functions["rjmpi"] = &_replace_rjmpi;
}
