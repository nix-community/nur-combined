SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

EXCLUDED_PATHS := -path './.git' -o -path './agent-ctrl' -o -path './_archived' -o -path './claude-code' -o -path './claude-code.bak' -o -path './konsave' -o -path './quickshell' -o -path './zsh/zsh-autosuggestions' -o -path './zsh/zsh-syntax-highlighting'

.PHONY: format lint help

help: ## List available maintenance commands.
	@awk 'BEGIN { FS = ":.*##" } /^[a-zA-Z_-]+:.*##/ { printf "%-12s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

format: ## Format tracked configuration files when their formatter is installed.
	@set -euo pipefail; \
	if command -v shfmt >/dev/null; then \
		echo '----- Shell -----'; \
		find . \( $(EXCLUDED_PATHS) \) -prune -o -type f -name '*.sh' -print0 | xargs -0 -r shfmt -w -i 2 -ci -sr; \
	else echo "[skip] Shell: 'shfmt' not found"; fi; \
	if command -v alejandra >/dev/null; then \
		echo '----- Nix -----'; \
		find . \( $(EXCLUDED_PATHS) \) -prune -o -type f -name '*.nix' -print0 | xargs -0 -r alejandra; \
	else echo "[skip] Nix: 'alejandra' not found"; fi; \
	if command -v stylua >/dev/null; then \
		echo '----- Lua -----'; \
		find . \( $(EXCLUDED_PATHS) \) -prune -o -type f -name '*.lua' -print0 | xargs -0 -r stylua; \
	else echo "[skip] Lua: 'stylua' not found"; fi; \
	if command -v prettier >/dev/null; then \
		echo '----- JSON/CSS/YAML -----'; \
		find . \( $(EXCLUDED_PATHS) \) -prune -o -type f \( -name '*.json' -o -name '*.css' -o -name '*.yml' -o -name '*.yaml' \) ! -name flake.lock ! -name lazy-lock.json -print0 | xargs -0 -r prettier --write --log-level warn; \
		echo '----- JSONC -----'; \
		find . \( $(EXCLUDED_PATHS) \) -prune -o -type f -name '*.jsonc' -print0 | xargs -0 -r prettier --write --log-level warn --trailing-comma none; \
	else echo "[skip] JSON/CSS/YAML: 'prettier' not found"; fi; \
	if command -v taplo >/dev/null; then \
		echo '----- TOML -----'; \
		find . \( $(EXCLUDED_PATHS) \) -prune -o -type f -name '*.toml' -print0 | xargs -0 -r taplo format; \
	else echo "[skip] TOML: 'taplo' not found"; fi; \
	if command -v perl >/dev/null; then \
		find . \( $(EXCLUDED_PATHS) \) -prune -o -type f \( -name '*.conf' -o -name '*.rasi' \) -exec perl -pi -e 's/[ \t]+$$//' {} +; \
		find . \( $(EXCLUDED_PATHS) \) -prune -o -type f -name '*.toml' -exec perl -pi -e 's/(\S)\s{2,}#/$$1 #/g' {} +; \
	else echo "[skip] whitespace cleanup: 'perl' not found"; fi; \
	echo 'Formatting completed.'

lint: ## Run shell and Nix checks.
	@set -euo pipefail; \
	echo '----- Shell lint -----'; \
	mapfile -d '' -t shell_files < <(find ./arch ./hyprland ./nixos -type f -name '*.sh' -print0); \
	if [ "$${#shell_files[@]}" -gt 0 ]; then shellcheck "$${shell_files[@]}"; fi; \
	echo '----- Nix flake check -----'; \
	alejandra ./nixos; \
	statix check ./nixos; \
	deadnix ./nixos; \
	nix flake check ./nixos
