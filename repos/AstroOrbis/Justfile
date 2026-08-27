check:
  nix-env -f . -qa \* --meta \
  --allowed-uris https://static.rust-lang.org \
  --option restrict-eval true \
  --option allow-import-from-derivation true \
  --drv-path --show-trace \
  -I nixpkgs=$(nix-instantiate --find-file nixpkgs) \
  -I ./ \
  --json | jq -r 'values | .[].name'

baseflake := ".#legacyPackages.x86_64-linux."

build pkg:
  nom build {{baseflake}}{{pkg}}

# build every cacheable package, skipping those already in the binary cache
ci:
  nix shell -f '<nixpkgs>' nix-fast-build nix-output-monitor \
    -c nix-fast-build --file ci.nix -A cacheOutputsAttrs --skip-cached
