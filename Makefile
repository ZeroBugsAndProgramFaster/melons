SRC = $(wildcard *.c)
HDR = $(wildcard *.h)

CFLAGS = -O3 -Wall -Werror
CC = gcc


melons: $(SRC) $(HDR)
	$(CC) -o melons $(CFLAGS) $(SRC)

clean:
	rm -f melons