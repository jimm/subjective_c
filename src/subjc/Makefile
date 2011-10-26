# -*- makefile -*-

include ../Makefile.pre

NAME	= subjc
OBJS	= main.o bracket.o classinf.o clist.o error.o msgargs.o xlate.o
CL_H	= classinf.h clist.h

all:		$(NAME)

$(NAME):	$(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(NAME) $(OBJS)

main.o:		main.c subjc.h bracket.h $(CL_H) error.h xlate.h
bracket.o:	bracket.c bracket.h subjc.h $(CL_H) error.h msgargs.h \
			xlate.h
classinf.o:	classinf.c subjc.h $(CL_H) error.h
clist.o:	clist.c clist.h
error.o:	error.c error.h
msgargs.o:	msgargs.c msgargs.h bracket.h subjc.h $(CL_H) error.h \
			xlate.h
xlate.o:	xlate.c xlate.h subjc.h $(CL_H) error.h

clean:
	rm -f *.o $(NAME)

install:	all
	cp $(NAME) $(BINDIR)/$(NAME)
	strip $(BINDIR)/$(NAME)
