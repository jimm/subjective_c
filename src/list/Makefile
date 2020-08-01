# -*- makefile -*-

include ../Makefile.pre

NAME	= main
OBJS	= main.o List.o Dictionary.o Stream.o String.o

$(NAME):		$(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) -lsubjc

main.o:		main.m List.h String.h Stream.h Dictionary.h
Dictionary.o:	Dictionary.m Dictionary.h List.h
List.o:		List.m List.h
String.o:	String.m String.h
Stream.o:	Stream.m Stream.h

clean:
	rm -f *.[oc] $(NAME)

install:	$(NAME)
	cp List.h Dictionary.h String.h Stream.h $(INCDIR)/subjc
	ar r $(LIBDIR)/libsubjc.a List.o Dictionary.o String.o Stream.o
	ranlib $(LIBDIR)/libsubjc.a

uninstall:
	cd $(INCDIR) && rm -f List.h Dictionary.h String.h Stream.h
	rm -f $(LIBDIR)/libsubjc.a
