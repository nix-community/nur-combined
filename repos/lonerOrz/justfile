@update:
    nix flake update

@update-custom-packages:
    nix-shell -p nix-update nix-prefetch-git prefetch-npm-deps jq nodejs dpkg --run ".github/script/update.py"

@update-custom-packages target:
    nix-shell -p nix-update nix-prefetch-git prefetch-npm-deps jq nodejs dpkg --run ".github/script/update.py --package {{ target }}"
