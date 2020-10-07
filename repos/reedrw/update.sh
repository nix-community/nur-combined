#! /usr/bin/env nix-shell
#! nix-shell -i bash

# number-versioned packages. Use nix-update
while read -r i; do
  nix-update "$i" || exit 1
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

