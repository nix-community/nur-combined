build TARGET:
  rm -f result
  NIXPKGS_ALLOW_UNFREE=1 nix build .#{{TARGET}} --impure

shell TARGET: (build TARGET)
  NIXPKGS_ALLOW_UNFREE=1 nix shell .#{{TARGET}} --impure

alias b := build
alias s := shell
