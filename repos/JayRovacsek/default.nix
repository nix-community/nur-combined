{ self ? (import (let lock = builtins.fromJSON (builtins.readFile ./flake.lock);
in fetchTarball {
  url =
    "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
  sha256 = lock.nodes.flake-compat.locked.narHash;
}) { src = ./.; }).defaultNix, system ? null, pkgs ? null }:
if builtins.any isNull [ system pkgs ] then
  self.outputs.packages.${builtins.currentSystem}
else {
  vulnix-pre-commit =
    import ./pkgs/vulnix-pre-commit { inherit self system pkgs; };
  better-english = import ./pkgs/better-english { inherit self system pkgs; };
}
