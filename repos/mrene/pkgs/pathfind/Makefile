CC=clang
INSTALL=install -m 755

pathfind: pathfind.c
	$(CC) -o pathfind -O3 pathfind.c

install: pathfind
	mkdir -p $(out)/bin
	$(INSTALL) pathfind $(out)/bin/pathfind

