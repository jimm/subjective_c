# -*- makefile -*-

include ../Makefile.pre

NAME	= main
OBJECT_H = Object.h Object_impl.h Class.h
CLASS_H	= $(OBJECT_H)
OBJS	= Object.o MessageSend.o


all:		$(NAME)

$(NAME):	main.o $(OBJS)
	$(CC) $(CFLAGS) $(DEVELOP) -o $@ main.o $(OBJS)

main.o:		main.m $(OBJECT_H)
MessageSend.o:	MessageSend.m $(OBJECT_H)
	$(BINDIR)/subjc_preproc.pl $*.m >$*.c
	$(CPP) $(CPPFLAGS) $*.c >$*.pre
	$(SUBJC) $*.pre >$*.c
	$(CC) $(CFLAGS) $(DEVELOP) -S $*.c
	../bin/makejump.pl $*.s
	$(CC) $(CFLAGS) $(DEVELOP) -c $*.s
#	rm $*.c *s. $*.pre
Object.o:	Object.m $(OBJECT_H)

clean:
	rm -f *.[ocs] *.pre $(NAME) core.$(NAME)

install:	all
	rm -fr $(INCDIR)/subjc
	mkdir $(INCDIR)/subjc
	cp $(OBJECT_H) $(INCDIR)/subjc
	rm -f $(LIBDIR)/libsubjc.a
	ar r $(LIBDIR)/libsubjc.a $(OBJS)
	ranlib $(LIBDIR)/libsubjc.a
