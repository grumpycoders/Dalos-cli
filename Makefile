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
LIBS = z

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
    ifeq ($(TRUESYSTEM),Linux)
        CROSSCOMPILE = true
        ARCH_FLAGS =
        CC = i686-apple-darwin9-gcc
        CXX = i686-apple-darwin9-g++
        LD = i686-apple-darwin9-g++ -arch i386 -mmacosx-version-min=10.5
        STRIP = i686-apple-darwin9-strip -x
        AS = i686-apple-darwin9-as -arch i386
        AR = i686-apple-darwin9-ar rcs
    endif
endif

ifeq ($(SYSTEM),MINGW32)
    BINEXT = exe
    COMPILE_PTHREADS = true
    CONFIG_H = Balau/mingw32-config.h
    INCLUDES += Balau/win32/iconv Balau/win32/pthreads-win32 Balau/win32/regex Balau/win32/dbghelp
    LIBS += ws2_32 ntdll
    ifeq ($(TRUESYSTEM),Linux)
        ifeq ($(DISTRIB),CentOS)
            CROSSCOMPILE = true
            CC = i686-pc-mingw32-gcc
            CXX = i686-pc-mingw32-g++
            LD = i686-pc-mingw32-g++
            AS = i686-pc-mingw32-gcc -c
            STRIP = i686-pc-mingw32-strip --strip-unneeded
            WINDRES = i686-pc-mingw32-windres
            AR = i686-pc-mingw32-ar rcs
            LUAJIT_CROSS = i686-pc-mingw32-
        else
            CROSSCOMPILE = true
            CC = i586-mingw32msvc-gcc
            CXX = i586-mingw32msvc-g++
            LD = i586-mingw32msvc-g++
            AS = i586-mingw32msvc-gcc -c
            STRIP = i586-mingw32msvc-strip --strip-unneeded
            WINDRES = i586-mingw32msvc-windres
            AR = i586-mingw32msvc-ar rcs
            LUAJIT_CROSS = i586-mingw32msvc-
        endif
        LUAJIT_TARGET = Windows
    endif

    ifeq ($(TRUESYSTEM),Darwin)
        CROSSCOMPILE = true
        CC = i386-mingw32-gcc
        CXX = i386-mingw32-g++
        LD = i386-mingw32-g++
        AS = i386-mingw32-gcc -c
        STRIP = i386-mingw32-strip --strip-unneeded
        WINDRES = i386-mingw32-windres
        AR = i386-mingw32-ar rcs
    endif
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
	$(LD) $(LDFLAGS) -o $@ $(ALL_OBJECTS) ./Balau/LuaJIT/src/libluajit.a ./Balau/libBalau.a $(LDLIBS)

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
