# Makefile for home
HOSTS          = $(shell nix flake show --json | yq '.nixosConfigurations.[] | key')
HOSTS_BUILD    = $(addprefix host/, $(addsuffix /build,$(HOSTS)))
BUILDER_HOST   = vincent@shikoku.sbr.pm

hosts: ${HOSTS_BUILD}
	echo ${HOSTS_BUILD} ${HOSTS}

host/%/build: FORCE
	nix build .#nixosConfigurations.$*.config.system.build.toplevel --no-link
host/%/boot: FORCE
	nixos-rebuild --build-host ${BUILDER_HOST} --target-host root@$*.sbr.pm --flake .#$* boot
host/%/switch: FORCE
	nixos-rebuild --build-host ${BUILDER_HOST} --target-host root@$*.sbr.pm --flake .#$* switch

host/shikoku/boot:
	nixos-rebuild --build-host root@shikoku.sbr.pm --target-host root@shikoku.sbr.pm --flake .#shikoku boot
host/shikoku/switch:
	nixos-rebuild --build-host root@shikoku.sbr.pm --target-host root@shikoku.sbr.pm --flake .#shikoku switch
host/kerkouane/boot:
	nixos-rebuild --build-host ${BUILDER_HOST} --target-host root@kerkouane.vpn --flake .#kerkouane boot
host/kerkouane/switch:
	nixos-rebuild --build-host ${BUILDER_HOST} --target-host root@kerkouane.vpn --flake .#kerkouane switch

boot:
	sudo nixos-rebuild --flake .# boot
switch:
	sudo nixos-rebuild --flake .# switch
dry-build:
	nixos-rebuild --flake .# dry-build
build:
	nixos-rebuild --flake .# build

FORCE:

# Old – to be removed
# Variables
EMACS =
ifndef EMACS
EMACS = "emacs"
endif

DOTEMACS = ~/.config/emacs
DOTGNUS = ~/.config/gnus
ETCNIXOS = /etc/nixos

# Targets
.PHONY: all
all: switch

.PHONY: update
update:
	nix-channel --update

.PHONY: install-hooks
install-hooks:
	if [ -e .git ]; then nix-shell -p git --run 'git config core.hooksPath .githooks'; fi

.PHONY: pre-commit
pre-commit: README.md fmt

.PHONY: fmt
fmt:
	-nixpkgs-fmt *.nix nix lib overlays pkgs systems tools users

# Cleaning
.PHONY: clean
clean: clean-system clean-results

.PHONY: clean-system
clean-system:
	nix-env --profile /nix/var/nix/profiles/system --delete-generations 15d

.PHONY: clean-results
clean-results:
	unlink results

.PHONY: clean-www
clean-www:
	-rm -rvf *.elc
	-rm -rv ~/.org-timestamps/*

.PHONY: www
www:
	(cd www; make)

# Documentation build and publishing
.PHONY: update-docs
update-docs:
	@echo "Updating docs references…"
	$(EMACS) --batch --directory $(DOTEMACS)/lisp/ \
		--load lib/lisp/docs.el \
		--funcall update-docs

README.md: README.org
	@echo "Updating README.md…"
	$(EMACS) --batch --directory $(DOTEMACS)/lisp/ \
		--load lib/lisp/docs.el \
		--funcall update-readme-md

# Setup and doctor
.PHONY: doctor
doctor:
	@echo "Validate the environment"
	@readlink $(DOTEMACS) || $(error $(DOTEMACS) is not correctly linked, you may need to run setup)
	@readlink $(DOTNIXPKGS) || $(error $(DOTNIXPKGS) is not correctly linked, you may need to run setup)

.PHONY: setup
setup: $(DOTEMACS) $(DOTGNUS)

$(DOTEMACS):
	@echo "Link $(DOTEMACS) to $(CURDIR)/tools/emacs"
	@ln -s $(CURDIR)/tools/emacs $(DOTEMACS)

$(DOTGNUS):
	@echo "Link $(DOTGNUs) to $(CURDIR)/tools/gnus"
	@ln -s $(CURDIR)/tools/gnus $(DOTGNUS)
