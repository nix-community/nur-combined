#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update nix-prefetch nix-prefetch-github

# number-versioned packages. Use nix-update
while read -r i; do
  nix-update "$i"
done << EOF
  r2mod_cli
  scientifica
EOF

# other. Run their update.sh
while read -r i; do
  pushd pkgs/"$i"/
  ./update.sh
  popd
done << EOF
  artwiz-lemon
EOF

