{
  pkgs,
  lib,
  ...
}:
let
  packages = import ../default.nix { inherit pkgs; };
  input = pkgs.writeText "input.yaml" (
    lib.generators.toYAML { } {
      packages = (
        lib.mapAttrsToList (name: value: {
          inherit name;
          version = value.version;
          platforms = builtins.concatStringsSep "," value.meta.platforms;
        }) (lib.filterAttrs (_: v: lib.isDerivation v) packages)
      );
    }
  );
in
pkgs.writeShellScript "create-docs" ''
  	cat ${input} | ${pkgs.mustache-go}/bin/mustache  ${./template.md.mustache} > README.md

''
