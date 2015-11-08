TARGET=csim
CC=gcc
CFLAGS=-Wall -std=c99 
SRC=main.c
HEADER_SIM=simulator.h
HEADER_UTILS=utils.h
HEADER_CONST=const.h

$(TARGET): $(SRC) $(HEADER_SIM) $(HEADER_UTILS) $(HEADER_CONST)
	$(CC) -o $(TARGET) $(CFLAGS) $(SRC)

.PHONY: clean
clean:
	rm -rf $(TARGET)
