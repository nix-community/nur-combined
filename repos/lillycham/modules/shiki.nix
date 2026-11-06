let
  source = import ../pkgs/shiki/source.nix;
  # Module imports must not depend on pkgs, which Home Manager defines later.
  src = builtins.fetchTarball {
    url = "https://github.com/${source.owner}/${source.repo}/archive/${source.rev}.tar.gz";
    sha256 = source.hash;
  };
in
{ pkgs, ... }:
let
  package = pkgs.callPackage ../pkgs/shiki { };
in
{
  imports = [
    (import "${src}/nix/module.nix" {
      self.packages.${pkgs.stdenv.hostPlatform.system}.default = package;
    })
  ];
}
