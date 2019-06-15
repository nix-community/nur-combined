{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs {} }:

{
  pkgs-linux = builtins.removeAttrs (pkgs.callPackages ./non-broken.nix {}) [ "fishPlugins" "emacs" ];
}
