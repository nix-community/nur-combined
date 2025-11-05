{
  pkgs,
  lib ? pkgs.lib,
  ...
}:
let
  fym998 = {
    name = "fym998";
    email = "fujun998@outlook.com";
    github = "fym998";
    githubId = 61316972;
  };
  callPackage =
    pkg: args:
    (pkgs.callPackage pkg args).overrideAttrs (
      finalAttrs: previousAttrs: {
        meta = previousAttrs.meta // {
          maintainers = [ fym998 ];
        };
      }
    );
in
lib.packagesFromDirectoryRecursive {
  inherit callPackage;
  directory = ./by-path;
}
