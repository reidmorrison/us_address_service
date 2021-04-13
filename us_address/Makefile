#CFLAGS = -g -O3 -Wall -Wno-format-truncation
CFLAGS = -g -O3

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -I$(ERLANG_PATH)
CFLAGS += -I../dqs
CFLAGS += -Ic_src
LDLIBS = -Lpriv -Wl,-rpath,priv -lmdAddr -lpthread

LIB_NAME = priv/md_address.so

ifneq ($(CROSSCOMPILE),)
    # crosscompiling
    CFLAGS += -fPIC
else
    # not crosscompiling
    ifneq ($(OS),Windows_NT)
        CFLAGS += -fPIC

        ifeq ($(shell uname),Darwin)
            LDFLAGS += -dynamiclib -undefined dynamic_lookup
        endif
    endif
endif

NIF_SRC=src/md_address.c src/nif_utils.c

all: $(LIB_NAME)

$(LIB_NAME): $(NIF_SRC)
	mkdir -p priv
	$(CC) $(CFLAGS) -shared $(LDFLAGS) $^ -o $@ $(LDLIBS)

clean:
	rm -f $(LIB_NAME)

.PHONY: all clean
