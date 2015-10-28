TARGET=fpu.so
CC=gcc
CFLAGS=-Wall
SRC=fadd.c fmul.c

$(TARGET): $(SRC)
	$(CC) -shared -fPIC -o $(TARGET) $(CFLAGS) $(SRC)

.PHONY: clean
clean:
	rm -rf $(TARGET)
