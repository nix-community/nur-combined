SHELL = /bin/sh
.DEFAULT_GOAL := help

# Colors
LOW := \033[0;32m
HIGH := \033[0;31m
NC := \033[0m

# Parameters
SPECIALISATION ?= 
SERVER ?= 
BUILD_HOST ?= 
INPUT ?= 
BUILD_HOST_PORT ?= 22
PROFILE ?= 

define HELP_MESSAGE
$(LOW)Usage:$(NC)
	$(LOW)make build$(NC)                 Builds system
	$(LOW)make build-remote$(NC)          Builds system on a remote server
	$(LOW)make boot$(NC)                  Create boot entry
	$(LOW)make activate$(NC)              Activates a nix-darwin build
	$(LOW)make makefile$(NC)
	$(LOW)make test$(NC)                  Tests generation
	$(LOW)make boot-p$(NC)                Create boot entry with profile
	$(LOW)make switch$(NC)                Switches generation
	$(LOW)make test-s$(NC)                Tests specialisation
	$(LOW)make update$(NC)                Updates flake input

$(LOW)Parameters:$(NC)
	$(LOW)SPECIALISATION$(NC)           specialisation to build (used with test-s) (default: )
	$(LOW)SERVER$(NC)                   Server to build (default: )
	$(LOW)BUILD_HOST$(NC)               info of the build host (used with build-remote) (default: )
	$(LOW)INPUT$(NC)                    input to update (used with update) (default: )
	$(LOW)BUILD_HOST_PORT$(NC)          ssh port of build host (default: 22)
	$(LOW)PROFILE$(NC)                  profile to set boot entry (used with boot-p) (default: )

endef

GORIN := $(shell command -v gorin 2>/dev/null)
NIX := $(shell command -v nix 2>/dev/null)

check_dependencies: 
ifndef GORIN
	$(error gorin is not available)
endif
ifndef NIX
	$(error nix is not available)
endif

export HELP_MESSAGE

help: 
	@echo -e "$$HELP_MESSAGE"

.PHONY: build
build: check_dependencies
	$(if $(shell command -v darwin-rebuild 2>/dev/null),darwin-rebuild,nixos-rebuild) build --flake .#$(SERVER)

.PHONY: build-remote
build-remote: check_dependencies
	NIX_SSHOPTS="-i ~/.ssh/Keys/id -p $(BUILD_HOST_PORT)" nixos-rebuild build --flake .#$(SERVER) --build-host $(BUILD_HOST)

.PHONY: boot
boot: check_dependencies
	$(if $(shell command -v doas 2>/dev/null),doas,sudo) nixos-rebuild boot --flake .#$(SERVER)

.PHONY: activate
activate: check_dependencies
	$(if $(shell command -v darwin-rebuild 2>/dev/null),,$(error darwin-rebuild is not available))
	sudo ./result/activate

.PHONY: makefile
makefile: check_dependencies
	@gorin makefile > Makefile

.PHONY: test
test: check_dependencies
	$(if $(shell command -v doas 2>/dev/null),doas,sudo) nixos-rebuild test --flake .#$(SERVER)

.PHONY: boot-p
boot-p: check_dependencies
	$(if $(shell command -v doas 2>/dev/null),doas,sudo) nixos-rebuild boot --flake .#$(SERVER) -p $(PROFILE)

.PHONY: switch
switch: check_dependencies
	$(if $(shell command -v doas 2>/dev/null),doas,sudo) $(if $(shell command -v darwin-rebuild 2>/dev/null),darwin-rebuild,nixos-rebuild) switch --flake .#$(SERVER)

.PHONY: test-s
test-s: check_dependencies
	$(if $(shell command -v doas 2>/dev/null),doas,sudo) nixos-rebuild test --flake .#$(SERVER) --specialisation $(SPECIALISATION)

.PHONY: update
update: check_dependencies
	nix flake update $(INPUT)
