{ nixpkgs ? <nixpkgs> }:

let
  pkgs.x86_64-linux  = import nixpkgs { system = "x86_64-linux"; };
  pkgs.x86_64-darwin = import nixpkgs { system = "x86_64-darwin"; };

in {
  pkgs-linux  = pkgs.x86_64-linux.callPackages  ./non-broken.nix {};
  pkgs-darwin = pkgs.x86_64-darwin.callPackages ./non-broken.nix {};
}
