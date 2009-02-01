#include "msg.h"

#include <sstream>
#include <algorithm>

using namespace std;

bool operator<(const _msg& a, const _msg& b) {
	return a.line < b.line;
}

void Msg::print_msg(MSG_LEVEL lvl, int line, const string& msg) {
	if (lvl <= this->lvl) {
		msgs.push_back(_msg(lvl, line, msg));
	}
}

void Msg::flush() {
	stable_sort(msgs.begin(), msgs.end());
	if (msgs.size()) {
		cout << "Received " << msgs.size() << " messages." << endl;
	}
	for (vector<_msg>::iterator iter = msgs.begin(); iter != msgs.end(); iter++) {
		stringstream ss;
		ss << file << ":" << iter->get_line() << ": "
				<< err_lvl_names[iter->get_level()] << ": " << iter->get_msg()
				<< "." << endl;
		if (iter->get_level() == ERR) {
			cerr << ss.str();
		} else {
			cout << ss.str();
		}
	}
}

void Msg::err_syntax(int line, const string& instr_line) {
	stringstream ss;
	int pos = instr_line.find('\n');
	ss << "Syntax error: \"" << (pos ? instr_line.substr(0, pos) : instr_line)
			<< "\"";
	print_msg(ERR, line, ss.str());
}

void Msg::err_no_instr(int line, const string& instruction) {
	stringstream ss;
	ss << "\"" << instruction << "\" is no valid instruction";
	print_msg(ERR, line, ss.str());
}

void Msg::err_number_args(int line, const string& instruction, int exp,
		int found) {
	stringstream ss;
	ss << "Wrong number of arguments for instruction " << instruction
			<< ". Expected: " << exp << ", found: " << found;
	print_msg(ERR, line, ss.str());
}

void Msg::err_no_int(int line, const string& value) {
	stringstream ss;
	ss << "Integer expected. Found: " << value;
	print_msg(ERR, line, ss.str());
}

void Msg::err_no_signed(int line, int value) {
	stringstream ss;
	ss << "Unsigned integer expected, found negative: " << value;
	print_msg(ERR, line, ss.str());
}

void Msg::err_no_imm(int line, const string& value) {
	stringstream ss;
	ss << "Immediate invalid: " << value;
	print_msg(ERR, line, ss.str());
}

void Msg::err_out_of_range(int line, int value, int min, int max) {
	stringstream ss;
	ss << "Immediate out of range: " << value << " not in [" << min << ".."
			<< max << "]";
	print_msg(ERR, line, ss.str());
}

void Msg::err_no_reg(int line, const string& reg) {
	stringstream ss;
	ss << "Register expected, found: " << reg;
	print_msg(ERR, line, ss.str());
}

void Msg::warn_out_of_range_word(int line, int value) {
	stringstream ss;
	ss << "Word value is out of range: " << value
			<< ". Applying bitmask 0xff00 which might not behave as desired.";
	print_msg(WARN, line, ss.str());
}
