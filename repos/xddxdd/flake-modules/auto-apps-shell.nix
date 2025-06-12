{ lib, ... }:

{
  perSystem =
    { config, pkgs, ... }:
    let
      makeAppsShell =
        apps:
        pkgs.mkShell {
          buildInputs = lib.mapAttrsToList (
            n: nv:
            pkgs.writeShellScriptBin n ''
              exec nix run .#${n} -- "$@"
            ''
          ) apps;
        };
    in
    {
      devShells.default = makeAppsShell config.apps;
    };
}
