#include <iostream>
#include <map>
#include <vector>

#include <assert.h>

#include <boost/lexical_cast.hpp>
#include <boost/regex.hpp>

#include "as.h"
#include "pseudo.h"

using namespace std;
using namespace boost;

std::map<std::string, instruction> instructions;
std::map<std::string, int> labels;
std::vector<loc> lines_prec;

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
	fclose(file);
}

void precompile(const string& filename, const string& file_precomp) {
	FILE* in = fopen(filename.c_str(), "r");
	FILE* out = fopen(file_precomp.c_str(), "w+");
	char line[1024];

	regex reg_empty("\\s*");
	regex reg_label("(\\w+)\\:\\s*");
	regex reg_instr1("\\s*(\\w+)\\s+([\\$\\w]+)\\s*"); /* 1 Parameter */
	regex reg_instr2("\\s*(\\w+)\\s+([\\$\\w]+)\\s*,\\s*([\\$\\w]+)\\s*"); /* 1 Parameter */

	cmatch tokens;
	int cnt = 0;
	while (fgets(line, 1024, in) != NULL) {
		removeComment(line);
		cout << "--------------\n\nPrecompiling: " << line << endl;
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

		bool copy_line = true;
		if (regex_match(line, tokens, reg_label)) {
			string label;
			label.assign(tokens[1].first, tokens[1].second);
			labels[label] = cnt;
		} else {
			if (regex_match(line, tokens, reg_empty)) {
				copy_line = false;
			}
			else{
				cnt += 2;
			}
		}
		if(copy_line){
			loc l;
			l.instr = fields[0];
			for(int i=1; i<=type_len; i++){
				cout << "Adding l.params: i: " << i << ", fields[i]: " << fields[i] << endl;
				l.params.push_back(fields[i]);
			}
			vector<loc> locs;
			replace_pseudo_instructions(locs, l);
			for(int i=0; i<locs.size(); i++){
				lines_prec.push_back(locs[i]);
			}
		}
	}
	fclose(in);
	fclose(out);
}

void compile(const string& file_in, const string& file_out) {
	FILE* in = fopen(file_in.c_str(), "r");
	FILE* out = fopen(file_out.c_str(), "w+");
	fseek(in, 0, SEEK_SET);
	char line[1024];

	vector<loc>::iterator iter = lines_prec.begin();
	for(; iter!=lines_prec.end(); iter++){
		loc& l = *iter;
		cout << "l.instr: " << l.instr << endl;
		instruction i = instructions[l.instr];
		int type_len = l.params.size()*3;
		cout << "l.params.size(): " << l.params.size() << endl;
		cout << "type_len: " << type_len << ", i.type.length: " << i.type.length() << endl;
		assert(type_len == i.type.length());

		int bin_code = i.opcode << 10;
		int bit_cnt = 0;
		int field_cnt = 0;

		for (int cnt = 0; cnt < type_len; cnt += 3) {
			cout << "foo" << endl;
			cout << "field_cnt: " << field_cnt << endl;
			cout << "l.params[field_cnt][" << field_cnt << "]: " << l.params[field_cnt][0] << endl;
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
					imm = lexical_cast<int> (l.params[field_cnt]);
				} catch (bad_lexical_cast& e) {
					valid = false;
				}
				if (!valid) {
					map<string, int>::iterator iter = labels.find(
							l.params[field_cnt]);
					if (iter != labels.end()) {
						imm = iter->second;
					}
				}
				assert(imm < (1<<cur_field_len));
				bin_code |= imm << (cur_field_pos);
				break;
			}
			case 'r':
				if (l.params[field_cnt][0] == '$') {
					int reg_num = strtol(l.params[field_cnt].c_str() + 1, NULL,
					10);
					cout << "reg_num: " << reg_num << endl;
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
		cout << "-----------------------" << endl << endl;
	}
	fclose(in);
	fclose(out);
}

void gen_rom(string file_in, string file_out) {
	FILE* in = fopen(file_in.c_str(), "r");
	FILE* out = fopen(file_out.c_str(), "w+");
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
		addr+=2;
	}

	string footer = "\t\twhen others => data <= \"0000000000000000\";\n"\
		"\tend case;\n"\
		"end process;\n"\
		"\n"\
		"end rtl;\n";

	fwrite(footer.c_str(), footer.length(), 1, out);
	fclose(in);
	fclose(out);
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
	load_pseudo_instructions();

	string file_in = argv[optind];
	string file_out = argv[optind+1];
	string file_precomp = file_out + ".pre";
	//string file_rom = file_out + ".rom";
	string file_rom = "../hw/src/mmu/rom.vhd";

	precompile(file_in, file_precomp);
	compile(file_precomp, file_out);
	if (create_rom) {
		gen_rom(file_out, file_rom);
	}
}
