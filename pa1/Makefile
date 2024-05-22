CFLAGS = -Wall -Wextra -Wpedantic -Wshadow -Wconversion -Wunreachable-code -std=c11

SRC = main.c
BUILD_DIR = build
BIN = $(BUILD_DIR)/mycat

# default
all:
	@printf "Choose a target to execute:\\n"
	@printf "  make build - Compile\\n"
	@printf "  make run   - Run\\n"
	@printf "  make fmt   - Format src tree\\n"
	@printf "  make clean - Clean build artifacts\\n"

build: $(SRC)
	@mkdir -p $(BUILD_DIR)
	@cc $(CFLAGS) -o $(BIN) $(SRC)

run: build
	@./$(BIN)

fmt:
	@printf "Formatting src tree...\\n"
	@nix fmt

clean:
	@printf "Cleaning up...\\n"
	@rm -Rf $(BUILD_DIR)

# targets
.PHONY: all build run fmt clean
