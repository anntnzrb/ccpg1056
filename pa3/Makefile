CC = gcc
CFLAGS = -Wall -Wshadow -O3 -march=native
OBJS = ex5.o bmp.o filter.o

all: clean ex5

ex5: $(OBJS)
	@mkdir -p outputs
	@$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	@$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -rf *.o *.d ex5 outputs/

test: ex5
	@./ex5 testcases/test.bmp outputs/test_out.bmp
	@diff outputs/test_out.bmp testcases/test_sol.bmp && printf 'Test passed!\n'

testmem: ex5
	valgrind --tool=memcheck --leak-check=summary ./ex5 testcases/test.bmp outputs/test_out.bmp

.PHONY: all clean test testmem ex5
