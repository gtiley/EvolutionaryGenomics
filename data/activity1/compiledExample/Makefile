CC=gcc
CFLAGS=-I.
DEPS = betaSolver.h
OBJ = betaSolver.o solveBeta.o 

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

betaSolver: $(OBJ)
	$(CC) -o $@ $^ $(CFLAGS)

.PHONY: clean

clean:
	rm -f $(OBJ)