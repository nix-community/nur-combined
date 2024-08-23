all: bunpen

bunpen:
	hare build -o $@

install:
	mkdir -p $(PREFIX)/bin
	install -m755 bunpen $(PREFIX)/bin

test:
	hare test

.PHONY: all install test
