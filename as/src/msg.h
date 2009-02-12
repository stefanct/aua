#ifndef MSG_H_
#define MSG_H_

#include <iostream>
#include <vector>

enum MSG_LEVEL {
	FATAL = 0, ERR = 1, WARN = 2, WALL = 3, INFO = 4
};

static std::string err_lvl_names[] = { "Fatal", "Error", "Warning", "Warning", "Info" };

class _msg {
	friend bool operator<(const _msg&, const _msg&);
private:
	MSG_LEVEL lvl;
	std::string file;
	int line;
	std::string msg;
public:
	_msg(MSG_LEVEL lvl, const std::string& file, int line, const std::string& msg) :
		lvl(lvl), file(file), line(line), msg(msg) {
	}

	MSG_LEVEL get_level() {
		return lvl;
	}

	std::string get_file(){
		return file;
	}

	int get_line() {
		return line;
	}

	std::string get_msg() {
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

	void print_msg(MSG_LEVEL lvl, const std::string& file, int line,
			const std::string& msg);

	void flush();

	void fatal_configuration();
	void fatal_noinput();

	void err_syntax(const std::string& file, int line,
			const std::string& instr_line);
	void err_no_instr(const std::string& file, int line,
			const std::string& instruction);
	void err_number_args(const std::string& file, int line,
			const std::string& instruction, int exp, int found);
	void
			err_no_int(const std::string& file, int line,
					const std::string& value);
	void err_no_signed(const std::string& file, int line, int value);
	void
			err_no_imm(const std::string& file, int line,
					const std::string& value);
	void err_out_of_range(const std::string& file, int line, int value,
			int min, int max);
	void err_no_reg(const std::string& file, int line, const std::string& reg);
	void err_no_const(const std::string& file, int line, int value);
	void err_open_file(const std::string& file);

	void warn_out_of_range_word(const std::string& file, int line, int value);
	void warn_const_as_offset(const std::string& file, int line);
	void warn_illegal_const(const std::string& file, int line, const std::string& str_constant);

	void wall_signed_overflow(const std::string& file, int line, int value);
};

#endif /* MSG_H_ */
