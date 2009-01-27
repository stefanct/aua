CC=g++
LIBS=-lboost_regex
FLAGS=-g -DDEBUG

all: as

clean:
	rm -f *.o

as.o: src/as.cpp src/as.h
	$(CC) $(FLAGS) -c src/as.cpp

pseudo.o: src/pseudo.cpp src/pseudo.h
	$(CC) $(FLAGS) -c src/pseudo.cpp

as: as.o pseudo.o
	$(CC) $(LIBS) as.o pseudo.o -o as 
