# Shared registry discovery for package exports and the flake overlay. This reads
# source directory entries only; it must not inspect a nixpkgs package set/fixpoint.
{
  packageDirectory ? ../pkgs,
}:
let
  entries = builtins.readDir packageDirectory;
in
builtins.filter (
  name:
  entries.${name} == "directory" && builtins.pathExists (packageDirectory + "/${name}/default.nix")
) (builtins.attrNames entries)
