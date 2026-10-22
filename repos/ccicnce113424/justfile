fmt:
    nix fmt .

fup:
    nix flake update --commit-lock-file 

hello:
    nix run

up:
    nix run .#nvfetcher-bin

# Targeted refresh of matching nvfetcher sources, e.g. `just upr '^zhuque$'`.
upr regex:
    nix run .#nvfetcher-bin -- --keep-old -f '{{ regex }}'
