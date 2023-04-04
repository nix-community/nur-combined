{pkgs ? import <nixpkgs> {}}:
let
  inherit (pkgs.lib) callPackageWith mapAttrs fix genAttrs;
  inherit (builtins) pathExists filter attrNames readDir;
  users = readDir "/home";
  filteredUsers = filter (user: pathExists "/home/${user}/packages.nix") (attrNames users);
in
fix (self: genAttrs filteredUsers (user: callPackageWith (pkgs // self) "/home/${user}/packages.nix" {}))
