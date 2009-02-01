#ifndef MSG_H_
#define MSG_H_

#include <iostream>
#include <vector>

enum MSG_LEVEL {
	ERR = 0, WARN = 1, WALL = 2, INFO = 3
};

static std::string err_lvl_names[] = { "Error", "Warning", "Warning", "Info" };

class _msg {
	friend bool operator<(const _msg&, const _msg&);
private:
	MSG_LEVEL lvl;
	int line;
	std::string msg;
public:
	_msg(MSG_LEVEL lvl, int line, const std::string& msg) :
		lvl(lvl), line(line), msg(msg) {
	}

	MSG_LEVEL get_level(){
		return lvl;
	}

	int get_line(){
		return line;
	}

	std::string get_msg(){
		return msg;
	}
};

class Msg {
	static Msg *instance;

	std::string file;
	MSG_LEVEL lvl;

	std::vector<_msg> msgs;

public:
	static Msg* get_instance() {
		return instance ? instance : new Msg();
	}

	void set_level(MSG_LEVEL lvl) {
		this->lvl = lvl;
	}

	void set_file(std::string& file) {
		this->file = file;
	}

	void print_msg(MSG_LEVEL lvl, int line, const std::string& msg);

	void flush();

	void err_syntax(int line, const std::string& instr_line);
	void err_no_instr(int line, const std::string& instruction);
	void err_number_args(int line, const std::string& instruction, int exp,
			int found);
	void err_no_int(int line, const std::string& value);
	void err_no_signed(int line, int value);
	void err_no_imm(int line, const std::string& value);
	void err_out_of_range(int line, int value, int min, int max);
	void err_no_reg(int line, const std::string& reg);

	void warn_out_of_range_word(int line, int value);

};

#endif /* MSG_H_ */
