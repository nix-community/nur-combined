# Makefile for home

# Variables
EMACS =
ifndef EMACS
EMACS = "emacs"
endif

DOTEMACS = ~/.config/emacs
DOTGNUS = ~/.config/gnus
ETCNIXOS = /etc/nixos
SYNCDIR = /home/vincent/sync/nixos
SRCWWW = ~/src/www
SRCHOME = ~/src/home

# Targets
.PHONY: all
all: switch emacs-dump

.PHONY: update
update:
	nix-channel --update

.PHONY: pull
pull:
	(cd overlays/emacs-overlay && git checkout master && git pull --rebase)

.PHONY: emacs-dump
emacs-dump:
	emacs --batch -q -l ~/.config/emacs/dump.el

.PHONY: secrets
secrets:
	mkdir -p secrets
	cp -Rv $(SYNCDIR)/* secrets/

.PHONY: assets
assets:
	mkdir -p assets
	cp -Rv $(SYNCDIR)/* assets/
	chown -R vincent:users assets || true

.PHONY: home-build
home-build: secrets
	home-manager -f home.nix build

.PHONY: home-switch
home-switch: secrets
	home-manager -f home.nix switch

.PHONY: build
build: secrets setup
	./hack/system build

.PHONY: nixos-dry-build
dry-build: secrets setup
	./hack/system dry-build

.PHONY: switch
switch: secrets setup
	./hack/system switch

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
clean:
	@if test $(USER) = root;\
	then\
		nix-env --profile /nix/var/nix/profiles/system --delete-generations 15d;\
	else\
		unlink result || true;\
	fi

.PHONY: clean-www
clean-www:
	-rm -rvf *.elc
	-rm -rv ~/.org-timestamps/*

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

.PHONY: build-www
build-www: $(SRCWWW)/publish-common.el lib/lisp/publish.el update-docs
	@echo "Publishing... with current Emacs configurations."
	${EMACS} --batch --directory $(DOTEMACS)/lisp/ --directory $(DOTEMACS)/lisp/vorg/ \
		--load $(SRCWWW)/publish-common.el --load lib/lisp/publish.el \
		--funcall org-publish-all

$(SRCWWW)/Makefile: $(SRCWWW)
$(SRCWWW)/publish-common.el: $(SRCWWW)

$(SRCWWW):
	test -d $(SRCWWW) || git clone git@git.sr.ht:~vdemeester/www.git $(SRCWWW)

# Setup and doctor
.PHONY: doctor
doctor:
	@echo "Validate the environment"
	@readlink $(DOTEMACS) || $(error $(DOTEMACS) is not correctly linked, you may need to run setup)
	@readlink $(DOTNIXPKGS) || $(error $(DOTNIXPKGS) is not correctly linked, you may need to run setup)

.PHONY: setup
setup: $(DOTEMACS) $(DOTGNUS) $(SYNCDIR) $(SRCHOME)

$(DOTEMACS):
	@echo "Link $(DOTEMACS) to $(CURDIR)/tools/emacs"
	@ln -s $(CURDIR)/tools/emacs $(DOTEMACS)

$(DOTGNUS):
	@echo "Link $(DOTGNUs) to $(CURDIR)/tools/gnus"
	@ln -s $(CURDIR)/tools/gnus $(DOTGNUS)

$(SRCHOME):
	@echo "Make sure $(SRCHOME) exists"
	@-ln -s ${PWD} $(SRCHOME)

$(SYNCDIR):
	$(error $(SYNCDIR) is not present, you need to configure syncthing before running this command)
