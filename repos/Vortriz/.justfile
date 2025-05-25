set shell := ["fish", "-c"]

export NIXPKGS_ALLOW_UNFREE := "1"

@default:
    just --list

@fmt:
    nix fmt

@check: fmt
    nix flake check

@update: check
    echo -e "Updating flake and fetchgit inputs...\n"

    nix flake update
    for i in $(command fd sources.toml); \
        set o $(echo $i | sed 's/.toml//'); \
        nvfetcher -c $i -o $o; \
    end

    git add -A
    git commit -m "chore: update inputs"

alias pf := prefetch

[group('TOOLS')]
@prefetch url:
    nix store prefetch-file --json {{ url }} | jaq -r .hash

[group('TOOLS')]
@explore name:
    yazi $(nix eval --raw nixpkgs#{{ name }})

[group('TOOLS')]
@repl:
    nix repl --expr \
    "let \
        flake = builtins.getFlake (toString ./.); \
        nixpkgs = import <nixpkgs> {}; \
    in \
        {inherit flake;} // flake // builtins // nixpkgs // nixpkgs.lib"
