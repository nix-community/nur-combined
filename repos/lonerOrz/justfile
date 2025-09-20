@update:
    nix flake update

@update-packages:
    nix-shell -p nix-update nix-prefetch-git prefetch-npm-deps jq nodejs dpkg --run ".github/script/update.py"

@update-custom-package target:
    nix-shell -p nix-update nix-prefetch-git prefetch-npm-deps jq nodejs dpkg --run ".github/script/update.py --package {{ target }}"

@commit:
    bash .github/script/commit.sh
