#ifndef AS_H_
#define AS_H_

#include <iostream>
#include <map>
#include <vector>

#include <boost/shared_ptr.hpp>

#include "msg.h"

using namespace std;
using namespace boost;

#define INSTR_CONFIG "resources/aua.conf"

#define NUM_REGS 32

#ifdef DEBUG
#define DBG(...) cout << __FILE__ << ": " << __LINE__ <<": "; printf(__VA_ARGS__); printf("\n");
#else
#define DBG(...)
#endif

struct instruction {
	int opcode;
	std::string type;
};

struct loc {
	std::string src;
	int line;
	std::string instr;
	std::vector<std::string> params;
	char opcode[2];
	std::vector<loc> loc_replaced;
};

class As {

	string inputfile;

	int addr;

	int error;

	Msg msg;

	std::map<string, instruction> instructions;
	std::map<string, string> settings;
	std::map<string, int> labels;
	std::vector<shared_ptr<loc> > program;

	void _load_config();
	void _precompile();
	int _compile_instr(loc& l);
	void _compile();
	std::string _gen_rom_line(int addr, const loc& l, bool hex, const char* const orig_src);

public:
	As(const std::string&);
	int compile();
	void write_bin(const string&);
	void write_rom(const std::string&);

};

#endif /* AS_H_ */
