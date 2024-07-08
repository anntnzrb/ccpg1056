CC = gcc
CFLAGS = -Wall -Wextra -Wpedantic -Werror -Wshadow -Wunreachable-code -std=c11 -O2
OBJS = ex5.o bmp.o filter.o

DOCS_DIR = docs

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

docs:
	@printf "Building docs...\\n"
	typst compile --root $(DOCS_DIR) $(DOCS_DIR)/main.typ 'reporte-Threads.pdf'

.PHONY: all clean test testmem ex5 docs
