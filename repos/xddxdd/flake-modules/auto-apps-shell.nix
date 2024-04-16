{
  self,
  lib,
  inputs,
  ...
}:

{
  perSystem =
    { config, pkgs, ... }:
    let
      makeAppsShell =
        apps:
        pkgs.mkShell {
          buildInputs = lib.mapAttrsToList (
            n: v:
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
