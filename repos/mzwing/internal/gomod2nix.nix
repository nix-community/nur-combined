# Fetch the flake-pinned gomod2nix source at evaluation time to avoid import-from-derivation.
builtins.fetchTree (builtins.fromJSON (builtins.readFile ../flake.lock)).nodes.gomod2nix.locked
