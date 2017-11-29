SYN_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SYN_SRC_DIR := $(SYN_DIR)src/
SYN_INC_DIR := $(SYN_DIR)inc/

vpath %.v $(SYN_SRC_DIR)
vpath %.vh $(SYN_INC_DIR)

IVERILOG_FLAGS += -y$(SYN_SRC_DIR) -I$(SYN_INC_DIR)
VERILATOR_FLAGS += -y $(SYN_SRC_DIR) -I$(SYN_INC_DIR)

SYN_BASE := $(notdir $(basename $(wildcard $(SYN_SRC_DIR)*.v)))
SYN_TEST := $(addprefix syn-test-,$(SYN_BASE))
SYN_LINT := $(addprefix syn-lint-,$(SYN_BASE))

all:

test: syn-test

lint: syn-lint

syn-all: syn-test

syn-test: $(SYN_TEST)

syn-lint: $(SYN_LINT)

$(SYN_TEST): syn-test-%: %.v
	@$(IVERILOG) $(IVERILOG_FLAGS) $(IVERILOG_VFLAGS) -tnull $<

$(SYN_LINT): syn-lint-%: %.v
	@$(VERILATOR) $(VERILATOR_FLAGS) -Wno-fatal --lint-only $<

.PHONY: syn test lint syn-test syn-lint $(SYN_TEST) $(SYN_LINT)
