{ pkgs }:
let
  arch = {
    amd64 = import ./amd64.nix { inherit (pkgs) dockerTools; };
    arm64 = import ./arm64.nix { inherit (pkgs) dockerTools; };
  };
in
(arch.${pkgs.stdenv.hostPlatform.go.GOARCH}
  or (builtins.warn "Using default architecture (amd64) for image" arch.amd64)
).overrideAttrs
  (
    _: prev: {
      passthru = (prev.passthru or { }) // {
        inherit (arch) amd64 arm64;
      };
    }
  )
