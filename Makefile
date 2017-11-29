PRJ_DIR := $(dir $(firstword $(MAKEFILE_LIST)))

VERILATOR ?= verilator
YOSYS ?= yosys
IVERILOG ?= iverilog
VVP ?= vvp

IVERILOG_VFLAGS := -g2005
IVERILOG_SVFLAGS := -g2012 -Y.sv
IVERILOG_FLAGS := -Wall
ifndef DEBUG
IVERILOG_FLAGS += -DNDEBUG
endif
ifdef NSTOP
IVERILOG_FLAGS += -DNSTOP
endif
VERILATOR_FLAGS := -Wall
CXXFLAGS := -Wall -std=c++11

all: gen-all sim-all syn-all

check:
	@$(MAKE) --warn-undefined-variables --makefile=$(firstword $(MAKEFILE_LIST)) all > /dev/null

help:
	@echo ""
	@echo " make [TARGET]"
	@echo ""
	@echo " TARGET ::= all | check | test | clean"
	@echo ""

include gen/machina.mk
include sim/machina.mk
include syn/machina.mk

.PHONY: all check test clean help
