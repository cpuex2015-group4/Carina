TARGET=csim
CC=gcc
CFLAGS=-Wall -std=c99 -O3
SRC_MAIN=main.c
SRC_UTILS=utils.c
SRC_SIM=simulator.c
OBJS=main.o utils.o simulator.o debugger.o _fadd.o _fmul.o
OBJ_MAIN=main.o
OBJ_UTILS=utils.o
OBJ_SIM=simulator.o
HEADER_SIM=simulator.h
HEADER_UTILS=utils.h

$(TARGET): $(OBJS)
	$(CC) -o $(TARGET) $(CFLAGS) $(OBJS)

%.o: %.c
	$(CC) -c $(CFLAGS) $<

.PHONY: clean
clean:
	rm -rf $(TARGET) $(OBJS)
