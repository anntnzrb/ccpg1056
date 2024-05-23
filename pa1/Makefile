CFLAGS = -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -Wunreachable-code -std=c11 -O2
LDFLAGS = -flto

SRC_DIR = src
BUILD_DIR = build
DOCS_DIR = docs

BIN = $(BUILD_DIR)/mycat
SRC = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(SRC:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
DEPS = $(OBJ:.o=.d)

# default
all: help

build: $(OBJ)
	@printf "Building project...\\n"
	@mkdir -p $(BUILD_DIR)
	@cc $(CFLAGS) $(LDFLAGS) -o $(BIN) $(OBJ)

run: build
	@printf "Running project...\\n"
	@./$(BIN)

# format src tree
fmt:
	@printf "Formatting src tree...\\n"
	nix fmt

clean:
	@printf "Cleaning up...\\n"
	@rm -Rf $(BUILD_DIR)

docs:
	@printf "Building docs...\\n"
	typst compile --root $(DOCS_DIR) $(DOCS_DIR)/main.typ 'reporte.pdf'

help:
	@printf "Choose a target to execute:\\n"
	@printf "  make build - Compile\\n"
	@printf "  make run   - Run\\n"
	@printf "  make fmt   - Format src tree\\n"
	@printf "  make clean - Clean build artifacts\\n"
	@printf "  make help  - Show this help message\\n"

# dependency generation
-include $(DEPS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	@cc $(CFLAGS) -MMD -MP -c -o $@ $<

# targets
.PHONY: all help build run fmt clean docs
