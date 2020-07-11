SOURCES=$(wildcard *.c)
OBJECTS=$(SOURCES:.c=.o)
BINS=$(SOURCES:.c=)

CFLAGS+=`pkg-config --cflags gnome-keyring-1`
LDFLAGS+=`pkg-config --libs gnome-keyring-1`

all: $(BINS)

.PHONY: clean

clean:
	$(RM) $(OBJECTS) $(BINS)
