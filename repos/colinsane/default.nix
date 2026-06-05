# this is the entry point for most `nix` commands run against this repo.
# it's written as a chain loader:
#
# 1. copy everything* under this directory tree into the nix store.
# 2. exec into `/nix/store/.../default.nix`.
#
# the point of this is to allow mutating of this repo even while outstanding nix operations
# are in flight, without affecting those in-flight operations.
#
# * certain ephemeral files like `result` links aren't copied, as they aren't used but incur huge copying costs.
#
### usage with pure eval
# IN THEORY pure eval should work if you pin a git rev; in practice the below sometimes (?) fails:
# - `nix-instantiate --eval -E 'import (builtins.fetchGit { url = ./.; rev = "b07aa27006bf850064b10e530fb4811df23c38ed"; }) { system = "x86_64-linux"; }' --option pure-eval true`
# - add  `--read-write-mode` if it complains about a path "not being in the store"
{ ... }@args:
let
  sane-nix-files = import ./pkgs/by-name/sane-nix-files/package.nix { };
in
  import "${sane-nix-files}/impure.nix" args
