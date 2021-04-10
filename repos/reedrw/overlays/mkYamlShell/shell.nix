with import <nixpkgs> { };

let
  mkYamlShell = pkgs.callPackage ./. { };
in
mkYamlShell ./shell.yml
