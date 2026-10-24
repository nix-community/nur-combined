fmt:
    nix fmt .

fup:
    nix flake update --commit-lock-file 

hello:
    nix run

# Regenerate every `_sources/` entry from nvfetcher.toml (bulk / first run only).
nvf:
    nix run .#nvfetcher-bin

# Targeted refresh of matching nvfetcher sources, e.g. `just nvfr '^zhuque$'`.
nvfr regex:
    nix run .#nvfetcher-bin -- --keep-old -f '{{ regex }}'
    _scripts/prune-sources.sh

# Refresh update units; no args = all, attrs select, `--list` = names as JSON.
upd *attrs:
    _scripts/run-update-scripts.sh {{ attrs }}
