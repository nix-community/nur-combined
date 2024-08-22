all: bunpen

bunpen:
	hare build -o $@ src

install:
	mkdir -p $(PREFIX)/bin
	install -m755 bunpen $(PREFIX)/bin

test:
	hare test src

.PHONY: all install test
