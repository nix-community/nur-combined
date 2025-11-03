set shell := ["fish", "-c"]

export NIXPKGS_ALLOW_UNFREE := "1"

@default:
    just --list

@fmt:
    nix fmt

@check: fmt
    nix flake check

@repl:
    nix repl --expr \
    "let \
        flake = builtins.getFlake (toString ./.); \
        nixpkgs = flake.inputs.nixpkgs; \
    in \
        {inherit flake;} // builtins // nixpkgs // nixpkgs.lib"
