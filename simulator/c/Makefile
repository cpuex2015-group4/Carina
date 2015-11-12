TARGET=csim
CC=gcc
CFLAGS=-Wall -std=c99 -O3
ICCFLAGS=-Wall -fast -parallel
SRC_MAIN=main.c
SRC_UTILS=utils.c
SRC_SIM=simulator.c
OBJS=main.o utils.o simulator.o 
OBJ_MAIN=main.o
OBJ_UTILS=utils.o
OBJ_SIM=simulator.o
HEADER_SIM=simulator.h
HEADER_UTILS=utils.h

$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(CFLAGS) $(OBJS)

$(OBJ_MAIN): $(SRC_MAIN) 
	$(CC) -c $(CFLAGS) $(SRC_MAIN)

$(OBJ_SIM): $(SRC_SIM) 
	$(CC) -c $(CFLAGS) $(SRC_SIM)

$(OBJ_UTILS): $(SRC_UTILS) 
	$(CC) -c $(CFLAGS) $(SRC_UTILS)


.PHONY: clean
clean:
	rm -rf $(TARGET) $(OBJS)
