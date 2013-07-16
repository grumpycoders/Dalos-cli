include Balau/common.mk

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

vpath %.cc src

DALOS_CLI_SOURCES = \
Dalos-cli.cc

ALL_OBJECTS = $(addsuffix .o, $(notdir $(basename $(DALOS_CLI_SOURCES))))
ALL_DEPS = $(addsuffix .dep, $(notdir $(basename $(DALOS_CLI_SOURCES))))

TARGET=Dalos-cli.$(BINEXT)

all: dep $(TARGET)

strip: $(TARGET)
	$(STRIP) $(TARGET)

Balau: Balau/libBalau.a

Balau/libBalau.a:
	$(MAKE) -C Balau

$(TARGET): Balau/libBalau.a $(ALL_OBJECTS)
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
