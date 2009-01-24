#include <iostream>
#include <map>

#include <assert.h>

#include <boost/lexical_cast.hpp>
#include <boost/regex.hpp>

#define INSTR_CONFIG "resources/instructions.conf"

#define NUM_REGS 32

using namespace std;
using namespace boost;

struct instruction {
	int opcode;
	string type;
};

map<string, instruction> instructions;
map<string, int> labels;

void usage() {
	cerr << "Usage: as [-r] input.as output" << endl;
}

void removeComment(char* line) {
	char* pos;
	if ((pos = strstr(line, "--"))) {
		*pos = 0;
	}
	if ((pos = strchr(line, '!'))) {
		*pos = 0;
	}
}

void loadInstructions() {
	FILE* file = fopen(INSTR_CONFIG, "r");
	char line[1024];
	regex reg_instr("(\\w+)\\s+(\\w+)\\s+(\\w+)\\s*");
	regex reg_empty("\\s*");
	cmatch tokens;
	while (fgets(line, 1024, file) != NULL) {
		removeComment(line);
		if (regex_match(line, tokens, reg_instr)) {
			string opcode(tokens[2].first, tokens[2].second);
			instruction i;
			i.opcode = strtol(opcode.c_str(), NULL, 0);
			i.type.assign(tokens[3].first, tokens[3].second);
			string iname(tokens[1].first, tokens[1].second);
			instructions[iname] = i;
		} else if (!regex_match(line, tokens, reg_empty)) {
			cerr << "Invalid instruction configuration: \"" << line
					<< "\", ignoring. " << endl;
		}
	}
}

void findLabels(FILE* file) {
	char line[1024];
	regex reg_label("(\\w+)\\:\\s*");
	regex reg_empty("\\s*");

	cmatch tokens;
	int cnt = 0;
	while (fgets(line, 1024, file) != NULL) {
		removeComment(line);
		if (regex_match(line, tokens, reg_label)) {
			string label;
			label.assign(tokens[1].first, tokens[1].second);
			labels[label] = cnt;
		} else {
			if (!regex_match(line, tokens, reg_empty)) {
				cnt += 2;
			}
		}
	}
}

void compile(FILE* in, FILE* out, bool create_rom) {
	fseek(in, 0, SEEK_SET);
	char line[1024];

	regex reg_empty("\\s*");
	regex reg_label("(\\w+)\\:\\s*");
	regex reg_instr1("\\s*(\\w+)\\s+([\\$\\w]+)\\s*"); /* 1 Parameter */
	regex reg_instr2("\\s*(\\w+)\\s+([\\$\\w]+)\\s*,\\s*([\\$\\w]+)\\s*"); /* 1 Parameter */

	cmatch tokens;

	while (fgets(line, 1024, in) != NULL) {
		removeComment(line);
		string instr;
		string fields[3];
		int type_len = 0;
		if (regex_match(line, tokens, reg_empty)) {
			continue;
		} else if (regex_match(line, tokens, reg_label)) {
			continue;
		} else if (regex_match(line, tokens, reg_instr1)) {
			type_len = 1;
		} else if (regex_match(line, tokens, reg_instr2)) {
			type_len = 2;
		} else {
			assert(0);
		}
		for (int i = 0; i <= type_len; i++) {
			fields[i].assign(tokens[i + 1].first, tokens[i + 1].second);
		}
		type_len *= 3;

		instr.assign(tokens[1].first, tokens[1].second);
		instruction i = instructions[instr];
		assert(type_len == i.type.length());

		int bin_code = i.opcode << 10;
		int bit_cnt = 0;
		int field_cnt = 1;

		for (int cnt = 0; cnt < type_len; cnt += 3) {
			char tmp[2] = { 0, 0 };
			tmp[0] = i.type[cnt + 1];
			int cur_field_pos = strtol(tmp, NULL, 16);
			tmp[0] = *(i.type.c_str() + cnt + 2);
			int cur_field_len = strtol(tmp, NULL, 16);
			switch (i.type[cnt]) {
			case 'i': {
				int imm = 0;
				bool valid = true;
				try {
					imm = lexical_cast<int> (fields[field_cnt]);
				} catch (bad_lexical_cast& e) {
					valid = false;
				}
				if (!valid) {
					map<string, int>::iterator iter = labels.find(
							fields[field_cnt]);
					if (iter != labels.end()) {
						imm = iter->second;
					}
				}
				assert(imm < (1<<cur_field_len));
				bin_code |= imm << (cur_field_pos);
				break;
			}
			case 'r':
				if (fields[field_cnt][0] == '$') {
					int reg_num = strtol(fields[field_cnt].c_str() + 1, NULL,
					10);
					assert(cur_field_len<=5);
					assert(reg_num>=0);
					assert(reg_num<(1<<cur_field_len));
					bin_code |= reg_num << (cur_field_pos);
				}
				break;
			default:
				break;
			}
			bit_cnt += cur_field_len;
			field_cnt++;
		}
		char *p = (char*) &bin_code;
		fwrite(p + 1, 1, 1, out);
		fwrite(p, 1, 1, out);
	}
}

void gen_rom(FILE* in, FILE* out) {
	string header = "";
	header+= "-- ROM file, generated\n"\
	"\n"\
	"library ieee;\n"\
	"use ieee.std_logic_1164.all;\n"\
	"\n"\
	"entity rom is\n"\
	"generic (width : integer; addr_width : integer); -- for compatibility\n"\
	"port (\n"\
	"\t\tclk : in std_logic;\n"\
	"\t\taddress : in std_logic_vector(15 downto 0);\n"\
	"\t\tq : out std_logic_vector(15 downto 0)\n"\
	");\n"\
	"end rom;\n"\
	"\n"\
	"architecture rtl of rom is\n"\
	"\n"\
	"signal areg : std_logic_vector(15 downto 0);\n"\
	"signal data : std_logic_vector(15 downto 0);\n"\
	"\n"\
	"begin\n"\
	"\n"\
	"process(clk) begin\n"\
	"\n"\
	"if rising_edge(clk) then\n"\
	"\tareg <= address;\n"\
	"end if;\n"\
	"\n"\
	"end process;\n"\
	"\n"\
	"q <= data;\n"\
	"\n"\
	"process(areg) begin\n"\
	"\n"\
	"\tcase arg is\n";
	fwrite(header.c_str(), header.length(), 1, out);

	fseek(in, 0, SEEK_SET);
	char buffer[2];
	int addr = 0;
	while (fread(buffer, 2, 1, in) == 1) {
		string line_out = "\t\twhen \"";
		for (int i = 15; i >= 0; i--) {
			line_out += addr & (1 << i) ? '1' : '0';
		}
		line_out += "\" => data <= \"";
		for (int i = 7; i >= 0; i--) {
			line_out += buffer[0] & (1 << i) ? '1' : '0';
		}
		for (int i = 7; i >= 0; i--) {
			line_out += buffer[1] & (1 << i) ? '1' : '0';
		}
		line_out += "\";\n";
		fwrite(line_out.c_str(), line_out.length(), 1, out);
	}

	string footer = "\t\twhen others => data <= \"00000000\";\n"\
		"\tend case;\n"\
		"end process;\n"\
		"\n"\
		"end rtl;\n";

	fwrite(footer.c_str(), footer.length(), 1, out);

}

int main(int argc, char** argv) {
	if (argc < 3) {
		usage();
		exit(1);
	}

	bool create_rom = false;

	int c;
	while ((c = getopt(argc, argv, "r")) != -1) {
		switch (c) {
		case 'r':
			create_rom = true;
			break;
		default:
			usage();
			exit(1);
		}
	}

	loadInstructions();

	FILE* file_in = fopen(argv[optind], "r");
	FILE* file_out = fopen(argv[optind + 1], "w+");
	FILE* file_rom = NULL;
	if (create_rom) {
		string rom(argv[optind + 1]);
		rom += ".rom";
		file_rom = fopen(rom.c_str(), "w+");
	}

	findLabels(file_in);
	compile(file_in, file_out, create_rom);
	if (create_rom) {
		gen_rom(file_out, file_rom);
	}

	fclose(file_in);
	fclose(file_out);
	if (create_rom) {
		fclose(file_rom);
	}
}
