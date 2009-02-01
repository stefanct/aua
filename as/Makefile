CC=g++
LIBS=-lboost_regex
FLAGS=-g -DDEBU

all: as

clean:
	rm -f *.o

main.o: src/main.cpp
	$(CC) $(FLAGS) -c src/main.cpp

as.o: src/as.cpp src/as.h
	$(CC) $(FLAGS) -c src/as.cpp

pseudo.o: src/pseudo.cpp src/pseudo.h
	$(CC) $(FLAGS) -c src/pseudo.cpp

msg.o: src/msg.cpp src/msg.h
	$(CC) $(FLAGS) -c src/msg.cpp

as: main.o as.o pseudo.o msg.o
	$(CC) $(LIBS) main.o as.o pseudo.o msg.o -o as 
