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

string trim(const string& str, const char* trim) {
	size_t start = str.find_first_not_of(trim);
	size_t end = str.find_last_not_of(trim);
	if (string::npos == start || string::npos == end) {
		return "";
	} else {
		return str.substr(start, end - start + 1);
	}
}

shared_ptr<vector<string> > split(string str, string sep) {
	int found = str.find_first_of(sep);
	shared_ptr<vector<string> > results(new vector<string> ());
	while (found != string::npos) {
		if (found > 0) {
			results->push_back(str.substr(0, found));
		}
		str = str.substr(found + 1);
		found = str.find_first_of(sep);
	}
	if (str.length() > 0) {
		results->push_back(str);
	}
	return results;
}

string to_dual(int number, int len) {
	string result = "";
	for (int i = len - 1; i >= 0; i--) {
		result += number & (1 << i) ? '1' : '0';
	}
	return result;
}

string to_dual(const string& str, int len) {
	string result = "";
	int i = 0;
	for (; i < str.length(); i++) {
		char c = str[i];
		for (int j = 7; j >= 0; j--) {
			result += c & (1 << j) ? '1' : '0';
		}
	}
	for (; i < len; i++) {
		result += "00000000";
	}
	return result;
}

string to_hex(int number) {
	char result[10];
	sprintf(result, "%x", number);
	return result;
}

As::As(const string& inputfile) :
	inputfile(inputfile), addr(0), cnt_instr(0), error(0) {
	_load_config();
	load_pseudo_instructions();
}

void As::_load_config() {
	FILE* file = fopen(INSTR_CONFIG, "r");
	char line[1024];
	regex reg_instr("(\\w+)\\s+(\\w+)\\s+(\\w+)\\s*");
	regex reg_setting("\\s*(\\w+)\\s*=\\s*(\\w+)\\s*");
	regex reg_register("\\s*(\\$\\w+)\\s*=\\s*(\\$\\w+)\\s*");
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
		} else if (regex_match(line, tokens, reg_register)) {
			string alias(tokens[1].first, tokens[1].second);
			string reg(tokens[2].first, tokens[2].second);
			registers[alias] = reg;
		} else if (!regex_match(line, tokens, reg_empty)) {
			cerr << "Invalid instruction configuration: \"" << trim(line, "\n")
					<< "\", ignoring. " << endl;
		}
	}
	fclose(file);
}

int As::_add_constant(const std::string& key, const std::string& str_const) {
	char *end_ptr;
	const char* c = str_const.c_str();
	int i = strtol(c, &end_ptr, 0);
	if (c == end_ptr) {
		if (str_const[0] == '"') {
			if (str_const[str_const.size() - 1] != '"') {
				return -1;
			}
			constants[key]
					= constant(CONST_STRING, 0, trim(str_const, "\""), 0);
			return 0;
		}
		if (str_const[0] == '{') {
			if (str_const[str_const.size() - 1] != '}') {
				return -1;
			}
			constants[key] = constant(CONST_ARRAY, 0, str_const.substr(1,
					str_const.size() - 2), 0);
			return 0;
		}
	}
	constants[key] = constant(CONST_INT, 0, str_const, i);
	return 0;
}

void As::_precompile(const string& file) {
	FILE* in = fopen(file.c_str(), "r");
	if (!in) {
		msg.err_open_file(file);
		return;
	}
	char line[1024];

	regex reg_empty("\\s*");
	regex reg_include("\\s*#include\\s*(\\S+)\\s*");
	regex reg_label("\\s*(\\w+)\\:\\s*");
	regex reg_define("\\s*#define\\s+([a-zA-Z]\\w*)\\s+(\\S+.*\\S+)\\s*");
	regex reg_assign("\\s*([a-zA-Z]\\w*)\\s*=\\s*([\"\\w]+)\\s*");
	regex reg_instr0("\\s*(\\w+)\\s*"); /* 0 Parameter */
	regex reg_instr1("\\s*(\\w+)\\s+([\\$\\w-]+)\\s*"); /* 1 Parameter */
	regex reg_instr2("\\s*(\\w+)\\s+([\\$\\w-]+)\\s*,\\s*([\\$\\w-]+)\\s*"); /* 1 Parameter */
	regex reg_eof("EOF\\s*");

	cmatch tokens;
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
		} else if (regex_match(line, tokens, reg_eof)) {
			break;
		} else if (regex_match(line, tokens, reg_include)) {
			string file_nxt(tokens[1].first, tokens[1].second);
			_precompile(file_nxt);
			continue;
		} else if (regex_match(line, tokens, reg_label)) {
			string label;
			label.assign(tokens[1].first, tokens[1].second);
			labels[label] = cnt_instr;DBG("Found label: %s: %d", label.c_str(), cnt_instr);
			continue;
		} else if (regex_match(line, tokens, reg_define) || regex_match(line,
				tokens, reg_assign)) {
			string key(tokens[1].first, tokens[1].second);
			string str_constant(tokens[2].first, tokens[2].second);
			if (_add_constant(key, str_constant) == -1) {
				msg.warn_illegal_const(file, line_number, str_constant);
			}
			continue;
		} else if (regex_match(line, tokens, reg_instr0)) {
			type_len = 0;
		} else if (regex_match(line, tokens, reg_instr1)) {
			type_len = 1;
		} else if (regex_match(line, tokens, reg_instr2)) {
			type_len = 2;
		} else {
			msg.err_syntax(file, line_number, line);
			copy_line = false;
			error = 1;
		}
		for (int i = 0; i <= type_len; i++) {
			fields[i].assign(tokens[i + 1].first, tokens[i + 1].second);
		}

		if (copy_line) {
			shared_ptr<loc> l(new loc());
			l->file = file;
			l->line = line_number;
			l->src = line;
			l->instr = fields[0];
			for (int i = 1; i <= type_len; i++) {
				DBG("Adding l.params: i: %d, fields[%d]: %s", i, i,
						fields[i].c_str());
				l->params.push_back(fields[i]);
			}
			int result = replace_pseudo_instructions(*l);
			if (result > 0) {
				program.push_back(l);
				cnt_instr += result * 2;DBG("replace_pseudo_instr: %d", result);
			}
		}
	}DBG("Precompile fertig");DBG("program.size(): %d", program.size());
	fclose(in);
}

void As::_set_const_addresses() {
	map<string, constant>::iterator it = constants.begin();
	int caddr = strtol(settings["rom_start"].c_str(), NULL, 0) + cnt_instr * 2;
	for (; it != constants.end(); it++) {
		if (it->second.type == CONST_STRING) {
			it->second.address = caddr;
			caddr += it->second.str_value.length();
			if (caddr & 1)
				caddr++;
		} else if (it->second.type == CONST_ARRAY) {
			it->second.address = caddr;
			caddr += split(trim(it->second.str_value, "\" \t\n"), ",")->size();
		}
	}
}

int As::_compile_instr(loc& l) {
	DBG("l.instr: %s", l.instr.c_str());
	map<string, instruction>::iterator iter = instructions.find(l.instr);
	if (iter == instructions.end()) {
		msg.err_no_instr(l.file, l.line, l.instr);
		return -1;
	}
	instruction& i = iter->second;
	int type_len = l.params.size() * 3;
	DBG("l.params.size(): %d", l.params.size());DBG("type_len: %d, i.type.length: %d", type_len, i.type.length());
	if (type_len != i.type.length()) {
		msg.err_number_args(l.file, l.line, l.instr, i.type.length() / 3,
				type_len / 3); // TODO: das /3 geht schöner...
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
						imm = (iter->second - addr) >> 1;
					} else {
						int start_addr = strtol(settings["rom_start"].c_str(), NULL, 0);
						imm = iter->second + start_addr;
					}DBG("imm: %d", imm);
					valid = true;
				}
			}

			if (!valid) {
				map<string, constant>::iterator iter = constants.find(
						l.params[field_cnt]);
				if (iter != constants.end()) {
					if (isupper(type)) {
						msg.warn_const_as_offset(l.file, l.line);
						if (iter->second.type) {
							imm = (iter->second.address - addr) >> 1;
						} else {
							imm = (iter->second.i_value - addr) >> 1;
						}
					} else {
						if (iter->second.type) {
							imm = iter->second.address;
						} else {
							imm = iter->second.i_value;
						}
					}
					valid = true;
				}
			}

			if (!valid) {
				msg.err_no_imm(l.file, l.line, l.params[field_cnt]);
				return -1;
			}

			if (type == 'h') {
				if (imm < 0) {
					msg.err_no_signed(l.file, l.line, imm);
					return -1;
				}
				if (imm > 0xffff) {
					msg.warn_out_of_range_word(l.file, l.line, imm);
				}
				imm >>= 8;
				imm &= ((1 << cur_field_len) - 1);
			}

			else if (type == 'l') {
				if (imm < 0) {
					msg.err_no_signed(l.file, l.line, imm);
					return -1;
				}
				imm &= ((1 << cur_field_len) - 1);
			}

			else if (type == 'u') {
				if (imm >= (1 << cur_field_len)) {
					msg.err_out_of_range(l.file, l.line, imm, 0, ((1
							<< cur_field_len) - 1));
					return -1;
				}
			} else if (type == 's' || type == 'S') {
				if (imm >= (1 << cur_field_len) || imm < -(1 << (cur_field_len
						- 1))) {
					msg.err_out_of_range(l.file, l.line, imm, -(1
							<< (cur_field_len - 1)), (1 << (cur_field_len - 1))
							- 1);
					return -1;
				}
				if (imm >= (1 << (cur_field_len - 1))) {
					msg.wall_signed_overflow(l.file, l.line, imm);
				}
			} else {
				assert(0);
			}
			bin_code |= ((imm & ((1 << cur_field_len) - 1)) << cur_field_pos);
			break;
		}
			/* register */
		case 'r':
			if (l.params[field_cnt][0] == '$') {
				char* end_ptr;
				string sreg = registers[l.params[field_cnt]];
				if(!sreg.size()){
					sreg = l.params[field_cnt];
				}
				const char* reg = sreg.c_str() + 1;
				int reg_num = strtol(reg, &end_ptr, 10);
				if (reg == end_ptr) {
					msg.err_no_reg(l.file, l.line, l.params[field_cnt]);
				}DBG("reg_num: %d", reg_num);
				assert(cur_field_len <= 5);
				assert(reg_num >= 0);
				assert(reg_num < (1 << cur_field_len));
				bin_code |= reg_num << (cur_field_pos);
			} else {
				msg.err_no_reg(l.file, l.line, l.params[field_cnt]);
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
	msg.set_level(INFO);
	_precompile(inputfile);
	_set_const_addresses();
	_compile();
	msg.flush();
	return error;
}

void As::write_bin(const string& filename) {
	FILE* out = fopen(filename.c_str(), "w+");
	for (vector<shared_ptr<loc> >::iterator iter = program.begin(); iter
			!= program.end(); iter++) {
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

	for (map<string, constant>::iterator iter = constants.begin(); iter
			!= constants.end(); iter++) {
		if (iter->second.type) {
			string value = iter->second.str_value;
			int addr = iter->second.address;
			if (iter->second.type == CONST_STRING) {
				if (value.length() & 1) {
					value.append("\0");
				}
				fwrite(value.c_str(), value.length(), 1, out);
			} else {
				vector<string> tokens = *split(value, ",");
				for (vector<string>::iterator iter = tokens.begin(); iter
						!= tokens.end(); iter++) {
					string token = trim(*iter, " \t\n");
					const char* ctoken = token.c_str();
					char *end_ptr;
					int i = strtol(ctoken, &end_ptr, 0);
					if (i < -0x8000 || i > 0xffff) {
						cerr << "ASM internal error: " << __FILE__ << ":"
								<< __LINE__ << ": TODO" << endl;
					}
					char *p = (char*) &i;
					fwrite(p + 1, 1, 1, out);
					fwrite(p, 1, 1, out);
				}
			}
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
	ss << "0x" << to_hex(addr) << ": ";
	ss << trim(l.src, " \t\n");
	if (orig_src) {
		ss << l.instr << " ";
		if (l.params.size()) {
			ss << l.params[0];
		}
		for (int i = 1; i < l.params.size(); i++) {
			ss << ", " << l.params[i];
		}
		ss << " (" << trim(orig_src, " \t\n") << ")";
	}
	ss << "\n";
	return ss.str();
}

void As::write_rom(const string& file_out) {
	FILE* out = fopen(file_out.c_str(), "w");

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

	bool hex = (settings["rom_hex"][0] == '1');
	if (hex) {
		msg.print_msg(WARN, "<General>", 0,
				"Using hex addresses/values for ROM-file not implemented.");
	}

	int addr = strtol(settings["rom_start"].c_str(), NULL, 0);
	for (vector<shared_ptr<loc> >::iterator iter = program.begin(); iter
			!= program.end(); iter++) {
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

	for (map<string, constant>::iterator iter = constants.begin(); iter
			!= constants.end(); iter++) {
		if (iter->second.type) {
			string value = iter->second.str_value;
			int addr = iter->second.address;
			if (iter->second.type == CONST_STRING) {
				stringstream ss;
				if (value.length() & 1) {
					value.append("\0");
				}
				const char* cvalue = value.c_str();
				for (int i = 0; i < value.length(); i += 2) {
					ss << "\t\twhen \"" << to_dual(addr, 16)
							<< "\" => data <= \"";
					string s = value.substr(i, 2);
					ss << to_dual(s, 2) << "\";\n";
					addr += 2;
				}
				fwrite(ss.str().c_str(), ss.str().length(), 1, out);
			} else {
				vector<string> tokens = *split(value, ",");
				for (vector<string>::iterator iter = tokens.begin(); iter
						!= tokens.end(); iter++) {
					stringstream ss;
					string token = trim(*iter, " \t\n");
					const char* ctoken = token.c_str();
					char *end_ptr;
					int i = strtol(ctoken, &end_ptr, 0);
					if (i < -0x8000 || i > 0xffff) {
						cerr << "ASM internal error: " << __FILE__ << ":"
								<< __LINE__ << ": TODO" << endl;
					}
					ss << "\t\twhen \"" << to_dual(addr, 16)
							<< "\" => data <= \"";
					ss << to_dual(i, 16) << "\";\n";
					addr += 2;
					fwrite(ss.str().c_str(), ss.str().length(), 1, out);
				}
			}
		}
	}

	string footer = "\t\twhen others => data <= \"0000000000000000\";\n"
		"\tend case;\n"
		"end process;\n"
		"\n"
		"end rtl;\n";

	fwrite(footer.c_str(), footer.length(), 1, out);
	fclose(out);
}
