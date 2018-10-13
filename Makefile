# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2010-2014 Intel Corporation

# binary name
APP = l2fwd

# all source are stored in SRCS-y
SRCS-y := main.cpp

# Build using pkg-config variables if possible
$(shell pkg-config --exists libdpdk)
ifeq ($(.SHELLSTATUS),0)

all: shared
.PHONY: shared static
shared: build/$(APP)-shared
	ln -sf $(APP)-shared build/$(APP)
static: build/$(APP)-static
	ln -sf $(APP)-static build/$(APP)

DPDKPATH = $(RTE_SDK)/$(RTE_TARGET)
CC = g++
PC_FILE := $(shell pkg-config --path libdpdk)
CFLAGS += -O3 $(shell pkg-config --cflags libdpdk)
LDFLAGS_SHARED = $(shell pkg-config --libs libdpdk)
LDFLAGS_STATIC = -Wl,-Bstatic $(shell pkg-config --static --libs libdpdk)

build/$(APP)-shared: $(SRCS-y) Makefile $(PC_FILE) | build
	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS) $(LDFLAGS_SHARED)

build/$(APP)-static: $(SRCS-y) Makefile $(PC_FILE) | build
	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS) $(LDFLAGS_STATIC)

build:
	@mkdir -p $@

.PHONY: clean
clean:
	rm -f build/$(APP) build/$(APP)-static build/$(APP)-shared
	rmdir --ignore-fail-on-non-empty build

else # Build using legacy build system

ifeq ($(RTE_SDK),)
$(error "Please define RTE_SDK environment variable")
endif

# Default target, can be overridden by command line or environment
RTE_TARGET ?= x86_64-native-linuxapp-gcc
CXXFLAGS = -Wall -std=c++14 -I$(RTE_SDK)/$(RTE_TARGET)/include -include $(RTE_SDK)/$(RTE_TARGET)/include/rte_config.h

CC = g++
LIBS = \
	-m64 -pthread -march=native\
	-Wl,--no-as-needed\
	-Wl,--export-dynamic\
	-L$(RTE_SDK)/$(RTE_TARGET)/lib \
	-lpthread -lm -lrt -lpcap -ldl -lnuma -lboost_system\
	-Wl,--whole-archive\
	-Wl,--start-group\
	-ldpdk \
	-Wl,--end-group\
	-Wl,--no-whole-archive


all: build
.PHONY: build
build:
	@mkdir -p build/app
	$(CC) $(CXXFLAGS) $(SRCS-y) -o build/app/$(APP) $(LIBS)

.PHONY: clean
clean:
	rm -f build/$(APP) build/$(APP)-static build/$(APP)-shared
	rmdir --ignore-fail-on-non-empty build


#include $(RTE_SDK)/mk/rte.vars.mk
#
#CFLAGS += -O3
#CFLAGS += $(WERROR_FLAGS)
#
#include $(RTE_SDK)/mk/rte.extapp.mk
endif
