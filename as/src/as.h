#ifndef AS_H_
#define AS_H_

#include <iostream>
#include <map>
#include <vector>

#define INSTR_CONFIG "resources/aua.conf"

#define NUM_REGS 32

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
