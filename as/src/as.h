#ifndef AS_H_
#define AS_H_

#include <iostream>
#include <map>
#include <vector>

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

struct loc{
	std::string src;
	std::string instr;
	std::vector<std::string> params;
	char opcode[2];
};

#endif /* AS_H_ */
