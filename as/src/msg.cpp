#include "msg.h"

#include <sstream>
#include <algorithm>

using namespace std;

bool operator<(const _msg& a, const _msg& b) {
	return a.line < b.line;
}

void Msg::print_msg(MSG_LEVEL lvl, const std::string& file, int line,
		const string& msg) {
	if (lvl <= this->lvl) {
		msgs.push_back(_msg(lvl, file, line, msg));
	}
}

void Msg::flush() {
	stable_sort(msgs.begin(), msgs.end());
	if (msgs.size()) {
		if (msgs.size() == 1) {
			cout << "Received one message." << endl;
		} else {
			cout << "Received " << msgs.size() << " messages." << endl;
		}
	}
	for (vector<_msg>::iterator iter = msgs.begin(); iter != msgs.end(); iter++) {
		stringstream ss;
		ss << iter->get_file();
		if (iter->get_line()) {
			ss << ":" << iter->get_line();
		}
		ss << ": " << err_lvl_names[iter->get_level()] << ": " << iter->get_msg()
				<< "." << endl;
		if (iter->get_level() == ERR) {
			cerr << ss.str();
		} else {
			cout << ss.str();
		}
	}
}

void Msg::fatal_configuration() {
	cerr << "ASM Configuration error. Aborting" << endl;
	exit(EXIT_FAILURE);
}

void Msg::fatal_noinput(){
	cerr << "No inputfile specified. Aborting" << endl;
	exit(EXIT_FAILURE);
}

void Msg::err_syntax(const string& file, int line, const string& instr_line) {
	stringstream ss;
	int pos = instr_line.find('\n');
	ss << "Syntax error: \"" << (pos ? instr_line.substr(0, pos) : instr_line)
			<< "\"";
	print_msg(ERR, file, line, ss.str());
}

void Msg::err_no_instr(const string& file, int line, const string& instruction) {
	stringstream ss;
	ss << "\"" << instruction << "\" is no valid instruction";
	print_msg(ERR, file, line, ss.str());
}

void Msg::err_number_args(const string& file, int line,
		const string& instruction, int exp, int found) {
	stringstream ss;
	ss << "Wrong number of arguments for instruction " << instruction
			<< ". Expected: " << exp << ", found: " << found;
	print_msg(ERR, file, line, ss.str());
}

void Msg::err_no_int(const string& file, int line, const string& value) {
	stringstream ss;
	ss << "Integer expected. Found: " << value;
	print_msg(ERR, file, line, ss.str());
}

void Msg::err_no_signed(const string& file, int line, int value) {
	stringstream ss;
	ss << "Unsigned integer expected, found negative: " << value;
	print_msg(ERR, file, line, ss.str());
}

void Msg::err_no_imm(const string& file, int line, const string& value) {
	stringstream ss;
	ss << "Immediate invalid: " << value;
	print_msg(ERR, file, line, ss.str());
}

void Msg::err_out_of_range(const string& file, int line, int value, int min,
		int max) {
	stringstream ss;
	ss << "Immediate out of range: " << value << " not in [" << min << ".."
			<< max << "]";
	print_msg(ERR, file, line, ss.str());
}

void Msg::err_no_reg(const string& file, int line, const string& reg) {
	stringstream ss;
	ss << "Register expected, found: " << reg;
	print_msg(ERR, file, line, ss.str());
}

void Msg::err_open_file(const string& file) {
	print_msg(ERR, file, 0, "File not found or readable");
}

void Msg::warn_out_of_range_word(const string& file, int line, int value) {
	stringstream ss;
	ss << "Word value is out of range: " << value
			<< ". Applying bitmask 0xff00 which might not behave as desired";
	print_msg(WARN, file, line, ss.str());
}

void Msg::warn_const_as_offset(const string& file, int line) {
	print_msg(WARN, file, line,
			"Using reference to constant value as relative address");
}

void Msg::warn_illegal_const(const string& file, int line,
		const string& str_constant) {
	stringstream ss;
	ss << "Illegal value for constant: \"" << str_constant << "\", ignoring.\n";
	ss << "\tExpected integer or string (within parantheses)";
	print_msg(WARN, file, line, ss.str());
}

void Msg::wall_signed_overflow(const string& file, int line, int value) {
	stringstream ss;
	ss << "Signed value expected. The unsigned value " << value
			<< " will overflow and be interpreted as negative integer";
	print_msg(WALL, file, line, ss.str());
}
