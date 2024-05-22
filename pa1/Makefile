CFLAGS = -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -Wunreachable-code -std=c11
SRC_DIR = src
BUILD_DIR = build
BIN = $(BUILD_DIR)/mycat
SRC = $(wildcard $(SRC_DIR)/*.c)

# default
all:
	@printf "Choose a target to execute:\\n"
	@printf "  make build - Compile\\n"
	@printf "  make run   - Run\\n"
	@printf "  make fmt   - Format src tree\\n"
	@printf "  make clean - Clean build artifacts\\n"

build: $(SRC)
	@mkdir -p $(BUILD_DIR)
	@printf "Building the project...\\n"
	@cc $(CFLAGS) -o $(BIN) $(SRC)

run: build
	@printf "Running the project...\\n"
	@./$(BIN) data/names.data

fmt:
	@printf "Formatting the code...\\n"
	nix fmt

clean:
	@printf "Cleaning up...\\n"
	@rm -Rf $(BUILD_DIR)

# targets
.PHONY: all build run fmt clean
