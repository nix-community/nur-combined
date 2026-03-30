{ pkgs }:
let
  systems = {
    x86_64-linux = import ./amd64.nix { inherit (pkgs) dockerTools; };
    aarch64-linux = import ./arm64.nix { inherit (pkgs) dockerTools; };
  };
in
(systems.${pkgs.stdenv.hostPlatform.system}
  or (builtins.warn "Using default architecture (amd64) for image" systems.x86_64-linux)
).overrideAttrs
  (
    _: prev: {
      passthru = (prev.passthru or { }) // {
        inherit (systems) x86_64-linux aarch64-linux;
      };
    }
  )
