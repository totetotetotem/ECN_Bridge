# binary name
APP = ecn_fwd

# sources
SRCS := main.cpp

# check RTE_SDK
ifeq ($(RTE_SDK),)
$(error "Please define RTE_SDK environment variable")
endif

# can be overwritten
RTE_TARGET ?= x86_64-native-linuxapp-gcc

CC = g++
CXXFLAGS = -Wall -std=c++14 -I$(RTE_SDK)/$(RTE_TARGET)/include -include $(RTE_SDK)/$(RTE_TARGET)/include/rte_config.h
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
	$(CC) $(CXXFLAGS) $(SRCS) -o build/app/$(APP) $(LIBS)

.PHONY: clean
clean:
	rm -f build/$(APP)
	rmdir --ignore-fail-on-non-empty build

