{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {
    inherit system;
    overlays = [
      (
        final: prev:
        prev.lib.recursiveUpdate prev {
          nur.repos.wwmoraes = import ./default.nix {
            inherit system;
            pkgs = prev;
          };
        }
      )
    ];
  },
  ...
}:
let
  self = rec {
    default = pkgs.mkShell {
      packages = [
        pkgs.cachix
        pkgs.git
        pkgs.remake
      ];
    };
    terminal = default.overrideAttrs (
      final: prev: {
        nativeBuildInputs = [
          # keep-sorted start
          pkgs.cocogitto
          # keep-sorted end
        ] ++ prev.nativeBuildInputs;

        shellHook = ''
          cog install-hook --all --overwrite
        '';
      }
    );
  };
in
if builtins ? getFlake then self else self.default
