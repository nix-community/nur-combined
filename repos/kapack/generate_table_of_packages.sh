OUTPUT=packages.md
nix flake show --json | jq -j --raw-output '["|attr|package|description|\n","|:-----|:------|:------|\n"] + (.packages."x86_64-linux" | to_entries | map("|\(.key)|\(.value.name)|\(.value.description | gsub("\n"; " "))|\n")) | .[]' > ${OUTPUT}
