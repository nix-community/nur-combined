NIX_FLAGS=--extra-experimental-features "nix-command flakes"
SCRIPT_DIR="$(shell pwd)/script"

.DEFAULT_GOAL := help

help:           ### Show help
	@echo -e "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?### .*$$' $(MAKEFILE_LIST) | awk '{printf "  \033[36m%-15s\033[0m %s\n", $$1, substr($$0, index($$0, "###") + 3)}'

check:          ### Check files
	nix $(NIX_FLAGS) flake check --no-build

update-flake:   ### update-flake
	bash -c $(SCRIPT_DIR)/update-flake

fix:            ### Fix nix syntax
	bash -c $(SCRIPT_DIR)/fix-syntax

.PHONY: help fix check update-flake
