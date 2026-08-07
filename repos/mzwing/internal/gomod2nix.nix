# Eval-time access to the nvfetcher-pinned gomod2nix source.
#
# gomod2nix's builder is Nix code that must be imported at evaluation
# time. Fetching it through the nvfetcher fixed-output derivation would
# turn every evaluation into an import-from-derivation (the source fetch
# must be realised before the import), which breaks
# `nix flake check --no-build` and adds a derivation build to pure
# evaluation for consumers. builtins.fetchTree fetches at evaluation time
# like a flake input instead — no derivation is involved.
#
# The pin is read from the nvfetcher-generated JSON, so nvfetcher remains
# the single source of truth. For a github-type nvfetcher entry,
# fetchTree's narHash of the tarball matches fetchFromGitHub's recursive
# output hash for the same rev.
let
  pin = (builtins.fromJSON (builtins.readFile ../_sources/generated.json)).gomod2nix.src;
in
  builtins.fetchTree {
    type = "github";
    inherit (pin) owner repo rev;
    narHash = pin.sha256;
  }
