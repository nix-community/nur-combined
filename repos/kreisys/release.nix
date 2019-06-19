{ nixpkgs ? <nixpkgs> }:

let
  pkgs.x86_64-linux  = import nixpkgs { system = "x86_64-linux"; };
  pkgs.x86_64-darwin = import nixpkgs { system = "x86_64-darwin"; };

in {
  pkgs-linux  = (pkgs.x86_64-linux.callPackages  ./ci.nix {}).buildOutputs;
  pkgs-darwin = (pkgs.x86_64-darwin.callPackages ./ci.nix {}).buildOutputs;
}
