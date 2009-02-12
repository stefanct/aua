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
	std::string file;
	int line;
	std::string src;
	std::string instr;
	std::vector<std::string> params;
	char opcode[2];
	std::vector<loc> loc_replaced;
};

enum CONST_TYPE {CONST_INT=0, CONST_STRING=1, CONST_ARRAY=2};

class constant {
public:
	CONST_TYPE type;
	int address;
	std::string str_value;
	int i_value;

	constant() :
		type(CONST_INT), address(0), str_value(""), i_value(0) {
	}

	constant(CONST_TYPE type, int address, const std::string& str_value,
			int i_value) :
		type(type), address(address), str_value(str_value), i_value(
				i_value) {
	}
};

class As {

	string inputfile;

	int addr;
	int cnt_instr;

	int error;

	Msg msg;

	std::map<string, instruction> instructions;
	std::map<string, string> settings;
	std::map<string, int> labels;
	std::map<string, constant> constants;
	std::vector<shared_ptr<loc> > program;
	std::map<std::string, std::string> registers;

	void _load_config();
	int _add_constant(const std::string& key, const std::string& constant);
	void _precompile(const std::string& file);
	void _set_const_addresses();
	int _compile_instr(loc& l);
	void _compile();
	std::string _gen_rom_line(int addr, const loc& l, bool hex,
			const char* const orig_src);

public:
	As(const std::string&);
	int compile();
	void write_bin(const string&);
	void write_rom(const std::string&);

};

#endif /* AS_H_ */
