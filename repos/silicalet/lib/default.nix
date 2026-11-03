{ pkgs }:

{
  reaDependencies = import ./rea-dependencies.nix { inherit pkgs; };
}
