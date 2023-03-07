{ self, nixpkgs, ... }:
system:
let
  pkgs = nixpkgs.legacyPackages.${system};
in
{
  default = pkgs.mkShell {
    name = "NixOS-config";

    nativeBuildInputs = with pkgs; [
      gitAndTools.pre-commit
      nixpkgs-fmt
    ];

    inherit (self.checks.${system}.pre-commit) shellHook;
  };
}
