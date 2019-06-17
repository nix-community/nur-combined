{ nixpkgs ? <nixpkgs> }:

let
  pkgs.x86_64-linux = import nixpkgs { system = "x86_64-linux"; };

in {
  pkgs-linux = pkgs.x86_64-linux.callPackages ./non-broken.nix {};
}
