TARGET=stats
OBJECTS=main.o summary.o detail.o csu.o info.o misc.o
HEADERS=include/interface.h include/sdl_stats.h
LIBS=-lStats -ltextbox -lpanel -lncurses

OPTIONS=-O3 -L../lib -L../libtextbox -Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion
INCLUDES=-I../include/ -I../libtextbox
LIBRARY=../lib/libStats.a
LIBTEXTBOX=../libtextbox/libtextbox.a

.SUFFIXES: .cc .o

.c.o: ${HEADERS}
	${CC} ${OPTIONS} ${INCLUDES} $(CFLAGS) -c $<

all: ${OBJECTS} ${TARGET} ${LIBRARY} ${LIBTEXTBOX}

${LIBRARY}:
	$(MAKE) -C ../lib CC="$(CC)" CFLAGS="$(CFLAGS)"

lib_clean:
	$(MAKE) -C ../lib clean

${LIBTEXTBOX}:
	$(MAKE) -C ../libtextbox CC="$(CC)" CFLAGS="$(CFLAGS)"

libtextbox_clean:
	$(MAKE) -C ../libtextbox clean

${TARGET}:${OBJECTS} ${LIBRARY} ${LIBTEXTBOX}
	${CC} ${OBJECTS} ${LIBS} ${INCLUDE} ${OPTIONS} -o ${TARGET}
	$(STRIP) ${TARGET}

clean: libtextbox_clean lib_clean
	rm -f ${OBJECTS} ${CORE} ${TARGET}
