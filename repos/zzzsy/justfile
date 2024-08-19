default:
  @just --summary --unsorted --justfile {{justfile()}}

alias u:=update
alias s:=switch
alias m:=metadata
alias gd:=gitdiff
alias gdc:=gitdiffcached
alias chk:=check
alias nv:=nvfetcher


metadata:
  @nix flake metadata

update:
  @nix flake update

fmt:
  nixpkgs-fmt ./

switch host="laptop":
  nh os switch . --ask
  # sudo nixos-rebuild switch --flake .#{{host}} -L

test host="laptop":
  nh os test . --ask
  # sudo nixos-rebuild test --flake .#{{host}} -L

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
