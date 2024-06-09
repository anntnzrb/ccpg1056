CC = gcc
CFLAGS = -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -Wunreachable-code -std=c11 -O2
LDFLAGS = -flto

SRC_DIR = src
BUILD_DIR = build
INCLUDE_DIR = include
DOCS_DIR = docs

SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)

BINARIES = timepipe timeshmm

# default
all: help

help:
	@printf "Choose a target to execute:\\n"
	@printf "  make build - Compile\\n"
	@printf "  make fmt   - Format src tree\\n"
	@printf "  make clean - Clean build artifacts\\n"
	@printf "  make docs  - Generate PDF report\\n"
	@printf "  make help  - Show this help message\\n"

build: $(BINARIES)
	@printf "Generating program @ ./build/...\\n"

timepipe: $(BUILD_DIR)/timepipe.o $(BUILD_DIR)/common.o
	@$(CC) $(LDFLAGS) -o $(BUILD_DIR)/$@ $^

timeshmm: $(BUILD_DIR)/timeshmm.o $(BUILD_DIR)/common.o
	@$(CC) $(LDFLAGS) -o $(BUILD_DIR)/$@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	@$(CC) $(CFLAGS) -c $< -o $@

# format src tree
fmt:
	@printf "Formatting src tree...\\n"
	@nix fmt

clean:
	@printf "Cleaning up...\\n"
	rm -Rf $(BUILD_DIR)/*.o $(BUILD_DIR)/$(BINARIES)

docs:
	@printf "Building docs...\\n"
	typst compile --root $(DOCS_DIR) $(DOCS_DIR)/main.typ 'reporte.pdf'

# targets
.PHONY: all clean help fmt docs timepipe timeshmm
