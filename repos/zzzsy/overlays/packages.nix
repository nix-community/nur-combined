{ inputs, lib }:
final: prev:
let
  system = final.stdenv.hostPlatform.system;
  sources = final.callPackage ../pkgs/_sources/generated.nix { };
  my = lib.my.importPackages final sources ../pkgs;
in
{
  zen-browser = inputs.zen-browser.packages.${system}.twilight;
  noctalia-shell = inputs.noctalia.packages.${system}.default;
  inherit my;
}
