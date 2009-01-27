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

std::map<string, instruction> instructions;
std::map<string, string> settings;
std::map<string, int> labels;
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

void loadConfig() {
	FILE* file = fopen(INSTR_CONFIG, "r");
	char line[1024];
	regex reg_instr("(\\w+)\\s+(\\w+)\\s+(\\w+)\\s*");
	regex reg_setting("\\s*(\\w+)\\s*=\\s*(\\w+)\\s*");
	regex reg_empty("\\s*");
	cmatch tokens;
	while (fgets(line, 1024, file) != NULL) {
		removeComment(line);
		if (regex_match(line, tokens, reg_setting)) {
			string key(tokens[1].first, tokens[1].second);
			string value(tokens[2].first, tokens[2].second);
			settings[key] = value;
		} else if (regex_match(line, tokens, reg_instr)) {
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
	regex reg_instr0("\\s*(\\w+)\\s*"); /* 0 Parameter */
	regex reg_instr1("\\s*(\\w+)\\s+([\\$\\w-]+)\\s*"); /* 1 Parameter */
	regex reg_instr2("\\s*(\\w+)\\s+([\\$\\w-]+)\\s*,\\s*([\\$\\w-]+)\\s*"); /* 1 Parameter */

	cmatch tokens;
	int cnt = 0;
	while (fgets(line, 1024, in) != NULL) {
		removeComment(line);DBG("--------------\n\nPrecompiling: ");
		string instr;
		string fields[3];
		int type_len = 0;
		if (regex_match(line, tokens, reg_empty)) {
			continue;
		} else if (regex_match(line, tokens, reg_label)) {
		} else if (regex_match(line, tokens, reg_instr0)) {
			type_len = 0;
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
			labels[label] = cnt;DBG("Found label: %s: %d", label.c_str(), cnt);
			copy_line = false;
		} else {
			if (regex_match(line, tokens, reg_empty)) {
				copy_line = false;
			} else {
				cnt += 2;
			}
		}
		if (copy_line) {
			loc l;
			l.instr = fields[0];
			for (int i = 1; i <= type_len; i++) {
				DBG("Adding l.params: i: %d, fields[%d]: %s", i, i, fields[i].c_str());
				l.params.push_back(fields[i]);
			}
			vector<loc> locs;
			replace_pseudo_instructions(locs, l);
			for (int i = 0; i < locs.size(); i++) {
				lines_prec.push_back(locs[i]);
			}
		}
	}
	fclose(in);
	fclose(out);
}

void compile(const string& file_in, const string& file_out) {
	int foo = 7;
	FILE* in = fopen(file_in.c_str(), "r");
	FILE* out = fopen(file_out.c_str(), "w+");
	fseek(in, 0, SEEK_SET);
	char line[1024];
	int addr = 0;

	vector<loc>::iterator iter = lines_prec.begin();
	for (; iter != lines_prec.end(); iter++) {
		loc& l = *iter;
		DBG("l.instr: %s", l.instr.c_str());
		instruction i = instructions[l.instr];
		int type_len = l.params.size() * 3;
		DBG("l.params.size(): %d", l.params.size());DBG("type_len: %d, i.type.length: %d", type_len, i.type.length());
		assert(type_len == i.type.length());

		int bin_code = i.opcode << 10;
		DBG("opcode: %x", i.opcode << 10);
		int bit_cnt = 0;
		int field_cnt = 0;

		for (int cnt = 0; cnt < type_len; cnt += 3) {
			DBG("field_cnt: %d", field_cnt);
			char tmp[2] = { 0, 0 };
			tmp[0] = i.type[cnt + 1];
			int cur_field_pos = strtol(tmp, NULL, 16);
			tmp[0] = *(i.type.c_str() + cnt + 2);
			int cur_field_len = strtol(tmp, NULL, 16);
			char type = i.type[cnt];
			switch (type) {
			/* signed oder unsigned immediate */
			case 'u':
			case 'U':
				DBG("u");
			case 's':
			case 'S': {
				DBG("s");
				const char* param = l.params[field_cnt].c_str();
				char* end_ptr;
				DBG(param);
				int imm = strtol(param, &end_ptr, 0);
				bool valid = param != end_ptr;
				if (!valid) {
					map<string, int>::iterator iter = labels.find(
							l.params[field_cnt]);
					if (iter != labels.end()) {
						if (isupper(type)) { // Adresse relativ
							imm = iter->second - addr;
						} else {
							imm = iter->second;
						}DBG("imm: %d", imm);
					} else {
						cerr << "Immediate \"" << l.params[field_cnt]
								<< "\" invalid." << endl;
						exit(1);
					}
				}
				if (type == 'u') {
					if (imm >= (1 << cur_field_len)) {
						cerr << l.instr << ": value " << imm
								<< " out of range: [0.." << ((1
								<< cur_field_len) - 1) << "]" << endl;
						exit(1);
					}
				} else {
					if (imm >= (1 << (cur_field_len - 1)) || imm < -(1
							<< (cur_field_len - 1))) {
						cerr << l.instr << ": value " << imm
								<< " out of range: [-" << (1 << (cur_field_len-1))
								<< ".." << (1 << (cur_field_len-1)) - 1 << "]"
								<< endl;
						exit(1);
					}
				}
				bin_code |= ((imm & ((1 << cur_field_len) - 1))
						<< cur_field_pos);
				break;
			}
				/* register */
			case 'r':
				if (l.params[field_cnt][0] == '$') {
					int reg_num = strtol(l.params[field_cnt].c_str() + 1, NULL,
					10);
					DBG("reg_num: %d", reg_num);
					assert(cur_field_len<=5);
					assert(reg_num>=0);
					assert(reg_num<(1<<cur_field_len));
					bin_code |= reg_num << (cur_field_pos);
				} else {
					assert(0); // TODO: evtl. Labels ersetzen
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
		fwrite(p, 1, 1, out);DBG("----------------\n");
		addr += 2;
	}
	fclose(in);
	fclose(out);
}

void gen_rom(string file_in, string file_out) {
	vector<loc>::iterator iter = lines_prec.begin(); // PFUSCH
	iter = lines_prec.begin(); // PFUSCH
	FILE* in = fopen(file_in.c_str(), "r");
	FILE* out = fopen(file_out.c_str(), "w");
	DBG("out: %p", out);
	string header = "";
	header += "-- Program " + file_in + ", generated ROM file\n"
		"\n"
		"library ieee;\n"
		"use ieee.std_logic_1164.all;\n"
		"\n"
		"entity rom is\n"
		"port (\n"
		"\t\tclk : in std_logic;\n"
		"\t\taddress : in std_logic_vector(15 downto 0);\n"
		"\t\tq : out std_logic_vector(15 downto 0)\n"
		");\n"
		"end rom;\n"
		"\n"
		"architecture rtl of rom is\n"
		"\n"
		"signal data : std_logic_vector(15 downto 0);\n"
		"\n"
		"begin\n"
		"\n"
		"q <= data;\n"
		"\n"
		"process(address) begin\n"
		"\n"
		"\tcase address is\n";
	fwrite(header.c_str(), header.length(), 1, out);

	fseek(in, 0, SEEK_SET);
	char buffer[2];
	int addr = strtol(settings["rom_start"].c_str(), NULL, 0);
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
		line_out += "\";";
		fwrite(line_out.c_str(), line_out.length(), 1, out);
		addr += 2;

		// <PFUSCH>
		string dreck = "\t-- ";
		dreck += iter->instr;
		for (int i = 0; i < iter->params.size(); i++) {
			dreck += " ";
			dreck += iter->params[i];
		}
		dreck += "\n";
		fwrite(dreck.c_str(), dreck.length(), 1, out);
		iter++;
		// </PFUSCH>
	}

	string footer = "\t\twhen others => data <= \"0000000000000000\";\n"
		"\tend case;\n"
		"end process;\n"
		"\n"
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

	loadConfig();
	load_pseudo_instructions();

	string file_in = argv[optind];
	string file_out = argv[optind + 1];
	string file_precomp = file_out + ".pre";
	string file_rom = "../hw/mmu/src/rom.vhd";

	precompile(file_in, file_precomp);
	compile(file_precomp, file_out);
	if (create_rom) {
		gen_rom(file_out, file_rom);
	}
}
