# -*- makefile -*-

SRC	= src

all:
	$(MAKE) $(MAKEFLAGS) -C $(SRC)/subjc all install
	$(MAKE) $(MAKEFLAGS) -C $(SRC)/runtime DEVELOP=-DDEVELOP all install
	$(MAKE) $(MAKEFLAGS) -C $(SRC)/list all install

clean:
	$(MAKE) $(MAKEFLAGS) -C $(SRC)/subjc clean
	$(MAKE) $(MAKEFLAGS) -C $(SRC)/runtime clean
	$(MAKE) $(MAKEFLAGS) -C $(SRC)/list clean
	rm -f lib/* include/subjc/* `find . -name '.nfs*' -print`
