
ASM = melonSlicer.s melonThrower.s main.s shared.s

CFLAGS = -O3
CC = gcc

melons: $(ASM)
	$(CC) -o melons $(CFLAGS) $(ASM) 

%.s: %.s.m4
	m4 $< > $@


clean:
	rm -f melons *.s
