all: bunpen

bunpen:
	hare build -o $@

install:
	mkdir -p $(PREFIX)/bin
	install -m755 bunpen $(PREFIX)/bin

test:
	hare test
	PATH=$(PWD):$(PATH) ./integration_test

.PHONY: all install test
