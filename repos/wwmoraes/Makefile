MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --jobs --max-load --output-sync
.SHELLFLAGS := -euc

export SHELL := $(shell which bash)

PKGS_SINGLE_FILE = $(patsubst %.nix,%,$(wildcard pkgs/*.nix))
PKGS_IN_SUBDIR = $(patsubst %/default.nix,%,$(wildcard pkgs/*/default.nix))
PUSH_PKGS_SINGLE_FILE = $(patsubst pkgs/%,push/%,${PKGS_SINGLE_FILE})
PUSH_PKGS_IN_SUBDIR = $(patsubst pkgs/%,push/%,${PKGS_IN_SUBDIR})

ifneq ($(shell which op),)
OP = op plugin run --
else
OP =
endif

.PHONY: all
#: Builds all packages.
all:
	nix-build --no-out-link

.PHONY: configure
#: Sets up the environment to contribute to this repository.
configure:
	cog install-hook --all --overwrite

.PHONY: check
#: Runs validations to ensure all packages build successfully.
check:
	nix fmt
	nix flake check --print-build-logs

.PHONY: clean
#: Removes built packages from the nix store.
clean:
	nix-instantiate 2> /dev/null | xargs nix-store --query | xargs nix-store --delete

.PHONY: push
#: Builds and pushes derivations to cachix.
push:
	nix-build --no-out-link | ${OP} cachix push wwmoraes

.PHONY: submodules
#: Checks out submodules to work in this repository.
submodules:
	git submodule update --force --checkout

.PHONY: test
#: Tests changes to ensure they can update the NUR index.
test:
	$(info checking NUR evaluation...)
	@env NIX_PATH= nix-env -f . -qa '*' --meta --xml \
	--allowed-uris https://static.rust-lang.org \
	--option restrict-eval true \
	--option allow-import-from-derivation true \
	--drv-path \
	--show-trace \
	-I nixpkgs=$(shell nix-instantiate --find-file nixpkgs) \
	-I ./ \
	> /dev/null && echo NUR evaluation succeeded

.PHONY: queue-refresh
#: Requests the upstream NUR to index the packages from this repository.
queue-refresh:
	curl -X POST "https://nur-update.nix-community.org/update?repo=wwmoraes"

.PHONY: ${PKGS_SINGLE_FILE}
#: Builds specific package.
${PKGS_SINGLE_FILE}: pkgs/%: pkgs/%.nix
	$(info building $* with $^)
	nix-build -A $* --no-out-link --repair --option substituters https://cache.nixos.org/

.PHONY: ${PKGS_IN_SUBDIR}
#: Builds specific package.
${PKGS_IN_SUBDIR}: pkgs/%: pkgs/%/default.nix
	nix-build -A $* --no-out-link --repair --option substituters https://cache.nixos.org/

.PHONY: ${PUSH_PKGS_SINGLE_FILE}
#: Builds and pushes specific package.
${PUSH_PKGS_SINGLE_FILE}: push/%: pkgs/%.nix
	nix-build -A $* --no-out-link | ${OP} cachix push wwmoraes

.PHONY: ${PUSH_PKGS_IN_SUBDIR}
#: Builds and pushes specific package.
${PUSH_PKGS_IN_SUBDIR}: push/%: pkgs/%/default.nix
	nix-build -A $* --no-out-link | ${OP} cachix push wwmoraes
