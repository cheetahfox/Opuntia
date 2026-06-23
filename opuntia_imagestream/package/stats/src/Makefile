SUBDIRS=library src
TARGET=stats

.PHONY : library src clean

CC ?= $(CROSS)gcc

all: ${SUBDIRS}

library:
	$(MAKE) -C lib CC="$(CC)" CFLAGS="$(CFLAGS)"

src:
	$(MAKE) -C src ${TARGET} CC="$(CC)" CFLAGS="$(CFLAGS)"

clean:
	$(MAKE) -C lib clean
	$(MAKE) -C src clean
