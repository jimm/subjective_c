# -*- makefile -*-

HERE = $(HOME)/src/subjc/src

all:
	cd $(HERE)/subjc; make -k; make -k install;
	cd $(HERE)/runtime; make -k; make -k install; # Used in the rest
	cd $(HERE)/list; make -k		# Must come after the above
#	cd $(HERE)/mcurses; make -k

clean:
	cd $(HERE)/list; make -k clean
	cd $(HERE)/subjc; make -k clean
	cd $(HERE)/runtime; make -k clean
	cd $(HERE); rm -fr ../bin/subjc ../lib/libsubjc.a ../include/subjc
#	cd $(HERE)/mcurses; make -k clean

install:
	cd $(HERE)/list; make -k install
	cd $(HERE)/subjc; make -k install
	cd $(HERE)/runtime; make -k install
#	cd $(HERE)/mcurses; make -k install

uninstall:
	cd $(HERE)/list; make -k uninstall
	cd $(HERE)/subjc; make -k uninstall
	cd $(HERE)/runtime; make -k uninstall
#	cd $(HERE)/mcurses; make -k uninstall
