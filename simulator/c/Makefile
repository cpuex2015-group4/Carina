TARGET=csim
CC=gcc
CFLAGS=-Wall -std=c99 
SRC_MAIN=main.c
SRC_UTILS=utils.c
SRC_SIM=simulator.c
OBJ_MAIN=main.o
OBJ_UTILS=utils.o
OBJ_SIM=simulator.o
OBJ_ALL=*.o
HEADER_SIM=simulator.h
HEADER_UTILS=utils.h
HEADER_CONST=const.h

$(TARGET): $(OBJ_MAIN) $(OBJ_SIM) $(OBJ_UTILS) $(HEADER_CONST)
	$(CC) -o $(TARGET) $(CFLAGS) $(OBJ_MAIN) $(OBJ_SIM) $(OBJ_UTILS)

$(OBJ_MAIN): $(SRC_MAIN) $(HEADER_CONST)
	$(CC) -c $(CFLAGS) $(SRC_MAIN)

$(OBJ_SIM): $(SRC_SIM) $(HEADER_CONST)
	$(CC) -c $(CFLAGS) $(SRC_SIM)

$(OBJ_UTILS): $(SRC_UTILS) $(HEADER_CONST)
	$(CC) -c $(CFLAGS) $(SRC_UTILS)


.PHONY: clean
clean:
	rm -rf $(TARGET) $(OBJ_ALL)
