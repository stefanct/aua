#include <iostream>
#include <cstdlib>

#include "as.h"

using namespace std;

void usage() {
	cerr << "Usage: as [-r] input.as output" << endl;
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

	string file_in;
	if(argc>optind){
		file_in = argv[optind];
	}
	else{
		void fatal_noinput();
	}

	string file_out("a.out");
	if(argc>optind+1){
		file_out = argv[optind + 1];
	}
	string file_rom = "../hw/mmu/src/rom.vhd";

	As p(file_in);

	int result = p.compile();
	if(result==0){
		p.write_bin(file_out);
	}
	if (create_rom && result==0) {
		p.write_rom(file_rom);
	}
}
