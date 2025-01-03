all: bunpen

# these are *runtime* dependencies
IP ?= $(shell which ip)
IPTABLES ?= $(shell which iptables)
PASTA ?= $(shell which pasta)
XDG_DBUS_PROXY ?= $(shell which xdg-dbus-proxy)

config/runtime_deps.ha: config/runtime_deps.ha.in
	test -x "$(IP)"
	test -x "$(IPTABLES)"
	test -x "$(PASTA)"
	sed -e "s:@IP@:$(IP):" \
	    -e "s:@IPTABLES@:$(IPTABLES):" \
	    -e "s:@PASTA@:$(PASTA):" \
	    -e "s:@XDG_DBUS_PROXY@:$(XDG_DBUS_PROXY):" \
	    $^ > $@
	cat $@

bunpen: config/runtime_deps.ha
	hare build -o $@

install:
	mkdir -p $(PREFIX)/bin
	install -m755 bunpen $(PREFIX)/bin

test:
	hare test
	PATH=$(PWD):$(PATH) ./integration_test

.PHONY: all install test
