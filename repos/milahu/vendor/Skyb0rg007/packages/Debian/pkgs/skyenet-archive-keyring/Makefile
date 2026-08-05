
KEY_ARMOR := skyenet-archive-keyring.asc
KEY_GPG := $(KEY_ARMOR:%.asc=%.gpg)

.DEFAULT: all
.PHONY: install test clean

all: $(KEY_GPG)

$(KEY_GPG): $(KEY_ARMOR)
	$(RM) $@
	gpg --batch --output $@ --dearmor $<

install: $(KEY_GPG)
	install --directory $(DESTDIR)/usr/share/keyrings
	install --mode=644 --target-directory=$(DESTDIR)/usr/share/keyrings $(KEY_GPG)
	install --directory $(DESTDIR)/etc/apt/sources.list.d
	install --mode=644 --target-directory=$(DESTDIR)/etc/apt/sources.list.d skyenet.sources

test: $(KEY_GPG)
	gpg --no-default-keyring --keyring $(KEY_GPG) --list-keys

clean:
	$(RM) $(KEY_GPG)
