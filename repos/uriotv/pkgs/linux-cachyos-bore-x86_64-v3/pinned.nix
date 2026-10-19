# The kernel pin is independent of the consumer's nixpkgs and of the other NUR
# packages. Its compiler/configuration must match CI for binary-cache hits.
{ system ? "x86_64-linux" }:
let
  source = builtins.fromJSON (builtins.readFile ./upstream/source.json);
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${source.nixpkgs.rev}.tar.gz";
    sha256 = source.nixpkgs.narHash;
  };
  pkgs = import nixpkgs { inherit system; };
  kernel = pkgs.callPackage ./. { };
in
{
  inherit pkgs kernel;
  kernelPackages = pkgs.linuxPackagesFor kernel;
}
