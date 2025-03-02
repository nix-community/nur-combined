#! /usr/bin/env nix-shell
#! nix-shell -i bash --pure
#! nix-shell -p gnumake nix nixfmt-rfc-style statix deadnix findutils git cacert gnupg
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/1807c2b91223227ad5599d7067a61665c52d1295.tar.gz

### A wrapper to run make, without need to install make, nix will add make to the runtime PATH
make $1
