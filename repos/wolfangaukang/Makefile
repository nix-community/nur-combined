SHELL = /bin/sh
.DEFAULT_GOAL := help

# Colors
LOW := \033[0;32m
HIGH := \033[0;31m
NC := \033[0m

# Parameters
PROFILE ?= 
INPUT ?= 
BUILD_HOST_PORT ?= 22
SPECIALISATION ?= 
SERVER ?= 
BUILD_HOST ?= 

# Makefile targets and tools, which will be added to .PHONY
MAKEFILE_DEFAULT_TARGETS = all clean test help check_dependencies
MAKEFILE_EXTRA_TARGETS = build-remote makefile build boot-p switch test-s boot update
TOOLS = gorin nix nixos-rebuild

define HELP_MESSAGE
$(LOW)Usage:$(NC)
	$(LOW)make build-remote$(NC)          Builds system on a remote server
	$(LOW)make makefile$(NC)
	$(LOW)make build$(NC)                 Builds system
	$(LOW)make boot-p$(NC)                Create boot entry with profile
	$(LOW)make switch$(NC)                Switches generation
	$(LOW)make test-s$(NC)                Tests specialisation
	$(LOW)make boot$(NC)                  Create boot entry
	$(LOW)make update$(NC)                Updates flake input
	$(LOW)make test$(NC)                  Tests generation

$(LOW)Parameters:$(NC)
	$(LOW)PROFILE$(NC)                  profile to set boot entry (used with boot-p) (default: )
	$(LOW)INPUT$(NC)                    input to update (used with update) (default: )
	$(LOW)BUILD_HOST_PORT$(NC)          ssh port of build host (default: 22)
	$(LOW)SPECIALISATION$(NC)           specialisation to build (used with test-s) (default: )
	$(LOW)SERVER$(NC)                   Server to build (default: )
	$(LOW)BUILD_HOST$(NC)               info of the build host (used with build-remote) (default: )

endef

check_dependencies: 
	@missing=(); \
	for cmd in $(TOOLS); do \
		if ! command -v $$cmd &> /dev/null; then \
			missing+=($$cmd); \
		fi; \
	done; \
	if [ $${#missing[@]} -gt 0 ]; then \
		echo "$(HIGH)ERROR: The following required tools are missing: $${missing[@]}.$(NC)"; \
		exit 1; \
	fi

.PHONY: $(MAKEFILE_DEFAULT_TARGETS) $(MAKEFILE_EXTRA_TARGETS) $(TOOLS)

export HELP_MESSAGE

help: 
	@echo -e "$$HELP_MESSAGE"

build-remote: check_dependencies
	NIX_SSHOPTS="-i ~/.ssh/Keys/id -p $(BUILD_HOST_PORT)" nixos-rebuild build --flake .#$(SERVER) --build-host $(BUILD_HOST)

makefile: check_dependencies
	@gorin makefile > Makefile

build: check_dependencies
	nixos-rebuild build --flake .#$(SERVER)

boot-p: check_dependencies
	doas nixos-rebuild boot --flake .#$(SERVER) -p $(PROFILE)

switch: check_dependencies
	doas nixos-rebuild switch --flake .#$(SERVER)

test-s: check_dependencies
	doas nixos-rebuild test --flake .#$(SERVER) --specialisation $(SPECIALISATION)

boot: check_dependencies
	doas nixos-rebuild boot --flake .#$(SERVER)

update: check_dependencies
	nix flake update $(INPUT)

test: check_dependencies
	doas nixos-rebuild test --flake .#$(SERVER)
