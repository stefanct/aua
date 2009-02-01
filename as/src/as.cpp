#include <iostream>
#include <map>
#include <vector>

#include <assert.h>

#include <boost/lexical_cast.hpp>
#include <boost/regex.hpp>

#include "as.h"
#include "pseudo.h"
#include "msg.h"

using namespace std;
using namespace boost;

void removeComment(char* line) {
	char* pos;
	if ((pos = strstr(line, "--"))) {
		*pos = 0;
	}
	if ((pos = strchr(line, '!'))) {
		*pos = 0;
	}
}

string trim(const string& str) {
	size_t start = str.find_first_not_of(" \t\n");
	size_t end = str.find_last_not_of(" \t\n");
	if (string::npos == start || string::npos == end) {
		return "";
	} else {
		return str.substr(start, end - start + 1);
	}
}

As::As(const string& inputfile) :
	inputfile(inputfile), addr(0), error(0) {
	_load_config();
	load_pseudo_instructions();
}

void As::_load_config() {
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

void As::_precompile() {
	FILE* in = fopen(inputfile.c_str(), "r");
	char line[1024];

	regex reg_empty("\\s*");
	regex reg_label("(\\w+)\\:\\s*");
	regex reg_instr0("\\s*(\\w+)\\s*"); /* 0 Parameter */
	regex reg_instr1("\\s*(\\w+)\\s+([\\$\\w-]+)\\s*"); /* 1 Parameter */
	regex reg_instr2("\\s*(\\w+)\\s+([\\$\\w-]+)\\s*,\\s*([\\$\\w-]+)\\s*"); /* 1 Parameter */

	cmatch tokens;
	int cnt = 0;
	int line_number = 0;
	while (fgets(line, 1024, in) != NULL) {
		line_number++;
		removeComment(line);DBG("--------------\n\nPrecompiling: %s", line);
		string instr;
		string fields[3];
		int type_len = 0;
		bool copy_line = true;
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
			msg.err_syntax(line_number, line);
			copy_line = false;
			error = 1;
		}
		for (int i = 0; i <= type_len; i++) {
			fields[i].assign(tokens[i + 1].first, tokens[i + 1].second);
		}

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
			shared_ptr<loc> l(new loc());
			l->line = line_number;
			l->src = line;
			l->instr = fields[0];
			for (int i = 1; i <= type_len; i++) {
				DBG("Adding l.params: i: %d, fields[%d]: %s", i, i,
						fields[i].c_str());
				l->params.push_back(fields[i]);
			}
			if (replace_pseudo_instructions(*l) == 0) {
				program.push_back(l);
			}
		}
	}DBG("Precompile fertig");DBG("program.size(): %d", program.size());
	fclose(in);
}

int As::_compile_instr(loc& l) {
	DBG("l.instr: %s", l.instr.c_str());
	map<string, instruction>::iterator iter = instructions.find(l.instr);
	if (iter == instructions.end()) {
		msg.err_no_instr(l.line, l.instr);
		return -1;
	}
	instruction& i = iter->second;
	int type_len = l.params.size() * 3;
	DBG("l.params.size(): %d", l.params.size());DBG("type_len: %d, i.type.length: %d", type_len, i.type.length());
	if (type_len != i.type.length()) {
		msg.err_number_args(l.line, l.instr, i.type.length(), type_len);
		return -1;
	}

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
		case 's':
		case 'S':
		case 'h':
		case 'l': {
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
					msg.err_no_imm(l.line, l.params[field_cnt]);
					return -1;
				}
			}

			if (type == 'h') {
				if (imm < 0) {
					msg.err_no_signed(l.line, imm);
					return -1;
				}
				if (imm > 0xffff) {
					msg.warn_out_of_range_word(l.line, imm);
				}
				imm >>= 8;
				imm &= ((1 << cur_field_len) - 1);
			}

			else if (type == 'l') {
				if (imm < 0) {
					msg.err_no_signed(l.line, imm);
					return -1;
				}
				imm &= ((1 << cur_field_len) - 1);
			}

			else if (type == 'u') {
				if (imm >= (1 << cur_field_len)) {
					msg.err_out_of_range(l.line, imm, 0, ((1 << cur_field_len)
							- 1));
					return -1;
				}
			} else {
				if (imm >= (1 << (cur_field_len - 1)) || imm < -(1
						<< (cur_field_len - 1))) {
					msg.err_out_of_range(l.line, imm, -(1
							<< (cur_field_len - 1)), (1 << (cur_field_len - 1))
							- 1);
					return -1;
				}
			}
			bin_code |= ((imm & ((1 << cur_field_len) - 1)) << cur_field_pos);
			break;
		}
			/* register */
		case 'r':
			if (l.params[field_cnt][0] == '$') {
				char* end_ptr;
				const char* reg = l.params[field_cnt].c_str() + 1;
				int reg_num = strtol(reg, &end_ptr, 10);
				if (reg == end_ptr) {
					msg.err_no_reg(l.line, l.params[field_cnt]);
				}DBG("reg_num: %d", reg_num);
				assert(cur_field_len <= 5);
				assert(reg_num >= 0);
				assert(reg_num < (1 << cur_field_len));
				bin_code |= reg_num << (cur_field_pos);
			} else {
				msg.err_no_reg(l.line, l.params[field_cnt]);
				return -1;
			}
			break;
		default:
			break;
		}
		bit_cnt += cur_field_len;
		field_cnt++;
	}
	return bin_code;
}

void As::_compile() {
	vector<shared_ptr<loc> >::iterator iter = program.begin();
	for (; iter != program.end(); iter++) {
		loc& l = **iter;

		if (l.loc_replaced.size()) {
			vector<loc>::iterator it_replaced = l.loc_replaced.begin();
			for (; it_replaced != l.loc_replaced.end(); it_replaced++) {
				int bin = _compile_instr(*it_replaced);
				if (bin == -1) {
					error = 1;
				} else {
					char *p = (char*) &bin;
					it_replaced->opcode[0] = p[1];
					it_replaced->opcode[1] = p[0];
					addr += 2;
				}
			}
		} else {
			int bin = _compile_instr(l);
			if (bin == -1) {
				error = 1;
			} else {
				char *p = (char*) &bin;
				l.opcode[0] = p[1];
				l.opcode[1] = p[0];
				addr += 2;
			}
		}

	}
}

int As::compile() {
	msg.set_file(inputfile);
	msg.set_level(INFO);
	_precompile();
	_compile();
	msg.flush();
	return error;
}

void As::write_bin(const string& filename) {
	FILE* out = fopen(filename.c_str(), "w+");
	vector<shared_ptr<loc> >::iterator iter = program.begin();
	for (; iter != program.end(); iter++) {
		loc& l = **iter;

		if (l.loc_replaced.size()) {
			vector<loc>::iterator it_replaced = l.loc_replaced.begin();
			for (; it_replaced != l.loc_replaced.end(); it_replaced++) {
				fwrite(it_replaced->opcode, 2, 1, out);
			}
		} else {
			fwrite(l.opcode, 2, 1, out);
		}
	}

	fclose(out);
}

string As::_gen_rom_line(int addr, const loc& l, bool hex,
		const char* const orig_src) {
	stringstream ss;
	ss << "\t\twhen \"";
	for (int i = 15; i >= 0; i--) {
		ss << (addr & (1 << i) ? '1' : '0');
	}
	ss << "\" => data <= \"";
	for (int i = 7; i >= 0; i--) {
		ss << (l.opcode[0] & (1 << i) ? '1' : '0');
	}
	for (int i = 7; i >= 0; i--) {
		ss << (l.opcode[1] & (1 << i) ? '1' : '0');
	}
	ss << "\";\t-- ";
	ss << trim(l.src);
	if (orig_src) {
		ss << l.instr << " ";
		if(l.params.size()){
			ss << l.params[0];
		}
		for(int i=1; i<l.params.size(); i++){
			ss << ", " << l.params[i];
		}
		ss << " (" << trim(orig_src) << ")";
	}
	ss << "\n";
	return ss.str();
}

void As::write_rom(const string& file_out) {
	FILE* out = fopen(file_out.c_str(), "w");
	vector<shared_ptr<loc> >::iterator iter = program.begin();

	string header = "";
	header += "-- Program " + inputfile + ", generated ROM file\n" // TODO: programname
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

	bool hex = (settings["rom_hex"] == "1");
	if (hex) {
		msg.print_msg(WARN, 0,
				"Using hex addresses/values for ROM-file not implemented.");
	}

	int addr = strtol(settings["rom_start"].c_str(), NULL, 0);
	iter = program.begin();
	for (; iter != program.end(); iter++) {
		loc& l = **iter;
		int lines_replaced = l.loc_replaced.size();
		if (lines_replaced) {
			vector<loc>::iterator it_replaced = l.loc_replaced.begin();
			for (; it_replaced != l.loc_replaced.end(); it_replaced++) {
				string line = _gen_rom_line(addr, *it_replaced, hex,
						l.src.c_str());
				fwrite(line.c_str(), line.length(), 1, out);
				addr += 2;
			}
		} else {
			string line = _gen_rom_line(addr, l, hex, NULL);
			fwrite(line.c_str(), line.length(), 1, out);
			addr += 2;
		}
//		fwrite("\n", 1, 1, out);

	}

	string footer = "\t\twhen others => data <= \"0000000000000000\";\n"
		"\tend case;\n"
		"end process;\n"
		"\n"
		"end rtl;\n";

	fwrite(footer.c_str(), footer.length(), 1, out);
	fclose(out);
}
