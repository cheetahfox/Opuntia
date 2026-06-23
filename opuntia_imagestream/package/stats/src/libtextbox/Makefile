OBJS			= input.o menurt.o listbox.o winops.o labels.o \
				msgboxes.o txbox.o

all: libtextbox.a

libtextbox.a: $(OBJS)
	rm -rf libtextbox.a
	$(AR) cq libtextbox.a $(OBJS)
	$(RANLIB) libtextbox.a

%.o: %.c *.h
	$(CC) -O2 -g -Wall -Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=int-conversion $(CFLAGS) -c -o $*.o $<

clean:
	rm -rf *.o *~ libtextbox.a libtextbox.so
