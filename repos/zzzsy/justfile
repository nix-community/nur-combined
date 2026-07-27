default:
    @just --summary --unsorted --justfile {{ justfile() }}

alias u := update
alias s := switch
alias m := metadata
alias gd := gitdiff
alias gdc := gitdiffcached
alias chk := check
alias nv := nvfetcher

metadata:
    @nix flake metadata

update:
    @nix flake update

fmt:
    nixpkgs-fmt ./

switch host="laptop":
    #!/usr/bin/env bash
    set -e
    nix build --log-format internal-json -v -f default.nix nixosConfigurations.{{ host }}.config.system.build.toplevel |& nom --json
    dix /run/current-system result
    read -p "Apply and switch? (y/N): " -n 1 -r confirm
    echo

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        echo "🔄 Switching..."
        sudo nix-env -p /nix/var/nix/profiles/system --set $(readlink result)
        sudo ./result/bin/switch-to-configuration switch
        unlink result
        echo "✅ Successfully switched."
    else
        echo "❌ Canceled."
    fi

gc:
    sudo nix-collect-garbage --delete-older-than 5d
    sudo nix store gc --debug

diff:
    @nix profile diff-closures --profile /nix/var/nix/profiles/system

show:
    @nix flake show

gitdiff:
    @git diff -- ':^flake.lock' ':^pkgs/_sources/*'; \

gitdiffcached:
    @git diff --cached -- ':^flake.lock' ':^pkgs/_sources/*'

check:
    @nix flake check

nvfetcher:
    @nvfetcher -c pkgs/nvfetcher.toml -o pkgs/_sources/ --verbose

rm:
    find . -type l -name 'result' -exec rm {} +

upkgs:
    just nvfetcher

renc:
    nix run .#vaultix.app.x86_64-linux.renc

sync-envrc:
    #!/usr/bin/env fish
    cd templates
    for dir in hugo python rust slidev typst zig
      cp common.envrc $dir/.envrc
    end
    echo "✅ Synced .envrc to all templates"

update-templates:
    #!/usr/bin/env fish
    cd templates
    for dir in hugo rust slidev typst zig
      if test -f $dir/flake.nix
        echo "Updating $dir..."
        cd $dir
        nix flake update
        cd ..
      else
        echo "Skipping $dir (no flake.nix found)"
      end
    end
    echo "✅ Updated all templates"
