NAME=Stats
VERSION=1.2.0
TARGET=lib${NAME}.a
OBJECTS=stat_if.o read_proc.o conf.o eth-mii.o bri.o ppp.o
HEADERS=../include/stat_if.h
LIBS=
INCLUDE=-I../include
CORE=core
OPTIONS=-Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion

.SUFFIXES: .cc .c .o

.c.o: ${HEADERS}
	$(CC) $(CFLAGS) ${INCLUDE} -O3 -c ${OPTIONS} $<

all: ${OBJECTS} ${TARGET}

${TARGET}:${OBJECTS}
	$(AR) r ${TARGET} ${OBJECTS}

clean:
	rm -f ${TARGETS} ${OBJECTS} ${CORE} ${TARGET} ${TARGET}
