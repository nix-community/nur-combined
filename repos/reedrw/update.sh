#! /usr/bin/env nix-shell
#! nix-shell -i bash -p nix-update nix-prefetch-github

# number-versioned packages. Use nix-update
while read -r i; do
  nix-update "$i"
done << EOF
  r2mod_cli
  scientifica
EOF

# other. Run their update.sh
while read -r i; do
  pkgs/"$i"/update.sh
done << EOF
  artwiz-lemon
EOF

