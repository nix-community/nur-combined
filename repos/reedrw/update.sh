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
  pushd pkgs/"$i"/ || exit 1
  ./update.sh
  popd || exit 1
done << EOF
  actions-cli
  artwiz-lemon
  picom-next-ibhagwan
  teletype
EOF
