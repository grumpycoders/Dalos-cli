include Balau/common.mk

ifeq ($(DEBUG),)
CPPFLAGS += -g3 -gdwarf-2 -O3 -DNDEBUG
LDFLAGS += -g3 -gdwarf-2
else
CPPFLAGS += -g3 -gdwarf-2 -DDEBUG
LDFLAGS += -g3 -gdwarf-2
endif

INCLUDES = includes Balau/includes Balau/libcoro Balau/libeio Balau/libev Balau/LuaJIT/src Dalos-modules/includes
LIBS = z edit

ifeq ($(SYSTEM),Darwin)
    LIBS += pthread iconv
    CONFIG_H = Balau/darwin-config.h
endif

ifeq ($(SYSTEM),Linux)
    LIBS += pthread dl
    CONFIG_H = Balau/linux-config.h
endif

CPPFLAGS_NO_ARCH += $(addprefix -I, $(INCLUDES)) -fexceptions -imacros $(CONFIG_H)
CPPFLAGS += $(CPPFLAGS_NO_ARCH) $(ARCH_FLAGS)

LDFLAGS += $(ARCH_FLAGS)
LDLIBS = $(addprefix -l, $(LIBS))

vpath %.cc src Dalos-modules/src

DALOS_CLI_SOURCES = \
Dalos-cli.cc \
\
Readline.cc \
LuaLoad.cc \

ALL_OBJECTS = $(addsuffix .o, $(notdir $(basename $(DALOS_CLI_SOURCES))))
ALL_DEPS = $(addsuffix .dep, $(notdir $(basename $(DALOS_CLI_SOURCES))))

TARGET=Dalos-cli.$(BINEXT)

all: dep Balau $(TARGET)

strip: $(TARGET)
	$(STRIP) $(TARGET)

Balau:
	$(MAKE) -C Balau

tests: all
	$(MAKE) -C Balau tests
	./$(TARGET) tests/alltests.lua tests/runtests.lua
	./$(TARGET) tests/alltests.lua -e 'runtests()'

Balau/libBalau.a:
	$(MAKE) -C Balau

$(TARGET): Balau/libBalau.a $(ALL_OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $(ALL_OBJECTS) ./Balau/libBalau.a ./Balau/LuaJIT/src/libluajit.a ./Balau/libtomcrypt/libtomcrypt.a ./Balau/libtommath/libtommath.a $(LDLIBS)

dep: $(ALL_DEPS)

%.dep : %.cc
	$(CXX) $(CXXFLAGS) $(CPPFLAGS_NO_ARCH) -M $< > $@

%.dep : %.c
	$(CC) $(CFLAGS) $(CPPFLAGS_NO_ARCH) -M $< > $@

-include $(ALL_DEPS)

clean:
	rm -f $(ALL_OBJECTS) $(ALL_DEPS) $(TARGET)
	$(MAKE) -C Balau clean

deepclean:
	git clean -f -d -x
	git submodule foreach git clean -f -d -x
	git submodule foreach git submodule foreach git clean -f --d -x
	git reset --hard HEAD
	git submodule foreach git reset --hard HEAD
	git submodule foreach git submodule foreach git reset --hard HEAD

.PHONY: clean deepclean strip Balau tests all
