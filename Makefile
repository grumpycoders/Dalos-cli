ifeq ($(SYSTEM),)
    SYSTEM = $(shell uname | cut -f 1 -d_)
endif

TRUESYSTEM = $(shell uname)
MACHINE = $(shell uname -m)
DISTRIB = $(shell cat /etc/issue | cut -f 1 -d\  | head -1)

CC = gcc
CXX = g++
LD = g++
AS = gcc -c
AR = ar rcs

BINEXT = bin

CPPFLAGS += -fno-strict-aliasing

ifeq ($(DEBUG),)
CPPFLAGS += -g -O3 -DNDEBUG
LDFLAGS += -g
else
CPPFLAGS += -g -DDEBUG
LDFLAGS += -g
endif

INCLUDES = includes Balau/includes Balau/libcoro Balau/libeio Balau/libev Balau/LuaJIT/src
LIBS = z readline

ifeq ($(SYSTEM),Darwin)
    CC = clang
    CXX = clang++
    CPPFLAGS += -fPIC
    LDFLAGS += -fPIC
    LIBS += pthread iconv
    CONFIG_H = Balau/darwin-config.h
    ARCH_FLAGS = -arch i386
    LD = clang++ -arch i386
    STRIP = strip -x
endif

ifeq ($(SYSTEM),Linux)
    CPPFLAGS += -fPIC
    LDFLAGS += -fPIC -rdynamic
    LIBS += pthread dl
    CONFIG_H = Balau/linux-config.h
    ARCH_FLAGS = -march=i686 -m32
    ASFLAGS = -march=i686 --32
    STRIP = strip --strip-unneeded
endif

CPPFLAGS_NO_ARCH += $(addprefix -I, $(INCLUDES)) -fexceptions -imacros $(CONFIG_H)
CPPFLAGS += $(CPPFLAGS_NO_ARCH) $(ARCH_FLAGS)

CXXFLAGS += -Wno-deprecated -std=gnu++0x

LDFLAGS += $(ARCH_FLAGS)
LDLIBS = $(addprefix -l, $(LIBS))

vpath %.cc src

DALOS_CLI_SOURCES = \
Dalos-cli.cc

ALL_OBJECTS = $(addsuffix .o, $(notdir $(basename $(DALOS_CLI_SOURCES))))
ALL_DEPS = $(addsuffix .dep, $(notdir $(basename $(DALOS_CLI_SOURCES))))

TARGET=Dalos-cli.$(BINEXT)

all: dep $(TARGET)

strip: $(TARGET)
	$(STRIP) $(TARGET)

Balau:
	$(MAKE) -C Balau

$(TARGET): Balau $(ALL_OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $(ALL_OBJECTS) ./Balau/libBalau.a ./Balau/LuaJIT/src/libluajit.a $(LDLIBS)

dep: $(ALL_DEPS)

%.dep : %.cc
	$(CXX) $(CXXFLAGS) $(CPPFLAGS_NO_ARCH) -M $< > $@

%.dep : %.c
	$(CC) $(CFLAGS) $(CPPFLAGS_NO_ARCH) -M $< > $@

-include $(ALL_DEPS)

clean:
	rm -f $(ALL_OBJECTS) $(ALL_DEPS) $(TARGET)
	$(MAKE) -C Balau clean

.PHONY: clean strip Balau
